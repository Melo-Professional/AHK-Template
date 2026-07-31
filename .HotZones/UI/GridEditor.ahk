#Requires AutoHotkey v2.0

; UI\GridEditor.ahk
; Premium fullscreen zone layout editor — dark glass theme

class GridEditor {
    ; ── GDI+ contexts (one per monitor) ──────────────────────────────────────
    static hGuis        := []
    static pGraphics    := []   ; array of {GraphicsScreen, GraphicsBuffer, Bitmap, Info, Hwnd, Index}

    ; ── Zone data ─────────────────────────────────────────────────────────────
    static Zones        := []   ; fractional {X,Y,W,H} 0..1
    static SelectedZone := 1
    static HoverZone    := 0

    ; ── Drag state ────────────────────────────────────────────────────────────
    static IsDragging   := false
    static DragMode     := ""   ; "V" | "H"
    static DragSplitVal := 0.0
    static DragTolerance := 8   ; pixels from edge to activate drag handle

    ; ── Toolbar native Gui ────────────────────────────────────────────────────
    static hToolbar     := 0
    static guiToolbar   := 0

    ; ── Redraw rate limiter ───────────────────────────────────────────────────
    static LastRedraw   := 0

    ; ── Cached GDI resources (created once, freed on close) ───────────────────
    static hFontLabel   := 0
    static hFontLabelSm := 0
    static hFontBtn     := 0
    static hFmtCenter   := 0

    ; ══════════════════════════════════════════════════════════════════════════
    static Show() {
        if this.hGuis.Length {
            for hGui in this.hGuis
                WinActivate("ahk_id " hGui)
            return
        }

        ; Deep-copy zones from current profile
        profile := Config.Profiles[Config.CurrentProfile]
        this.Zones := []
        for i, z in profile.Zones
            this.Zones.Push({X: z.X, Y: z.Y, W: z.W, H: z.H})
        this.SelectedZone := 1
        this.HoverZone    := 0
        if (this.Zones.Length == 0)
            this.Zones.Push({X:0.0, Y:0.0, W:1.0, H:1.0})

        this.hGuis     := []
        this.pGraphics := []

        ; Create GDI+ cached resources
        this.hFontLabel   := Gdip_CreateFont("Segoe UI", 22, 0)
        this.hFontLabelSm := Gdip_CreateFont("Segoe UI", 13, 0)
        this.hFontBtn     := Gdip_CreateFont("Segoe UI", 12, 1)
        this.hFmtCenter   := Gdip_CreateStringFormat(1, 1)

        ; Create one fullscreen overlay per monitor
        monCount := MonitorGetCount()
        loop monCount {
            mInfo := Monitor.GetInfo(A_Index)
            if !mInfo
                continue

            g := Gui("+AlwaysOnTop -Caption +ToolWindow -DPIScale +E0x08000000")
            g.BackColor := "080810"
            WinSetTransparent(225, g.Hwnd)

            g.Show("x" mInfo.WorkLeft " y" mInfo.WorkTop
                 " w" mInfo.Width    " h" mInfo.Height " NoActivate")

            pScreen := Gdip_GraphicsFromHWND(g.Hwnd)
            pBmp    := Gdip_CreateBitmap(mInfo.Width, mInfo.Height)
            pBuf    := Gdip_GraphicsFromImage(pBmp)
            Gdip_SetSmoothingMode(pBuf, 4)

            this.hGuis.Push(g.Hwnd)
            this.pGraphics.Push({
                GraphicsScreen: pScreen,
                GraphicsBuffer: pBuf,
                Bitmap: pBmp,
                Info: mInfo,
                Hwnd: g.Hwnd,
                Index: A_Index,
                GuiObj: g
            })
        }

        ; Build the floating toolbar
        this.BuildToolbar()

        ; Register messages
        OnMessage(0x0100, ObjBindMethod(this, "OnKeyDown"))   ; WM_KEYDOWN
        OnMessage(0x0200, ObjBindMethod(this, "OnMouseMove")) ; WM_MOUSEMOVE
        OnMessage(0x0201, ObjBindMethod(this, "OnLButtonDown"))
        OnMessage(0x0202, ObjBindMethod(this, "OnLButtonUp"))

        this.RedrawAll()
    }

