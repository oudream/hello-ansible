
**MDT** automates the deployment of Windows on workstations

CTRL + SHIFT + F3 to bypass the Windows configuration wizard at the first boot

**Preparation**
Download and install MDT and ADK

https://developer.microsoft.com/fr-fr/windows/hardware/windows-assessment-deployment-kit

https://www.microsoft.com/en-us/download/details.aspx?id=54259*

During installation leave all items checked by default.

Creating the deployment point

Run Deployment Workbench

Right click on Deployment Shares > New Deployment Share

C:\MDTProd
MDTProd$
MDT Production

Leave the rest of the default options and do the following until confirmation

**Configuration**

Right click on MDT Production and Properties

Uncheck x86

Add this in the Rules tab

```ini
[Settings]
Priority=Default
Properties=MyCustomProperty
[Default]
_SMSTSORGNAME=IT
OSInstall=Y
SkipCapture=YES
SkipProductKey=YES
SkipComputerBackup=YES
SkipUserData =YES
:Set ComputerName
OSDComputerName=MW-%SerialNumber%
TaskSequenceID=W10-1809v1
SkipTaskSequence=NO
SkipBitLocker=NO
SkipApplications=NO
MandatoryApplications001={2e45d12b-b9d4-46bf-a171-aa97b3a76061}
MandatoryApplications002={f084bca6-2fb0-4335-bb76-97ec276bf321}
MandatoryApplications003={bc1d8805-6293-46e5-8a3b-a9057742d3fc}
MandatoryApplications004={23a46eb3-d57a-4e2f-bb42-b796e5b1c938}
MandatoryApplications005={a5abd761-035c-47de-96de-d376652b6501}
MandatoryApplications006={4fb2740a-1c2b-42d9-91f8-9cdcca54403c}
MandatoryApplications007={46d178d8-3e48-4ea0-a0a8-a1b19a419d87}
MandatoryApplications008={d45442b2-8023-44f1-9020-520419d65d27}
SkipAdminPassword=YES
AdminPassword=passwordadminlocal
SkipDomainMembership=YES
JoinDomain=mondomain.lan
DomainAdmin=accountforjoindomain
DomainAdminDomain=mondomain
DomainAdminPassword=password
MachineObjectOU=OU=Computers,OU=Workstations,OU=Companies,DC=mondomain,DC=lan
SkipLocaleSelection=YES
SkipTimeZone=YES
KeyboardLocale=040c:0000040c
UserLocale=fr-FR
UILanguage=fr-FR
TimeZone=105
TimeZoneName=Romance Standard Time
EventService=http://mdt:9800
```

Edit bootstrap.ini

```ini
[Settings]
Priority=Default
[Default]
DeployRoot=\\MDT\MDTProd$
UserDomain=mondomain
UserID=accountforconnnecttoshare
UserPassword=password
SkipBDDWelcome=YES
KeyboardLocalePE=040c:0000040c
```


**Importing OS**
Unzip the latest version of Windows ISO into a directory

Check the presence of the install.wim file if it is not present there will be an install.esd file instead, it must be converted to.wim

Open a DOS command prompt as administrator

we type this command to check which version of Windows we need

dism /Get-WimInfo /WimFile:install.esd

type this command in the directory where the install.esd file is located (by modifying /SourceIndex:8 with the Windows version number we need index:8 for Windows Pro in our case)

dism /export-image /SourceImageFile:install.esd /SourceIndex:8 /DestinationImageFile:install.wim /Compress:max /CheckIntegrity

Finally we can import the OS into our Deployment Workshop

Clic droit sur Operating Systems > Custom image file

Source directory: we indicate the path where the install.wim file that we just generated is located > Next

Setup files are not needed selctionné > Next

Destination directory name

Windows 10 Pro x64
Summary > Next

**Preparation of the task**
Still on Deployment Workbench

MDT Build Lab > Task Sequences > clic droit New Task Sequence

Task sequence ID: W10-1809-MMv1

Task sequence name: W10-1809-MMv1

Standard Client Task Sequence

