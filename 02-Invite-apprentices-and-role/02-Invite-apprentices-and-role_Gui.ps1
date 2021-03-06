############################################################################################################################
# Purpose : This script allows you to invite apprentices by email and give them permission to use the DevTest Lab you want.
# Creation date: 01.06.2021
# Version: 1.0
# Author: Arnaud Kolly / KollyA05@studentfr.ch
############################################################################################################################

#Generated Form Function
function GenerateForm {

#region Import the Assemblies
[reflection.assembly]::loadwithpartialname("System.Drawing") | Out-Null
[reflection.assembly]::loadwithpartialname("System.Windows.Forms") | Out-Null
#endregion

#region Generated Form Objects
$form1 = New-Object System.Windows.Forms.Form
$labelProcess = New-Object System.Windows.Forms.Label
$buttonCreate = New-Object System.Windows.Forms.Button
$richTextBoxMessage = New-Object System.Windows.Forms.RichTextBox
$label6 = New-Object System.Windows.Forms.Label
$label5 = New-Object System.Windows.Forms.Label
$radioButtonNo = New-Object System.Windows.Forms.RadioButton
$radioButtonYes = New-Object System.Windows.Forms.RadioButton
$comboBoxLab = New-Object System.Windows.Forms.ComboBox
$label4 = New-Object System.Windows.Forms.Label
$comboBoxClass = New-Object System.Windows.Forms.ComboBox
$label3 = New-Object System.Windows.Forms.Label
$label2 = New-Object System.Windows.Forms.Label
$label1 = New-Object System.Windows.Forms.Label
$InitialFormWindowState = New-Object System.Windows.Forms.FormWindowState
#endregion Generated Form Objects

#Connect Az Account
Connect-AzAccount
#Connect AzureAD Account
Connect-AzureAD -TenantId "34bb6ca0-854e-4d46-96fa-204df387d876"
 
#Variables for inviting apprentices and giving them permissions
$messageInfo = New-Object Microsoft.Open.MSGraph.Model.InvitedUserMessageInfo
$message = ''
$sendMessage = $True
$numClasse = ''
$nameClasse = ''
$subscriptionId = '9d1efdf8-d1b9-4e6b-be5e-c41b4fc12361'
$labResourceGroup = ''
$labName = ''

#Fill in $comboboxClass with the class numbers
$num = @('300211','300212', '300213', '300221', '300222', '300223', '300231', '300232', '300233', '300241', '300242', '300243')
$comboBoxClass.Items.AddRange($num)

#Fill in $comboBoxLab with the names of the labs
$lab = (Get-AzResource -ResourceType Microsoft.DevTestLab/labs).Name
$comboBoxLab.Items.AddRange($lab)

#Default selected value
$radioButtonYes.Checked =  $True

#Default combo box class value
$comboBoxClass.SelectedIndex = 0

#Default combo box lab value
$comboBoxLab.SelectedIndex = 0

#----------------------------------------------
#Generated Event Script Blocks
#----------------------------------------------
#Provide Custom Code for events specified in PrimalForms.
$buttonCreate_OnClick= 
{
	#Get information from form1
    $numClasse = $comboBoxClass.SelectedItem
    $nameClasse = 'EMF Students CL EMF_'+$numClasse
    $labName = $comboBoxLab.SelectedItem
    $labResourceGroup = $labName

	#Check if the radioButtonYes is checked
    if($radioButtonYes.Checked){
	        #Reading the text entered by the user and store in $message
	        $message = $richTextBoxMessage.Text
	        #Check if $message value isn't "" or null
	        if(-not [string]::IsNullOrEmpty($message)){
                 #Change of value in the variable $sendMessage
                 $sendMessage = $True
				 #Call function StartProcess
                 StartProcess
            }else{
				 #Pop-up information for enter a message	
                 $wshell.Popup("Please enter a message in the text box",0,"02-Invite-apprentices-and-role_Gui",48+0)
            }
    }elseif ($radioButtonNo.Checked){
		#Change of value in the variable $sendMessage
        $sendMessage = $False
		#Call function StartProcess
        StartProcess
    }	
}

#Function to start the process for create users and roles
Function StartProcess{
	#Change value of the labelProcess and disable button create
    $labelProcess.Text = "Creation and permissions are in progress..."
	$buttonCreate.Enabled = $false

    #Start the Search-GAL function and send invitations
    Search-GAL $nameClasse
	
	#Change value of the labelProcess and enable button create
    $labelProcess.Text = ""
	$buttonCreate.Enabled = $true

	#Pop-up completed task for the user
    $wshell.Popup("The creation of the users and permissions is completed.",0,"02-Invite-apprentices-and-role_Gui",64+0)
}

#Function to retrieve the email addresses of the trainees in the class, send them an invitation and give them permissions
Function Search-GAL {
	
	#Definition of parameters
	param (
		[string]$searchString
	)
	
	#Creating the object for the link with the Outlook application
	$ol = New-Object -ComObject Outlook.Application
	
	#Search for a class in outlook
	$dl = $ol.Session.GetGlobalAddressList().AddressEntries.Item($searchString)
	
	#Getting the members of a class
	$members = $dl.members
	
	#Executing actions for each member of a class
	foreach($member in $members)
		{
			#Getting user
			$user = $member.GetExchangeUser()

			#Displaying the user's Email Address on the Console
			write-host ($user.PrimarySMTPAddress)

			#Define the message that will be included in the invitation
			$messageInfo.customizedMessageBody = $message

			#Creation of the user in AzureAD and sending of an invitation by email
			New-AzureADMSInvitation -InvitedUserEmailAddress $user.PrimarySMTPAddress -SendInvitationMessage $sendMessage -InviteRedirectUrl "https://portal.azure.com" -InvitedUserMessageInfo $messageInfo -Verbose	

			#Variable to test if the user id isn't "" or null
			$okAdd = $true
			
            #Loop as long as $okAdd is not equal to false. If $okAdd is equal to false, it means that the user id isn't null or empty and so we go to the next step
			While($okAdd){
                #Get the user created using his email address
			    $adObject = Get-AzADUser -Mail $user.PrimarySMTPAddress
				#Check if $adObject value isn't "" or null
				if($adObject -ne $null){
					#Change of value in the variable $okAdd
					$okAdd = $false
				}
			}

			#Defining the path to the laboratory 
			$labId = ('/subscriptions/' + $subscriptionId + '/resourceGroups/' + $labResourceGroup + '/providers/Microsoft.DevTestLab/labs/' + $labName)

			#Add the DevTest Labs User permission to the selected lab
			New-AzRoleAssignment -ObjectId $adObject.Id -RoleDefinitionName 'DevTest Labs User' -Scope $labId -Verbose
		}
}

$OnLoadForm_StateCorrection=
{#Correct the initial state of the form to prevent the .Net maximized form issue
	$form1.WindowState = $InitialFormWindowState
}

#----------------------------------------------
#region Generated Form Code
$System_Drawing_Size = New-Object System.Drawing.Size
$System_Drawing_Size.Height = 454
$System_Drawing_Size.Width = 631
$form1.ClientSize = $System_Drawing_Size
$form1.DataBindings.DefaultDataSourceUpdateMode = 0
$form1.Name = "form1"
$form1.Text = "02-Invite-apprentices-and-role"

$labelProcess.DataBindings.DefaultDataSourceUpdateMode = 0

$System_Drawing_Point = New-Object System.Drawing.Point
$System_Drawing_Point.X = 459
$System_Drawing_Point.Y = 382
$labelProcess.Location = $System_Drawing_Point
$labelProcess.Name = "labelProcess"
$System_Drawing_Size = New-Object System.Drawing.Size
$System_Drawing_Size.Height = 33
$System_Drawing_Size.Width = 147
$labelProcess.Size = $System_Drawing_Size
$labelProcess.TabIndex = 12
$labelProcess.TextAlign = 32

$form1.Controls.Add($labelProcess)


$buttonCreate.DataBindings.DefaultDataSourceUpdateMode = 0
$buttonCreate.Font = New-Object System.Drawing.Font("Microsoft Sans Serif",9.75,0,3,1)

$System_Drawing_Point = New-Object System.Drawing.Point
$System_Drawing_Point.X = 209
$System_Drawing_Point.Y = 380
$buttonCreate.Location = $System_Drawing_Point
$buttonCreate.Name = "buttonCreate"
$System_Drawing_Size = New-Object System.Drawing.Size
$System_Drawing_Size.Height = 38
$System_Drawing_Size.Width = 209
$buttonCreate.Size = $System_Drawing_Size
$buttonCreate.TabIndex = 11
$buttonCreate.Text = "Create apprentices and role"
$buttonCreate.UseVisualStyleBackColor = $True
$buttonCreate.add_Click($buttonCreate_OnClick)

$form1.Controls.Add($buttonCreate)

$richTextBoxMessage.DataBindings.DefaultDataSourceUpdateMode = 0
$System_Drawing_Point = New-Object System.Drawing.Point
$System_Drawing_Point.X = 278
$System_Drawing_Point.Y = 221
$richTextBoxMessage.Location = $System_Drawing_Point
$richTextBoxMessage.Name = "richTextBoxMessage"
$System_Drawing_Size = New-Object System.Drawing.Size
$System_Drawing_Size.Height = 115
$System_Drawing_Size.Width = 248
$richTextBoxMessage.Size = $System_Drawing_Size
$richTextBoxMessage.TabIndex = 10
$richTextBoxMessage.Text = "Bonjour, voici votre accès au laboratoire Azure pour votre prochain module."

$form1.Controls.Add($richTextBoxMessage)

$label6.DataBindings.DefaultDataSourceUpdateMode = 0

$System_Drawing_Point = New-Object System.Drawing.Point
$System_Drawing_Point.X = 70
$System_Drawing_Point.Y = 262
$label6.Location = $System_Drawing_Point
$label6.Name = "label6"
$System_Drawing_Size = New-Object System.Drawing.Size
$System_Drawing_Size.Height = 23
$System_Drawing_Size.Width = 164
$label6.Size = $System_Drawing_Size
$label6.TabIndex = 9
$label6.Text = "Custom your e-mail message :"

$form1.Controls.Add($label6)

$label5.DataBindings.DefaultDataSourceUpdateMode = 0

$System_Drawing_Point = New-Object System.Drawing.Point
$System_Drawing_Point.X = 70
$System_Drawing_Point.Y = 179
$label5.Location = $System_Drawing_Point
$label5.Name = "label5"
$System_Drawing_Size = New-Object System.Drawing.Size
$System_Drawing_Size.Height = 21
$System_Drawing_Size.Width = 163
$label5.Size = $System_Drawing_Size
$label5.TabIndex = 8
$label5.Text = "Send e-mail invitation ?"
$label5.TextAlign = 32

$form1.Controls.Add($label5)


$radioButtonNo.DataBindings.DefaultDataSourceUpdateMode = 0

$System_Drawing_Point = New-Object System.Drawing.Point
$System_Drawing_Point.X = 327
$System_Drawing_Point.Y = 177
$radioButtonNo.Location = $System_Drawing_Point
$radioButtonNo.Name = "radioButtonNo"
$System_Drawing_Size = New-Object System.Drawing.Size
$System_Drawing_Size.Height = 24
$System_Drawing_Size.Width = 40
$radioButtonNo.Size = $System_Drawing_Size
$radioButtonNo.TabIndex = 7
$radioButtonNo.TabStop = $True
$radioButtonNo.Text = "No"
$radioButtonNo.UseVisualStyleBackColor = $True

$form1.Controls.Add($radioButtonNo)


$radioButtonYes.DataBindings.DefaultDataSourceUpdateMode = 0

$System_Drawing_Point = New-Object System.Drawing.Point
$System_Drawing_Point.X = 433
$System_Drawing_Point.Y = 177
$radioButtonYes.Location = $System_Drawing_Point
$radioButtonYes.Name = "radioButtonYes"
$System_Drawing_Size = New-Object System.Drawing.Size
$System_Drawing_Size.Height = 24
$System_Drawing_Size.Width = 51
$radioButtonYes.Size = $System_Drawing_Size
$radioButtonYes.TabIndex = 6
$radioButtonYes.TabStop = $True
$radioButtonYes.Text = "Yes"
$radioButtonYes.UseVisualStyleBackColor = $True

$form1.Controls.Add($radioButtonYes)

$comboBoxLab.DataBindings.DefaultDataSourceUpdateMode = 0
$comboBoxLab.FormattingEnabled = $True
$System_Drawing_Point = New-Object System.Drawing.Point
$System_Drawing_Point.X = 278
$System_Drawing_Point.Y = 137
$comboBoxLab.Location = $System_Drawing_Point
$comboBoxLab.Name = "comboBoxLab"
$System_Drawing_Size = New-Object System.Drawing.Size
$System_Drawing_Size.Height = 21
$System_Drawing_Size.Width = 248
$comboBoxLab.Size = $System_Drawing_Size
$comboBoxLab.TabIndex = 5

$form1.Controls.Add($comboBoxLab)

$label4.DataBindings.DefaultDataSourceUpdateMode = 0

$System_Drawing_Point = New-Object System.Drawing.Point
$System_Drawing_Point.X = 70
$System_Drawing_Point.Y = 135
$label4.Location = $System_Drawing_Point
$label4.Name = "label4"
$System_Drawing_Size = New-Object System.Drawing.Size
$System_Drawing_Size.Height = 23
$System_Drawing_Size.Width = 164
$label4.Size = $System_Drawing_Size
$label4.TabIndex = 4
$label4.Text = "Select your DevTest Lab :"
$label4.TextAlign = 32

$form1.Controls.Add($label4)

$comboBoxClass.DataBindings.DefaultDataSourceUpdateMode = 0
$comboBoxClass.FormattingEnabled = $True
$System_Drawing_Point = New-Object System.Drawing.Point
$System_Drawing_Point.X = 278
$System_Drawing_Point.Y = 96
$comboBoxClass.Location = $System_Drawing_Point
$comboBoxClass.Name = "comboBoxClass"
$System_Drawing_Size = New-Object System.Drawing.Size
$System_Drawing_Size.Height = 21
$System_Drawing_Size.Width = 248
$comboBoxClass.Size = $System_Drawing_Size
$comboBoxClass.TabIndex = 3

$form1.Controls.Add($comboBoxClass)

$label3.DataBindings.DefaultDataSourceUpdateMode = 0

$System_Drawing_Point = New-Object System.Drawing.Point
$System_Drawing_Point.X = 70
$System_Drawing_Point.Y = 95
$label3.Location = $System_Drawing_Point
$label3.Name = "label3"
$System_Drawing_Size = New-Object System.Drawing.Size
$System_Drawing_Size.Height = 21
$System_Drawing_Size.Width = 164
$label3.Size = $System_Drawing_Size
$label3.TabIndex = 2
$label3.Text = "Select your class number :"
$label3.TextAlign = 32

$form1.Controls.Add($label3)

$label2.DataBindings.DefaultDataSourceUpdateMode = 0

$System_Drawing_Point = New-Object System.Drawing.Point
$System_Drawing_Point.X = 418
$System_Drawing_Point.Y = 44
$label2.Location = $System_Drawing_Point
$label2.Name = "label2"
$System_Drawing_Size = New-Object System.Drawing.Size
$System_Drawing_Size.Height = 14
$System_Drawing_Size.Width = 139
$label2.Size = $System_Drawing_Size
$label2.TabIndex = 1
$label2.Text = "Version 1.0 Arnaud Kolly"
$label2.TextAlign = 32

$form1.Controls.Add($label2)

$label1.DataBindings.DefaultDataSourceUpdateMode = 0
$label1.Font = New-Object System.Drawing.Font("Microsoft Sans Serif",21.75,0,3,1)

$System_Drawing_Point = New-Object System.Drawing.Point
$System_Drawing_Point.X = 41
$System_Drawing_Point.Y = 26
$label1.Location = $System_Drawing_Point
$label1.Name = "label1"
$System_Drawing_Size = New-Object System.Drawing.Size
$System_Drawing_Size.Height = 39
$System_Drawing_Size.Width = 377
$label1.Size = $System_Drawing_Size
$label1.TabIndex = 0
$label1.Text = "Add apprentices and role"
$label1.TextAlign = 32

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
#Install AzureAD module
Install-Module -Name AzureAD -Verbose

#Change folder to script path
cd $path

#Pop-up information for the user
$wshell.Popup("If you have any errors in the following script, close it and reboot your machine to apply the installation of the modules",0,"01-DevTest-Lab_Gui",64+0)

#Call the Function
GenerateForm
