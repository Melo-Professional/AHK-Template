#Requires AutoHotkey v2.0
#Include .\winrt\windows.ahk
#SingleInstance Force
Persistent(true)

/* 
App:={}
App.Name := "Template"
App.Icon := A_ScriptDir "app.icon"
App.Icon := "E:\Users\Melo\Documents\GitHub\scripts\Scripts_Windows\_Template\assets\winrt\app.ico"
 
NotificationTitle := "App Status Notification"
NotificationBody  := "The automation job completed successfully without thread lock directives."

MyToast(NotificationTitle, NotificationBody, App.Icon)
 */

/**
 * Creates and displays a native Windows Toast notification using the template injection model.
 * @param {String} title - The title text of the notification (e.g., App.Name).
 * @param {String} message - The body text or message content.
 * @param {String} iconPath - (Optional) Absolute path to a local image file (PNG/JPG).
 * @param {String} appId - (Optional) Registered AppUserModelID. Defaults to AutoHotkey.
 */
MyToast(title := "Title", message := "Message", iconPath := App.Icon, appId := App.Name) {
    ; Reference the native ToastNotificationManager
    TNM := Windows.UI.Notifications.ToastNotificationManager
    
    ; Grab the standard image and text template object from the OS
    toastXml := TNM.GetTemplateContent('ToastImageAndText02')
    
    ; Populate the text lines directly into the managed nodes
    toastXml.GetElementsByTagName("text").GetAt(0).InnerText := title
    toastXml.GetElementsByTagName("text").GetAt(1).InnerText := message
    
    ; Inject the image path safely if the file exists on disk
    if (iconPath != "" && FileExist(iconPath)) {
        toastXml.GetElementsByTagName("image").Item(0).SetAttribute("src", iconPath)
    }
    
    ; Initialize and show the notification container
    notification := Windows.UI.Notifications.ToastNotification(toastXml)
    toastNotifier := TNM.CreateToastNotifier(appId)
    toastNotifier.Show(notification)
}