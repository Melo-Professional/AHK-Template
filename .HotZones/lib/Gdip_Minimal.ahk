#Requires AutoHotkey v2.0

; Minimal GDI+ library for HotZones (AHK v2)
; Provides necessary functions to draw rectangles, fill colors, and handle graphics for overlay and editor.

Gdip_Startup() {
    If !DllCall("GetModuleHandle", "str", "gdiplus", "UPtr")
        DllCall("LoadLibrary", "str", "gdiplus")
    si := Buffer(24, 0)
    NumPut("UInt", 1, si, 0)
    pToken := 0
    DllCall("gdiplus\GdiplusStartup", "UPtr*", &pToken, "UPtr", si.Ptr, "UPtr", 0)
    return pToken
}

Gdip_Shutdown(pToken) {
    DllCall("gdiplus\GdiplusShutdown", "UPtr", pToken)
    If hModule := DllCall("GetModuleHandle", "str", "gdiplus", "UPtr")
        DllCall("FreeLibrary", "UPtr", hModule)
}

Gdip_GraphicsFromHWND(hwnd) {
    pGraphics := 0
    DllCall("gdiplus\GdipCreateFromHWND", "UPtr", hwnd, "UPtr*", &pGraphics)
    return pGraphics
}

Gdip_DeleteGraphics(pGraphics) {
    return DllCall("gdiplus\GdipDeleteGraphics", "UPtr", pGraphics)
}

Gdip_SetSmoothingMode(pGraphics, SmoothingMode) {
    return DllCall("gdiplus\GdipSetSmoothingMode", "UPtr", pGraphics, "Int", SmoothingMode)
}

Gdip_BrushCreateSolid(ARGB) {
    pBrush := 0
    DllCall("gdiplus\GdipCreateSolidFill", "UInt", ARGB, "UPtr*", &pBrush)
    return pBrush
}

Gdip_DeleteBrush(pBrush) {
    return DllCall("gdiplus\GdipDeleteBrush", "UPtr", pBrush)
}

Gdip_PenCreateSolid(ARGB, w) {
    pPen := 0
    DllCall("gdiplus\GdipCreatePen1", "UInt", ARGB, "Float", w, "Int", 2, "UPtr*", &pPen)
    return pPen
}

Gdip_DeletePen(pPen) {
    return DllCall("gdiplus\GdipDeletePen", "UPtr", pPen)
}

Gdip_FillRectangle(pGraphics, pBrush, x, y, w, h) {
    return DllCall("gdiplus\GdipFillRectangle", "UPtr", pGraphics, "UPtr", pBrush, "Float", x, "Float", y, "Float", w, "Float", h)
}

Gdip_DrawRectangle(pGraphics, pPen, x, y, w, h) {
    return DllCall("gdiplus\GdipDrawRectangle", "UPtr", pGraphics, "UPtr", pPen, "Float", x, "Float", y, "Float", w, "Float", h)
}

Gdip_DrawLine(pGraphics, pPen, x1, y1, x2, y2) {
    return DllCall("gdiplus\GdipDrawLine", "UPtr", pGraphics, "UPtr", pPen, "Float", x1, "Float", y1, "Float", x2, "Float", y2)
}


