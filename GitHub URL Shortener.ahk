;................................................................................
;																				.
; app ...........: tigerlily's GitHub URL Shortener								.
; version .......: 0.1.0														.
;																				.
;................................................................................
;																				.
; author ........: tigerlily													.
; language ......: AutoHotkey V2 (alpha 122-f595abc2)							.
; github repo ...: git.io/tigerlilysGitHubURLShortener  						.
; forum thread ..: bit.ly/tigerlilys-github-url-shortener-AHK-forum				.
; license .......: MIT (git.io/tigerlilysGitHubURLShortenerLicense)				.
;																				.
;................................................................................



;................................................................................
;		   ...........................................................			.
;           A U T O - E X E C U T E   &   I N I T I A L I Z A T I O N			.
;................................................................................

#SingleInstance

;................................................................................
;		                .................................		                .
;                        D E F A U L T   S E T T I N G S		                .
;................................................................................

; Change these assignments below to change default load settings 
user  := "user-name"       
repo  := "A-Repository-Name"
addtl := "/other/optional/subfolders"
code  := "yourShortcode"


;................................................................................
;					  ..................................						.
;                      T R A Y  M E N U   &   I C O N S		                 	.
;................................................................................

; Set Icon ToolTip and App Name
A_IconTip := "tigerlily's GitHub URL Shortener"

; Create tray menu with a "Close App" option
A_TrayMenu.Delete()
A_TrayMenu.Add(A_IconTip, (*) => GitHubUrlShortener.Show()) 
A_TrayMenu.Add() 
A_TrayMenu.Add("Close", (*) => ExitApp()) 

; Allows a single left-click on taskbar icon to open monitor menu
OnMessage(0x404, (wParam, lParam, *) => lParam = 0x201 ? GitHubUrlShortener.Show() : "")

; Try to download and set tray/menu icons without keeping images saved locally
try Download("https://i.imgur.com/V1uoZpS.png", A_ScriptDir "\tray-icon.png")
try Download("https://i.imgur.com/Ea1kZrE.png", A_ScriptDir "\close-app.png")
try TraySetIcon(A_ScriptDir "\tray-icon.png")
try A_TrayMenu.SetIcon(A_IconTip , A_ScriptDir "\tray-icon.png")
try A_TrayMenu.SetIcon("Close" , A_ScriptDir "\close-app.png")
(FileExist(A_ScriptDir "\tray-icon.png")) ? FileDelete(A_ScriptDir "\tray-icon.png") : ""
(FileExist(A_ScriptDir "\close-app.png")) ? FileDelete(A_ScriptDir "\close-app.png") : ""



;................................................................................
;								     .......		        					.
;                                     G U I       		                    	.
;................................................................................

; Create and display "GitHub URL Shortener" GUI and Controls
GitHubUrlShortener := Gui.New( "MaximizeBox", A_IconTip)
GitHubUrlShortener.OnEvent("Close", (GitHubUrlShortener) => GitHubUrlShortener.Hide() )
GitHubUrlShortener.OnEvent("Size" , (GitHubUrlShortener, MinMax, *) => MinMax = -1 ? GitHubUrlShortener.Hide() : "" )
GitHubUrlShortener.SetFont("c0xC6C8C5 s8 bold"), GitHubUrlShortener.BackColor := 0x000000
GitHubUrlShortener.MarginX := 20, GitHubUrlShortener.MarginY := 10

GitHubUrlShortener.Add("Text", "w450 center", "Enter the rest of a GitHub URL:")
GitHubUrlShortener.Add("Text", "w70", "https://github.com/")
url     := user "/" repo . addtl
urlEdit := GitHubUrlShortener.Add("Edit", "r1 vurl w342 yp Background0x000000", url)
urlEdit.OnEvent("Change", "UpdateTargetUrl")

GitHubUrlShortener.Add("Text", "xm w450 center", "Or build one:")
GitHubUrlShortener.Add("Text", "w70", "User Name:")
userEdit := GitHubUrlShortener.Add("Edit", "r1 yp vuser w370 Background0x000000", user)
userEdit.OnEvent("Change", "UpdateTargetUrl")

GitHubUrlShortener.Add("Text", "w70 xm", "Repository:")
repoEdit := GitHubUrlShortener.Add("Edit", "r1 yp vrepo w370 Background0x000000", repo)
repoEdit.OnEvent("Change", "UpdateTargetUrl")

GitHubUrlShortener.Add("Text", "w70 xm", "Additional:")
addtlEdit := GitHubUrlShortener.Add("Edit", "r1 yp vaddtl w370 Background0x000000", addtl)
addtlEdit.OnEvent("Change", "UpdateTargetUrl")

GitHubUrlShortener.Add("Text", "w450 xm center", "Then enter your desired short URL code:")
codeEdit := GitHubUrlShortener.Add("Edit", "r1 vcode w450 Background0x000000", code)
codeEdit.OnEvent("Change", "UpdateShortUrlExample") 