Select OS: Windows 10 Pro.wim

Do not specify....

OS Settings laisser par defaut

Do not specify password an Administrator

Summary > Next

**Generate the WinPE ISO**

Right click on the MDT Production and select properties

Platform x64

change the name and put

MDT Prod(x64)

MDTProdx64.iso

Apply

Right click on MDT Production

Update Deployment Share

**Boot on WINPE**

Use a PC SPARE or a VM

You can boot either by PXE (by putting the ISO MDT Build Lab on it) or by flashing the ISO on a USB stick

**Add applications**
Right click on applications > new application

Select the first option > Application with source files

Fill in the information

Browse the directory where the application is based

indicate the name of the application directory

Add a command line to start the installation or directly enter the .exe to install

Validate

**Add Custom Settings**

create .cmd file

SetCustomSettings.cmd

add this content

```ini
rem ****Setup WallPaper****
takeown /f c:\windows\WEB\wallpaper\Windows\img0.jpg
takeown /f C:\Windows\Web\4K\Wallpaper\Windows\*.*
icacls c:\windows\WEB\wallpaper\Windows\img0.jpg /grant Administrateur:(F)
icacls C:\Windows\Web\4K\Wallpaper\Windows\*.* /grant Administrateur:(F)
del c:\windows\WEB\wallpaper\Windows\img0.jpg
del /q C:\Windows\Web\4K\Wallpaper\Windows\*.*
copy "%~dp0img0.jpg" c:\windows\WEB\wallpaper\Windows\img0.jpg
rem ****Setup Product Key****
@ECHO OFF
ECHO.
ECHO We will retrieve the product key from the bios (if it exists) and store it as a variable.
for /F "tokens=* delims=" %%i in ('%~dp0GetWinkey.exe') do set PRODUCTKEY=%%i
IF ["%PRODUCTKEY%"]==[] GOTO NOKEY
ECHO.
ECHO Your Product Key is %PRODUCTKEY%
ECHO.
ECHO We will now take this product key and install it using the "Software License Manager" (SLMGR) tool.
cscript //B "%SYSTEMROOT%\system32\slmgr.vbs" -ipk %PRODUCTKEY%
ECHO.
ECHO We will now take the newly installed product key and activate Windows.
cscript //B "%SYSTEMROOT%\system32\slmgr.vbs" -ato
GOTO END
:NOKEY
ECHO.
ECHO No product key was found in the BIOS using the supplied tool. Please try another tool to extract the key manually.
:END
ECHO.
rem ****Copy Bitlocker Recovery****
net use b: \\bitlocker /user:domain\account password
copy "c:\*.txt" b:\
rem ****Setup Wifi Key
netsh wlan add profile filename="%~dp0wifi.xml" user=all
```

Back to Deployment Workbench

Right click on applications > new application

Select the first option > Application with source files

Fill in the information

Browse the directory where SetCustomSettings.cmd is located

indicate the name SetCustomSettings

Add cmd.exe /c SetCustomSettings.cmd to the command line

Validate

Task Sequences > right click on W10-1809-MMv1 > properties

Onglet Task Sequences > Descendre Custom Tasks apres enable bitlocker

cliquer sur Add en haut > General > Install Application > Install single application > Select SetCustomSettings

#### Erreurs

**Failed to save the current environment to (80070057)**

**Litetouch deployment failed, Return Code = -2147467259 0x80004005**

**Failed to create D:_SMSTaskSequence**

- Si on fait un diskpart à ce moment la on realise que Wndows est sur C:\ et non D:\

- il faut donc éditer le fichier **ZTIDiskpart.wsf** et modifier les lignes suivantes pour faire pointer sur D:\

- Si c'est un poste fixe on doit désactiver le DVD-ROM le temps du matriçage

```ini
Const DISKPART_MAIN_DRIVE = "D:"If iDiskIndex = 0 and oFSO.FileExists("D:\OEM.wsf") thenoLogging.CreateEntry "D:\OEM.wsf exists. Running an OEM Scenario: Skip.", LogTypeInfo"
```