Gdip_FillRoundedRectangle(pGraphics, pBrush, x, y, w, h, r) {
    Region := Gdip_GetClipRegion(pGraphics)
    Gdip_SetClipRect(pGraphics, x-r, y-r, 2*r, 2*r, 4)
    Gdip_SetClipRect(pGraphics, x+w-r, y-r, 2*r, 2*r, 4)
    Gdip_SetClipRect(pGraphics, x-r, y+h-r, 2*r, 2*r, 4)
    Gdip_SetClipRect(pGraphics, x+w-r, y+h-r, 2*r, 2*r, 4)
    E := Gdip_FillRectangle(pGraphics, pBrush, x, y, w, h)
    Gdip_SetClipRegion(pGraphics, Region, 0)
    Gdip_SetClipRect(pGraphics, x-r, y-r, 2*r, 2*r, 4)
    Gdip_FillPie(pGraphics, pBrush, x, y, 2*r, 2*r, 180, 90)
    Gdip_SetClipRect(pGraphics, x+w-r, y-r, 2*r, 2*r, 4)
    Gdip_FillPie(pGraphics, pBrush, x+w-2*r, y, 2*r, 2*r, 270, 90)
    Gdip_SetClipRect(pGraphics, x-r, y+h-r, 2*r, 2*r, 4)
    Gdip_FillPie(pGraphics, pBrush, x, y+h-2*r, 2*r, 2*r, 90, 90)
    Gdip_SetClipRect(pGraphics, x+w-r, y+h-r, 2*r, 2*r, 4)
    Gdip_FillPie(pGraphics, pBrush, x+w-2*r, y+h-2*r, 2*r, 2*r, 0, 90)
    Gdip_SetClipRegion(pGraphics, Region, 0)
    Gdip_DeleteRegion(Region)
    return E
}

Gdip_DrawRoundedRectangle(pGraphics, pPen, x, y, w, h, r) {
    Gdip_SetClipRect(pGraphics, x-r, y-r, 2*r, 2*r, 4)
    Gdip_SetClipRect(pGraphics, x+w-r, y-r, 2*r, 2*r, 4)
    Gdip_SetClipRect(pGraphics, x-r, y+h-r, 2*r, 2*r, 4)
    Gdip_SetClipRect(pGraphics, x+w-r, y+h-r, 2*r, 2*r, 4)
    E := Gdip_DrawRectangle(pGraphics, pPen, x, y, w, h)
    Gdip_SetClipRect(pGraphics, x-r, y-r, 2*r, 2*r, 4)
    Gdip_DrawArc(pGraphics, pPen, x, y, 2*r, 2*r, 180, 90)
    Gdip_SetClipRect(pGraphics, x+w-r, y-r, 2*r, 2*r, 4)
    Gdip_DrawArc(pGraphics, pPen, x+w-2*r, y, 2*r, 2*r, 270, 90)
    Gdip_SetClipRect(pGraphics, x-r, y+h-r, 2*r, 2*r, 4)
    Gdip_DrawArc(pGraphics, pPen, x, y+h-2*r, 2*r, 2*r, 90, 90)
    Gdip_SetClipRect(pGraphics, x+w-r, y+h-r, 2*r, 2*r, 4)
    Gdip_DrawArc(pGraphics, pPen, x+w-2*r, y+h-2*r, 2*r, 2*r, 0, 90)
    return E
}

Gdip_GetClipRegion(pGraphics) {
    Region := Gdip_CreateRegion()
    DllCall("gdiplus\GdipGetClip", "UPtr", pGraphics, "UPtr", Region)
    return Region
}
Gdip_SetClipRegion(pGraphics, Region, CombineMode:=0) {
    return DllCall("gdiplus\GdipSetClipRegion", "UPtr", pGraphics, "UPtr", Region, "Int", CombineMode)
}
Gdip_SetClipRect(pGraphics, x, y, w, h, CombineMode:=0) {
    return DllCall("gdiplus\GdipSetClipRect", "UPtr", pGraphics, "Float", x, "Float", y, "Float", w, "Float", h, "Int", CombineMode)
}
Gdip_CreateRegion() {
    Region := 0
    DllCall("gdiplus\GdipCreateRegion", "UPtr*", &Region)
    return Region
}
Gdip_DeleteRegion(Region) {
    return DllCall("gdiplus\GdipDeleteRegion", "UPtr", Region)
}
Gdip_FillPie(pGraphics, pBrush, x, y, w, h, StartAngle, SweepAngle) {
    return DllCall("gdiplus\GdipFillPie", "UPtr", pGraphics, "UPtr", pBrush, "Float", x, "Float", y, "Float", w, "Float", h, "Float", StartAngle, "Float", SweepAngle)
}
Gdip_DrawArc(pGraphics, pPen, x, y, w, h, StartAngle, SweepAngle) {
    return DllCall("gdiplus\GdipDrawArc", "UPtr", pGraphics, "UPtr", pPen, "Float", x, "Float", y, "Float", w, "Float", h, "Float", StartAngle, "Float", SweepAngle)
}