shortUrlExample := GitHubUrlShortener.Add("Text", "w450 center", "output example:" A_Tab "https://git.io/" codeEdit.Value)
shortUrlExample.SetFont("s8 bold")

ShortenUrlButton := GitHubUrlShortener.Add("Text", "w450 h20 Background0x4A4A47 center border", "Shorten That URL!")
ShortenUrlButton.SetFont("s12 bold")
ShortenUrlButton.OnEvent("Click", "ShortenUrl")

GitHubUrlShortener.Show()



;................................................................................
;								...................								.
;                                F U N C T I O N S		                    	.
;................................................................................


UpdateTargetUrl(ctrl, *){ ; Updates target URL edit control with each keypress.
                          ; Restricts most non-alphanumeric chars.
    global    
    value := ctrl.Value, name := ctrl.name
        name = "url"   ? RemoveInvalidChars("[^%\/A-Za-z0-9_-]") 
    :   name = "addtl" ? RemoveInvalidChars("[^\/A-Za-z0-9_-]")
    :                    RemoveInvalidChars("[^A-Za-z0-9_-]")
    
        name = "url"   ? "" 
    :   urlEdit.Value := userEdit.Value "/" repoEdit.Value . addtlEdit.Value

    RemoveInvalidChars(needle){

        if (pos := RegExMatch(value, needle))
        {            
            ctrl.Value := RegExReplace(value, needle, "")   
            ctrl.Focus(), Send("{Left}{Right " pos - 1 "}")
        }  
    }
}

UpdateShortUrlExample(*){  ; Updates short URL example with each keypress.
                           ; Restricts all non-alphanumeric chars.
    global     
    value := codeEdit.Value, needle := "[^A-Za-z0-9]"
    if (pos := RegExMatch(value, needle))
    {  
        value := codeEdit.Value := RegExReplace(value, needle, "")
        shortUrlExample.Value := "output example:" A_Tab "https://git.io/" value
        codeEdit.Focus(), Send("{Left}{Right " pos - 1 "}")
    }  
    else
        shortUrlExample.Value := "output example:" A_Tab "https://git.io/" value    
}

ShortenUrl(*){ ; Copies newly created short URL to clipboard on success. Displays target URL,
               ; newly created short URL, and short URL character length. Option to test short URL.
               ; If status code returned is not 201: fail. Displays status code for debugging.
    global
    GitHubUrlShortener.Hide()
    data := "url=https://github.com/" urlEdit.Value "&code=" CodeEdit.Value

    whr := ComObjCreate("WinHttp.WinHttpRequest.5.1")
    whr.Open("POST", "https://git.io", true)
    whr.SetRequestHeader("Content-Type", "application/x-www-form-urlencoded")
    whr.Send(data), whr.WaitForResponse()

    status := whr.Status A_Space whr.StatusText
    status = "201 Created" ?    (shortUrl := (whr.GetResponseHeader("Location"))
                           ,    (shortUrlLen := StrLen(shortUrl))
                           ,    (targetUrl := whr.ResponseText)
                           ,    ShowStatusAlert("Success", shortUrl, shortUrlLen, targetUrl)) 
                           :    ShowStatusAlert("Fail")           
                  
    ShowStatusAlert(statusReturned, shortUrl := "", shortUrlLen := "", targetUrl := ""){
        
        static Statuses := Map(
            "Success", "Success! Short URL created and copied to clipboard.`n`nShort URL (" shortUrlLen " chars):`n" (A_Clipboard := shortUrl) "`n`nTarget URL:`n" targetUrl,
            "Fail",    "Failed for some reason.`n`nHTTP Status: " status)

        statusAlert := Gui.New( "-MaximizeBox", A_IconTip)
        statusAlert.OnEvent("Close", (statusAlert) => statusAlert.Destroy() )
        statusAlert.OnEvent("Size" , (statusAlert, MinMax, *) => MinMax = -1 ? statusAlert.Minimize() : "" )
        statusAlert.SetFont("c0xC6C8C5 s10 bold"), statusAlert.BackColor := 0x000000
        statusAlert.MarginX := 20, statusAlert.MarginY := 10
        statusAlertText := statusAlert.Add("Text", , Statuses[statusReturned])
        OkButton := statusAlert.Add("Text", "w450 h20 Background0x4A4A47 center border", statusReturned = "Success" ? "SWEET" : "DARNIT")
        OkButton.SetFont("s12 bold")
        OkButton.OnEvent("Click", (*) => statusAlert.Destroy())
        if (statusReturned = "Success")
        {
            OkButton.Opt("w225")
            TestShortUrlButton := statusAlert.Add("Text", "w450 h20 Background0x4A4A47 center border", "TEST THE SHORT LINK!")
            TestShortUrlButton.SetFont("s12 bold")
            TestShortUrlButton.OnEvent("Click", (*) => testShortUrl())                                   
        }
        statusAlert.Show()

        testShortUrl(*){
            
            statusAlert.Destroy()
            Run(shortUrl)
        }    
    }
 }
