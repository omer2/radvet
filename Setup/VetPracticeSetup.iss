[_ISTool]
EnableISX=false
UseAbsolutePaths=true

[Files]
Source: RunImage\Client\aussie.adm; DestDir: {app}
Source: RunImage\Client\gds32.dll; DestDir: {app}
Source: RunImage\Client\RADServers.exe; DestDir: {app}
Source: RunImage\Client\RADVet.exe; DestDir: {app}
Source: RunImage\Client\RADDoc.exe; DestDir: {app}
Source: RunImage\Client\RadVetHelp.chm; DestDir: {app}
Source: RunImage\Client\VetPracticeSMS.dll; DestDir: {app}
Source: RunImage\Client\DocumentTemplates\WelcomeLetter.rvf; DestDir: {app}\DocumentTemplates
Source: RunImage\Client\DocumentTemplates\AdmissionConsentForm.rvf; DestDir: {app}\DocumentTemplates
Source: RunImage\Client\DocumentTemplates\CatteryRegistration.rvf; DestDir: {app}\DocumentTemplates
Source: RunImage\Client\DocumentTemplates\CertificateOfSterilisation.rvf; DestDir: {app}\DocumentTemplates
Source: RunImage\Client\DocumentTemplates\CertificateOfVaccination.rvf; DestDir: {app}\DocumentTemplates
Source: RunImage\Client\DocumentTemplates\ClientRegistration.rvf; DestDir: {app}\DocumentTemplates
Source: RunImage\Client\DocumentTemplates\CreditApplication.rvf; DestDir: {app}\DocumentTemplates
Source: RunImage\Client\DocumentTemplates\DesexingReminder.rvf; DestDir: {app}\DocumentTemplates
Source: RunImage\Client\DocumentTemplates\EuthanasiaConsent.rvf; DestDir: {app}\DocumentTemplates
Source: RunImage\Client\DocumentTemplates\ExaminationForm.rvf; DestDir: {app}\DocumentTemplates
Source: RunImage\Client\DocumentTemplates\GroomingAdmission.rvf; DestDir: {app}\DocumentTemplates
Source: RunImage\Client\DocumentTemplates\PostOperativeCare.rvf; DestDir: {app}\DocumentTemplates
Source: RunImage\Client\DocumentTemplates\VaccinationReminder.rvf; DestDir: {app}\DocumentTemplates
Source: RunImage\Client\Templates\canine.jpg; DestDir: {app}\ImageTemplates
Source: RunImage\Client\Templates\canineeye.bmp; DestDir: {app}\ImageTemplates
Source: RunImage\Client\Templates\canineskin.bmp; DestDir: {app}\ImageTemplates
Source: RunImage\Client\Templates\canineteeth2.bmp; DestDir: {app}\ImageTemplates
Source: RunImage\Client\Templates\canineteeth.jpg; DestDir: {app}\ImageTemplates
Source: RunImage\Client\Templates\eyes.BMP; DestDir: {app}\ImageTemplates
Source: RunImage\Client\Templates\feline.jpg; DestDir: {app}\ImageTemplates
Source: RunImage\Client\Templates\felineeye.bmp; DestDir: {app}\ImageTemplates
Source: RunImage\Client\Templates\felineskin.bmp; DestDir: {app}\ImageTemplates
Source: RunImage\Client\Templates\felineteeth.bmp; DestDir: {app}\ImageTemplates
Source: RunImage\Client\Templates\felineteeth.jpg; DestDir: {app}\ImageTemplates
Source: RunImage\Client\Templates\horse.BMP; DestDir: {app}\ImageTemplates
Source: C:\Harmony\Setup\RunImage\Client\ReportTemplates\Receipt A5.rtm; DestDir: {app}\ReportTemplates\
Source: C:\Harmony\Setup\RunImage\Client\ReportTemplates\Client Ageing.rtm; DestDir: {app}\ReportTemplates\
Source: RunImage\Client\System32\BlueSkyFrog.dll; DestDir: {sys}; Flags: regserver
Source: RunImage\Server\RADVET.GDB; DestDir: {app}\Server
Source: C:\Harmony\Setup\RunImage\Server\RADVETEMPTY.GDB; DestDir: {app}\Server
Source: RunImage\Server\Backup.bat; DestDir: {app}\Server
Source: RunImage\Server\Mend.bat; DestDir: {app}\Server
Source: RunImage\Server\DataUtils.exe; DestDir: {app}\Server
Source: RunImage\Client\VersionHistory.rtf; DestDir: {app}
Source: RunImage\Client\RADQuery.exe; DestDir: {app}

[Dirs]
Name: {app}\DocumentTemplates
Name: {app}\ImageTemplates
Name: {app}\Server
Name: {app}\ReportTemplates

[Setup]
MinVersion=0,4.0.1381sp5
AppCopyright=Copyright 2003 Rinos Software
AppName=RADVet
AppVerName=RADVet 1.5 Beta 4
DefaultDirName={pf}\RADVet
AppID={9FF67546-1399-4A67-BE3B-F0962A23E12A}
OutputBaseFilename=RADVetSetup
WizardImageFile=C:\images\wizards\WizModernImage10.bmp
WizardSmallImageFile=C:\Harmony\Setup\Logo.bmp
InfoAfterFile=C:\Harmony\Setup\RunImage\Client\VersionHistory.rtf
DefaultGroupName=RADVet
DiskSpanning=false
OutputDir=C:\Harmony\Setup\Output

[Icons]
Name: {group}\RADVet; Filename: {app}\RADVet.exe; IconFilename: {app}\RADVet.exe; Comment: RADVet; IconIndex: 0; Flags: createonlyiffileexists
Name: {group}\Data Utilities; Filename: {app}\Server\DataUtils.exe; Comment: Database Utilities; IconIndex: 0
Name: {group}\Server Info; Filename: {app}\RADServers.exe; Comment: Server Info; IconIndex: 0
Name: {group}\RADDoc Editor; Filename: {app}\RADDoc.exe; Comment: Document Editor; IconIndex: 0
Name: {group}\RADQuery; Filename: {app}\RADQuery.exe; Comment: Query Editor; IconIndex: 0
Name: {group}\RADVet Help; Filename: {app}\RADVetHelp.chm; Comment: RADVet Help
Name: {group}\Database Backup; Filename: {app}\Server\Backup.bat; WorkingDir: {app}\Server; IconFilename: {app}\RADVet.exe; IconIndex: 0
Name: {group}\Database Mend; Filename: {app}\Server\Mend.bat; Parameters: > mendlog.txt; WorkingDir: {app}\Server; IconFilename: {app}\RADVet.exe; IconIndex: 0

[INI]
Filename: {commonappdata}\radvetsettings.ini; Section: Software\RADN Technology\RADVet\; Key: DatabasePath; String: 127.0.0.1:{app}\Server\RADVET.gdb

[Registry]
Root: HKCR; SubKey: .rvf; ValueType: string; ValueData: RADVet Document; Flags: uninsdeletekey
Root: HKCR; SubKey: RADVet Document; ValueType: string; ValueData: RADVet Document; Flags: uninsdeletekey
Root: HKCR; SubKey: RADVet Document\Shell\Open\Command; ValueType: string; ValueData: """{app}\RADDoc.exe"" ""%1"""; Flags: uninsdeletevalue
Root: HKCR; Subkey: RADVet Document\DefaultIcon; ValueType: string; ValueData: {app}\RADDoc.exe,0; Flags: uninsdeletevalue
