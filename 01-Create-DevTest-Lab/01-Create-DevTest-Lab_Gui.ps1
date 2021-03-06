####################################################################################################################################################
# Purpose : This script allows you to create a new DevTest Lab in the region you want, with the name you want and in the resource group you want.
# Creation date: 28.05.2021
# Version: 1.0
# Author: Arnaud Kolly / KollyA05@studentfr.ch
####################################################################################################################################################

#Generated Form Function
function GenerateForm {

#region Import the Assemblies
[reflection.assembly]::loadwithpartialname("System.Drawing") | Out-Null
[reflection.assembly]::loadwithpartialname("System.Windows.Forms") | Out-Null
#endregion

#region Generated Form Objects
$form1 = New-Object System.Windows.Forms.Form
$label3Progress = New-Object System.Windows.Forms.Label
$button1Create = New-Object System.Windows.Forms.Button
$textBoxName = New-Object System.Windows.Forms.TextBox
$labelName = New-Object System.Windows.Forms.Label
$labelLocation = New-Object System.Windows.Forms.Label
$comboBoxLocation = New-Object System.Windows.Forms.ComboBox
$label2 = New-Object System.Windows.Forms.Label
$label1 = New-Object System.Windows.Forms.Label
$InitialFormWindowState = New-Object System.Windows.Forms.FormWindowState
#endregion Generated Form Objects

#Variable for the creation of the devtest lab
[string]$name = ''
[string]$regionChoose = ''
$jsonPath = ".\01-Create-DevTest-Lab_Template.json"

#Connect Azure Account
Connect-AzAccount

#Add value in the combobox
$regions = @('North Europe','West Europe','Switzerland North')
$comboBoxLocation.Items.AddRange($regions)

#----------------------------------------------
#Generated Event Script Blocks
#----------------------------------------------
#Provide Custom Code for events specified in PrimalForms.

$button1Create_OnClick= 
{
#Get information from form1
$regionChoose = $comboBoxLocation.Text.Replace(' ','').ToLower()
$name = $textBoxName.Text

    #Check if the json file is in the same folder then the script
	if(Test-Path -Path $jsonPath){
        #Check if $name respect the pattern
		if($name -cmatch "[0-9]{3}-[A-Z]{3}-[0-9]{6}"){
            #Change value of the label3 and disable button create
			$label3Progress.Text = "Creation is in progress..."
			$button1Create.Enabled = $false
            #Create a new resource group with the 2 parameters
			New-AzResourceGroup -Name $name -Location $regionChoose
			#Create a new lab with the 3 parameters
			New-AzResourceGroupDeployment -ResourceGroupName $name -TemplateFile $JsonPath -regionId $regionChoose -nameFromTemplate $name -Verbose
            #Change value of the label3 and enable button create
			$label3Progress.Text = ""
			$button1Create.Enabled = $true
            #Pop-up completed task for the user
			$wshell.Popup("The creation of the lab is completed.",0,"01-DevTest-Lab_Gui",64+0)
		}else{
        #Pop-up for enter a correct name
        $wshell.Popup("Please enter a correct name (ex. 159-GRE-300222)",0,"01-DevTest-Lab_Gui",48+0)
		}
	}else{
    #Pop-up for copy the json file in the correct forlder
    $wshell.Popup("Please copy the json file to the same folder as the script",0,"01-DevTest-Lab_Gui",48+0)
	}
}

$OnLoadForm_StateCorrection=
{#Correct the initial state of the form to prevent the .Net maximized form issue
	$form1.WindowState = $InitialFormWindowState
}

#----------------------------------------------
#region Generated Form Code
$System_Drawing_Size = New-Object System.Drawing.Size
$System_Drawing_Size.Height = 267
$System_Drawing_Size.Width = 625
$form1.ClientSize = $System_Drawing_Size
$form1.DataBindings.DefaultDataSourceUpdateMode = 0
$form1.Name = "form1"
$form1.Text = "01-Create-DevTest-Lab_Gui"

$label3Progress.DataBindings.DefaultDataSourceUpdateMode = 0

$System_Drawing_Point = New-Object System.Drawing.Point
$System_Drawing_Point.X = 423
$System_Drawing_Point.Y = 215
$label3Progress.Location = $System_Drawing_Point
$label3Progress.Name = "label3Progress"
$System_Drawing_Size = New-Object System.Drawing.Size
$System_Drawing_Size.Height = 29
$System_Drawing_Size.Width = 132
$label3Progress.Size = $System_Drawing_Size
$label3Progress.TabIndex = 9
$label3Progress.TextAlign = 32

$form1.Controls.Add($label3Progress)


$button1Create.DataBindings.DefaultDataSourceUpdateMode = 0
$button1Create.Font = New-Object System.Drawing.Font("Microsoft Sans Serif",9.75,0,3,1)

$System_Drawing_Point = New-Object System.Drawing.Point
$System_Drawing_Point.X = 213
$System_Drawing_Point.Y = 209
$button1Create.Location = $System_Drawing_Point
$button1Create.Name = "button1Create"
$System_Drawing_Size = New-Object System.Drawing.Size
$System_Drawing_Size.Height = 40
$System_Drawing_Size.Width = 156
$button1Create.Size = $System_Drawing_Size
$button1Create.TabIndex = 8
$button1Create.Text = "Create the new Lab"
$button1Create.UseVisualStyleBackColor = $True
$button1Create.add_Click($button1Create_OnClick)

$form1.Controls.Add($button1Create)

$textBoxName.DataBindings.DefaultDataSourceUpdateMode = 0
$System_Drawing_Point = New-Object System.Drawing.Point
$System_Drawing_Point.X = 353
$System_Drawing_Point.Y = 141
$textBoxName.Location = $System_Drawing_Point
$textBoxName.Name = "textBoxName"
$System_Drawing_Size = New-Object System.Drawing.Size
$System_Drawing_Size.Height = 20
$System_Drawing_Size.Width = 170
$textBoxName.Size = $System_Drawing_Size
$textBoxName.TabIndex = 7

$form1.Controls.Add($textBoxName)

$labelName.DataBindings.DefaultDataSourceUpdateMode = 0

$System_Drawing_Point = New-Object System.Drawing.Point
$System_Drawing_Point.X = 30
$System_Drawing_Point.Y = 144
$labelName.Location = $System_Drawing_Point
$labelName.Name = "labelName"
$System_Drawing_Size = New-Object System.Drawing.Size
$System_Drawing_Size.Height = 18
$System_Drawing_Size.Width = 317
$labelName.Size = $System_Drawing_Size
$labelName.TabIndex = 6
$labelName.Text = "Type the name for your Lab (Ex. 159-GRE-300222) :"
$labelName.TextAlign = 32

$form1.Controls.Add($labelName)

$labelLocation.DataBindings.DefaultDataSourceUpdateMode = 0

$System_Drawing_Point = New-Object System.Drawing.Point
$System_Drawing_Point.X = 30
$System_Drawing_Point.Y = 108
$labelLocation.Location = $System_Drawing_Point
$labelLocation.Name = "labelLocation"
$System_Drawing_Size = New-Object System.Drawing.Size
$System_Drawing_Size.Height = 21
$System_Drawing_Size.Width = 317
$labelLocation.Size = $System_Drawing_Size
$labelLocation.TabIndex = 3
$labelLocation.Text = "Choose the region for your Lab :"
$labelLocation.TextAlign = 32
$labelLocation.add_Click($handler_label3_Click)

$form1.Controls.Add($labelLocation)

$comboBoxLocation.DataBindings.DefaultDataSourceUpdateMode = 0
$comboBoxLocation.FormattingEnabled = $True
$System_Drawing_Point = New-Object System.Drawing.Point
$System_Drawing_Point.X = 353
$System_Drawing_Point.Y = 109
$comboBoxLocation.Location = $System_Drawing_Point
$comboBoxLocation.Name = "comboBoxLocation"
$System_Drawing_Size = New-Object System.Drawing.Size
$System_Drawing_Size.Height = 21
$System_Drawing_Size.Width = 170
$comboBoxLocation.Size = $System_Drawing_Size
$comboBoxLocation.TabIndex = 2

$form1.Controls.Add($comboBoxLocation)

$label2.DataBindings.DefaultDataSourceUpdateMode = 0
$label2.Font = New-Object System.Drawing.Font("Microsoft Sans Serif",8.25,0,3,1)

$System_Drawing_Point = New-Object System.Drawing.Point
$System_Drawing_Point.X = 400
$System_Drawing_Point.Y = 44
$label2.Location = $System_Drawing_Point
$label2.Name = "label2"
$System_Drawing_Size = New-Object System.Drawing.Size
$System_Drawing_Size.Height = 15
$System_Drawing_Size.Width = 155
$label2.Size = $System_Drawing_Size
$label2.TabIndex = 1
$label2.Text = "Version 1.0 Arnaud Kolly"

$form1.Controls.Add($label2)

$label1.DataBindings.DefaultDataSourceUpdateMode = 0
$label1.Font = New-Object System.Drawing.Font("Microsoft Sans Serif",21.75,0,3,1)

$System_Drawing_Point = New-Object System.Drawing.Point
$System_Drawing_Point.X = 30
$System_Drawing_Point.Y = 25
$label1.Location = $System_Drawing_Point
$label1.Name = "label1"
$System_Drawing_Size = New-Object System.Drawing.Size
$System_Drawing_Size.Height = 34
$System_Drawing_Size.Width = 364
$label1.Size = $System_Drawing_Size
$label1.TabIndex = 0
$label1.Text = "Create a new DevTest Lab"
$label1.add_Click($handler_label1_Click)

$form1.Controls.Add($label1)

#endregion Generated Form Code

#Save the initial state of the form
$InitialFormWindowState = $form1.WindowState
#Init the OnLoad event to correct the initial state of the form
$form1.add_Load($OnLoadForm_StateCorrection)
#Show the Form
$form1.ShowDialog()| Out-Null

} #End Function

#Initial variable for pop-up
$wshell = New-Object -comObject Wscript.Shell

#Information for the user
Write-Host "Installation of modules"

#Get script path
$path = Split-Path -Parent -Path $MyInvocation.MyCommand.Definition

#Run PowerShell as admin
Function is-admin ()
{
    $user = [security.principal.windowsidentity]::getcurrent()
    $role = new-object security.principal.windowsprincipal $user
    $role.isinrole( [security.principal.windowsbuiltinrole]::administrator )
}
 
if (!(is-admin))
{
    $args = $myinvocation.mycommand.definition
    start-process powershell -argumentlist $args -verb 'runas'
    exit
}

#Change security protocole
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
#Install NuGet package
Install-PackageProvider -Name NuGet -Force -Verbose
#Install Az module
Install-Module -Name Az -Verbose

#Change folder to script path
cd $path

#Pop-up information for the user
$wshell.Popup("If you have any errors in the following script, close it and reboot your machine to apply the installation of the modules",0,"01-DevTest-Lab_Gui",64+0)

#Call the Function
GenerateForm