    ; ── Toolbar ───────────────────────────────────────────────────────────────
    static BuildToolbar() {
        ; Get primary monitor info to anchor toolbar
        primaryIdx := MonitorGetPrimary()
        mInfo := Monitor.GetInfo(primaryIdx)

        tbW := 560
        tbH := 52
        tbX := mInfo.WorkLeft + (mInfo.Width // 2) - (tbW // 2)
        tbY := mInfo.WorkTop + 22

        g := Gui("+AlwaysOnTop -Caption +ToolWindow -DPIScale")
        g.BackColor := "141418"
        g.MarginX := 10
        g.MarginY := 10

        g.SetFont("s11 w600 cE0E0E0", "Segoe UI")

        btnW := 110
        btnH := 34
        pad  := 10

        bSV   := g.Add("Button", "x" pad " y" (tbH//2 - btnH//2) " w" btnW " h" btnH " vBtnSV",   "◫  Split ↔")
        bSH   := g.Add("Button", "x" (pad+btnW+6) " y" (tbH//2 - btnH//2) " w" btnW " h" btnH " vBtnSH",   "⊟  Split ↕")
        bDel  := g.Add("Button", "x" (pad+btnW*2+12) " y" (tbH//2 - btnH//2) " w90 h" btnH " vBtnDel",  "✕  Delete")
        bSave := g.Add("Button", "x" (pad+btnW*2+108) " y" (tbH//2 - btnH//2) " w130 h" btnH " vBtnSave", "✔  Save (ESC)")

        bSV.OnEvent("Click",   ObjBindMethod(this, "SplitVertical"))
        bSH.OnEvent("Click",   ObjBindMethod(this, "SplitHorizontal"))
        bDel.OnEvent("Click",  ObjBindMethod(this, "DeleteZone"))
        bSave.OnEvent("Click", ObjBindMethod(this, "SaveLayout"))

        g.Show("x" tbX " y" tbY " w" tbW " h" tbH " NoActivate")

        ; Make window corners round — cosmetic DWM call
        try {
            DWMWCP_ROUND := 2
            DllCall("dwmapi\DwmSetWindowAttribute", "Ptr", g.Hwnd,
                "UInt", 33, "Int*", DWMWCP_ROUND, "UInt", 4)
        }

        this.guiToolbar := g
        this.hToolbar   := g.Hwnd
    }

    ; ── Drawing ───────────────────────────────────────────────────────────────
    static RedrawAll() {
        ; Rate-limit to 60 fps
        now := A_TickCount
        if (now - this.LastRedraw < 14)
            return
        this.LastRedraw := now

        for ctx in this.pGraphics
            this.RedrawMonitor(ctx)
    }

    static RedrawMonitor(ctx) {
        if !ctx.GraphicsBuffer
            return
        if !this.hFontLabel   ; fonts not yet initialized
            return

        g := ctx.GraphicsBuffer
        W := ctx.Info.Width
        H := ctx.Info.Height

        ; ── clear ────────────────────────────────────────────────────────────
        Gdip_GraphicsClear(g, 0xFF0D0D12)

        ; ── brushes / pens ───────────────────────────────────────────────────
        bNormal  := Gdip_BrushCreateSolid(0x1A1E3A6E)  ; subtle blue tint fill
        bHover   := Gdip_BrushCreateSolid(0x2E1E5A9C)  ; hover fill
        bSel     := Gdip_BrushCreateSolid(0x440078D7)  ; selected fill (richer blue)
        bSelLine := Gdip_BrushCreateSolid(0xCC60CDFF)  ; label text selected
        bLabel   := Gdip_BrushCreateSolid(0x66FFFFFF)  ; label text normal
        bLabelSm := Gdip_BrushCreateSolid(0x44FFFFFF)  ; hint text

        pNorm    := Gdip_PenCreateSolid(0x22FFFFFF, 1)  ; zone border normal
        pSel     := Gdip_PenCreateSolid(0xFF60CDFF, 2)  ; zone border selected
        pHov     := Gdip_PenCreateSolid(0x664DC2FF, 1)  ; zone border hover
        pHandle  := Gdip_PenCreateSolid(0x9960CDFF, 4)  ; drag handle indicator

        ; ── pass 1: zone fills (pixel-precise) ───────────────────────────────
        for i, z in this.Zones {
            zx := Floor(z.X * W)
            zy := Floor(z.Y * H)
            zw := Floor((z.X + z.W) * W) - zx
            zh := Floor((z.Y + z.H) * H) - zy

            if (i == this.SelectedZone)
                Gdip_FillRectangle(g, bSel, zx, zy, zw, zh)
            else if (i == this.HoverZone)
                Gdip_FillRectangle(g, bHover, zx, zy, zw, zh)
            else
                Gdip_FillRectangle(g, bNormal, zx, zy, zw, zh)
        }

        ; ── pass 2: borders ──────────────────────────────────────────────────
        for i, z in this.Zones {
            zx := Floor(z.X * W)
            zy := Floor(z.Y * H)
            zw := Floor((z.X + z.W) * W) - zx
            zh := Floor((z.Y + z.H) * H) - zy

            if (i == this.SelectedZone)
                Gdip_DrawRectangle(g, pSel, zx, zy, zw, zh)
            else if (i == this.HoverZone)
                Gdip_DrawRectangle(g, pHov, zx, zy, zw, zh)
            else
                Gdip_DrawRectangle(g, pNorm, zx, zy, zw, zh)
        }

        ; ── pass 3: drag handle highlights (bright lines on draggable edges) ─
        for i, z in this.Zones {
            ; Right vertical edge (if not screen edge)
            if (z.X + z.W < 0.99) {
                ex := Floor((z.X + z.W) * W)
                ey1 := Floor(z.Y * H) + 10
                ey2 := Floor((z.Y + z.H) * H) - 10
                Gdip_DrawLine(g, pHandle, ex, ey1, ex, ey2)
            }
            ; Bottom horizontal edge
            if (z.Y + z.H < 0.99) {
                ey := Floor((z.Y + z.H) * H)
                ex1 := Floor(z.X * W) + 10
                ex2 := Floor((z.X + z.W) * W) - 10
                Gdip_DrawLine(g, pHandle, ex1, ey, ex2, ey)
            }
        }

        ; ── pass 4: zone labels ───────────────────────────────────────────────
        for i, z in this.Zones {
            zx := Floor(z.X * W)
            zy := Floor(z.Y * H)
            zw := Floor((z.X + z.W) * W) - zx
            zh := Floor((z.Y + z.H) * H) - zy

            br := (i == this.SelectedZone) ? bSelLine : bLabel
            fnt := (i == this.SelectedZone) ? this.hFontLabel : this.hFontLabelSm

            ; Zone number centered
            Gdip_DrawString(g, "Zone " i, fnt, this.hFmtCenter, br,
                zx + 2, zy + 2, zw - 4, zh - 4)

            ; Selected zone hint
            if (i == this.SelectedZone && zw > 250 && zh > 80) {
                Gdip_DrawString(g, "Drag edges to resize  ·  Click toolbar to split or delete",
                    this.hFontLabelSm, this.hFmtCenter, bLabelSm,
                    zx + 2, zy + zh//2 + 14, zw - 4, 30)
            }
        }

        ; ── cleanup brushes/pens ──────────────────────────────────────────────
        for obj in [bNormal,bHover,bSel,bSelLine,bLabel,bLabelSm]
            Gdip_DeleteBrush(obj)
        for obj in [pNorm,pSel,pHov,pHandle]
            Gdip_DeletePen(obj)

        ; ── blit to screen ────────────────────────────────────────────────────
        Gdip_DrawImage(ctx.GraphicsScreen, ctx.Bitmap, 0, 0, W, H)
    }

    ; ── Hit testing ───────────────────────────────────────────────────────────
    static GetCtxFromHwnd(hwnd) {
        for ctx in this.pGraphics
            if (ctx.Hwnd == hwnd)
                return ctx
        return 0
    }

    static HasHwnd(hwnd) {
        for hGui in this.hGuis
            if (hGui == hwnd)
                return true
        return false
    }

    ; Returns {Type, Val?, ZoneA?, ZoneB?, Ctx}
    static GetHoverState(hwnd, x, y) {
        ctx := this.GetCtxFromHwnd(hwnd)
        if !ctx
            return {Type: "None"}

        W := ctx.Info.Width
        H := ctx.Info.Height
        tol := this.DragTolerance

        ; Check draggable vertical edges (right side of each zone)
        for i, z in this.Zones {
            edgeX := Floor((z.X + z.W) * W)
            if ((z.X + z.W) > 0.005 && (z.X + z.W) < 0.995
             && Abs(x - edgeX) <= tol) {
                return {Type: "V", Val: z.X + z.W, Ctx: ctx}
            }
        }

        ; Check draggable horizontal edges
        for i, z in this.Zones {
            edgeY := Floor((z.Y + z.H) * H)
            if ((z.Y + z.H) > 0.005 && (z.Y + z.H) < 0.995
             && Abs(y - edgeY) <= tol) {
                return {Type: "H", Val: z.Y + z.H, Ctx: ctx}
            }
        }

        ; Check zone under cursor
        px := x / W
        py := y / H
        for i, z in this.Zones {
            if (px >= z.X && px <= z.X + z.W && py >= z.Y && py <= z.Y + z.H)
                return {Type: "Zone", Index: i, Ctx: ctx}
        }

        return {Type: "None", Ctx: ctx}
    }

    ; ── Message handlers ──────────────────────────────────────────────────────
    static OnKeyDown(wParam, lParam, msg, hwnd) {
        if (!this.HasHwnd(hwnd) && hwnd != this.hToolbar)
            return
        if (wParam == 27)   ; ESC
            this.SaveLayout()
    }

    static OnMouseMove(wParam, lParam, msg, hwnd) {
        if !this.HasHwnd(hwnd)
            return

        x := lParam & 0xFFFF
        y := (lParam >> 16) & 0xFFFF

        ; ── dragging ────────────────────────────────────────────────────────
        if this.IsDragging {
            ctx := this.GetCtxFromHwnd(hwnd)
            if !ctx
                return
            px := Max(0.01, Min(0.99, x / ctx.Info.Width))
            py := Max(0.01, Min(0.99, y / ctx.Info.Height))

            if (this.DragMode == "V") {
                diff := px - this.DragSplitVal
                this.ApplyDragV(this.DragSplitVal, diff)
                this.DragSplitVal := px
            } else {
                diff := py - this.DragSplitVal
                this.ApplyDragH(this.DragSplitVal, diff)
                this.DragSplitVal := py
            }
            this.RedrawAll()
            return
        }

        ; ── hover ────────────────────────────────────────────────────────────
        state := this.GetHoverState(hwnd, x, y)
        newHover := 0
        if (state.Type == "V")
            DllCall("SetCursor","Ptr",DllCall("LoadCursor","Ptr",0,"Int",32644))
        else if (state.Type == "H")
            DllCall("SetCursor","Ptr",DllCall("LoadCursor","Ptr",0,"Int",32645))
        else if (state.Type == "Zone") {
            newHover := state.Index
            DllCall("SetCursor","Ptr",DllCall("LoadCursor","Ptr",0,"Int",32512)) ; arrow
        }

        if (newHover != this.HoverZone) {
            this.HoverZone := newHover
            this.RedrawAll()
        }
    }

    static OnLButtonDown(wParam, lParam, msg, hwnd) {
        if !this.HasHwnd(hwnd)
            return
        x := lParam & 0xFFFF
        y := (lParam >> 16) & 0xFFFF
        state := this.GetHoverState(hwnd, x, y)

        if (state.Type == "V" || state.Type == "H") {
            this.IsDragging   := true
            this.DragMode     := state.Type
            this.DragSplitVal := state.Val
        } else if (state.Type == "Zone") {
            if (this.SelectedZone != state.Index) {
                this.SelectedZone := state.Index
                this.RedrawAll()
            }
        }
    }

    static OnLButtonUp(wParam, lParam, msg, hwnd) {
        this.IsDragging := false
    }

    ; ── Drag helpers ──────────────────────────────────────────────────────────
    static ApplyDragV(edgeVal, diff) {
        eps := 0.0015
        for i, z in this.Zones {
            if (Abs(z.X + z.W - edgeVal) < eps) {
                z.W := Max(0.04, z.W + diff)
            } else if (Abs(z.X - edgeVal) < eps) {
                newX := z.X + diff
                z.W  := Max(0.04, z.W - diff)
                z.X  := newX
            }
        }
    }

    static ApplyDragH(edgeVal, diff) {
        eps := 0.0015
        for i, z in this.Zones {
            if (Abs(z.Y + z.H - edgeVal) < eps) {
                z.H := Max(0.04, z.H + diff)
            } else if (Abs(z.Y - edgeVal) < eps) {
                newY := z.Y + diff
                z.H  := Max(0.04, z.H - diff)
                z.Y  := newY
            }
        }
    }

    ; ── Zone operations ───────────────────────────────────────────────────────
    static SplitVertical(*) {
        if (this.SelectedZone < 1 || this.SelectedZone > this.Zones.Length)
            return
        z := this.Zones[this.SelectedZone]
        halfW := z.W / 2
        z.W := halfW
        this.Zones.InsertAt(this.SelectedZone + 1,
            {X: z.X + halfW, Y: z.Y, W: halfW, H: z.H})
        this.RedrawAll()
    }

    static SplitHorizontal(*) {
        if (this.SelectedZone < 1 || this.SelectedZone > this.Zones.Length)
            return
        z := this.Zones[this.SelectedZone]
        halfH := z.H / 2
        z.H := halfH
        this.Zones.InsertAt(this.SelectedZone + 1,
            {X: z.X, Y: z.Y + halfH, W: z.W, H: halfH})
        this.RedrawAll()
    }

    ; Smart delete: merge deleted zone into the best adjacent neighbor
    static DeleteZone(*) {
        if (this.Zones.Length <= 1)
            return

        del := this.Zones[this.SelectedZone]
        eps := 0.003   ; fractional tolerance for "shared edge"
        merged := false

        ; Try to find a neighbor that shares a full edge and can absorb the space
        ; Priority: same-row left/right neighbor, then same-column top/bottom
        for i, z in this.Zones {
            if (i == this.SelectedZone)
                continue

            ; Left neighbor: z.right == del.left, same Y/H band
            if (!merged && Abs((z.X + z.W) - del.X) < eps
             && Abs(z.Y - del.Y) < eps && Abs(z.H - del.H) < eps) {
                z.W += del.W
                merged := true
                break
            }
            ; Right neighbor
            if (!merged && Abs((del.X + del.W) - z.X) < eps
             && Abs(z.Y - del.Y) < eps && Abs(z.H - del.H) < eps) {
                z.X := del.X
                z.W += del.W
                merged := true
                break
            }
            ; Top neighbor
            if (!merged && Abs((z.Y + z.H) - del.Y) < eps
             && Abs(z.X - del.X) < eps && Abs(z.W - del.W) < eps) {
                z.H += del.H
                merged := true
                break
            }
            ; Bottom neighbor
            if (!merged && Abs((del.Y + del.H) - z.Y) < eps
             && Abs(z.X - del.X) < eps && Abs(z.W - del.W) < eps) {
                z.Y := del.Y
                z.H += del.H
                merged := true
                break
            }
        }

        ; If no perfect match, just give the space to the largest neighbor
        if (!merged) {
            bestArea := 0
            bestIdx  := 0
            for i, z in this.Zones {
                if (i == this.SelectedZone)
                    continue
                area := z.W * z.H
                if (area > bestArea) {
                    bestArea := area
                    bestIdx  := i
                }
            }
            if (bestIdx > 0) {
                nb := this.Zones[bestIdx]
                nb.X := Min(nb.X, del.X)
                nb.Y := Min(nb.Y, del.Y)
                nb.W := Max(nb.X + nb.W, del.X + del.W) - nb.X
                nb.H := Max(nb.Y + nb.H, del.Y + del.H) - nb.Y
            }
        }

        this.Zones.RemoveAt(this.SelectedZone)
        this.SelectedZone := Max(1, Min(this.SelectedZone, this.Zones.Length))
        this.RedrawAll()
    }

    ; ── Save / Close ──────────────────────────────────────────────────────────
    static SaveLayout(*) {
        profile := Config.Profiles[Config.CurrentProfile]
        profile.Zones := this.Zones
        Config.Save()
        this.OnClose()
    }

    static OnClose(*) {
        ; Unregister messages
        OnMessage(0x0100, ObjBindMethod(this, "OnKeyDown"),    0)
        OnMessage(0x0200, ObjBindMethod(this, "OnMouseMove"),  0)
        OnMessage(0x0201, ObjBindMethod(this, "OnLButtonDown"),0)
        OnMessage(0x0202, ObjBindMethod(this, "OnLButtonUp"),  0)

        ; Free GDI+ text resources
        if this.hFontLabel
            Gdip_DeleteFont(this.hFontLabel)
        if this.hFontLabelSm
            Gdip_DeleteFont(this.hFontLabelSm)
        if this.hFontBtn
            Gdip_DeleteFont(this.hFontBtn)
        if this.hFmtCenter
            Gdip_DeleteStringFormat(this.hFmtCenter)
        this.hFontLabel   := 0
        this.hFontLabelSm := 0
        this.hFontBtn     := 0
        this.hFmtCenter   := 0

        ; Free GDI+ screen contexts
        for ctx in this.pGraphics {
            if ctx.GraphicsBuffer {
                Gdip_DeleteGraphics(ctx.GraphicsBuffer)
                Gdip_DisposeImage(ctx.Bitmap)
                Gdip_DeleteGraphics(ctx.GraphicsScreen)
            }
        }
        this.pGraphics := []

        ; Destroy toolbar
        if this.guiToolbar {
            this.guiToolbar.Destroy()
            this.guiToolbar := 0
            this.hToolbar   := 0
        }

        ; Destroy overlay windows
        for hGui in this.hGuis
            GuiFromHwnd(hGui).Destroy()
        this.hGuis := []
    }
}