Gdip_GraphicsClear(pGraphics, ARGB:=0x00000000) {
    return DllCall("gdiplus\GdipGraphicsClear", "UPtr", pGraphics, "Int", ARGB)
}

Gdip_CreateBitmap(Width, Height, Format:=0x26200A) {
    pBitmap := 0
    DllCall("gdiplus\GdipCreateBitmapFromScan0", "Int", Width, "Int", Height, "Int", 0, "Int", Format, "UPtr", 0, "UPtr*", &pBitmap)
    return pBitmap
}

Gdip_GraphicsFromImage(pBitmap) {
    pGraphics := 0
    DllCall("gdiplus\GdipGetImageGraphicsContext", "UPtr", pBitmap, "UPtr*", &pGraphics)
    return pGraphics
}

Gdip_DrawImage(pGraphics, pBitmap, dx, dy, dw, dh, sx:=0, sy:=0, sw:=0, sh:=0) {
    if (sw = 0)
        sw := dw, sh := dh
    return DllCall("gdiplus\GdipDrawImageRectRect", "UPtr", pGraphics, "UPtr", pBitmap, "Float", dx, "Float", dy, "Float", dw, "Float", dh, "Float", sx, "Float", sy, "Float", sw, "Float", sh, "Int", 2, "UPtr", 0, "UPtr", 0, "UPtr", 0)
}

Gdip_DisposeImage(pBitmap) {
    return DllCall("gdiplus\GdipDisposeImage", "UPtr", pBitmap)
}

; --- Text / Font helpers ---

Gdip_CreateFont(fontName, size, style:=0, unit:=3) {
    ; style: 0=Regular,1=Bold,2=Italic,3=BoldItalic; unit: 3=Pixel
    hFamily := 0
    DllCall("gdiplus\GdipCreateFontFamilyFromName", "WStr", fontName, "UPtr", 0, "UPtr*", &hFamily)
    hFont := 0
    DllCall("gdiplus\GdipCreateFont", "UPtr", hFamily, "Float", size, "Int", style, "Int", unit, "UPtr*", &hFont)
    DllCall("gdiplus\GdipDeleteFontFamily", "UPtr", hFamily)
    return hFont
}

Gdip_DeleteFont(hFont) {
    return DllCall("gdiplus\GdipDeleteFont", "UPtr", hFont)
}

Gdip_CreateStringFormat(align:=1, lineAlign:=1) {
    ; align/lineAlign: 0=Near,1=Center,2=Far
    hFormat := 0
    DllCall("gdiplus\GdipCreateStringFormat", "Int", 0, "Int", 0, "UPtr*", &hFormat)
    DllCall("gdiplus\GdipSetStringFormatAlign",     "UPtr", hFormat, "Int", align)
    DllCall("gdiplus\GdipSetStringFormatLineAlign", "UPtr", hFormat, "Int", lineAlign)
    return hFormat
}

Gdip_DeleteStringFormat(hFormat) {
    return DllCall("gdiplus\GdipDeleteStringFormat", "UPtr", hFormat)
}

Gdip_DrawString(pGraphics, str, hFont, hFormat, pBrush, x, y, w, h) {
    RectF := Buffer(16, 0)
    NumPut("Float", x, RectF, 0)
    NumPut("Float", y, RectF, 4)
    NumPut("Float", w, RectF, 8)
    NumPut("Float", h, RectF, 12)
    return DllCall("gdiplus\GdipDrawString", "UPtr", pGraphics, "WStr", str,
        "Int", -1, "UPtr", hFont, "UPtr", RectF.Ptr, "UPtr", hFormat, "UPtr", pBrush)
}
