############################################################################################################################
# Purpose : This script allows you to invite apprentices by email and give them permission to use the DevTest Lab you want.
# Creation date: 31.05.2021
# Version: 1.0
# Author: Arnaud Kolly / KollyA05@studentfr.ch
############################################################################################################################

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

#Information for the user
Write-Host "If you have any errors in the following script, close it and reboot your machine to apply the installation of the modules."

#Confirmation that the user as read the information
pause

#Connect Az Account
Connect-AzAccount
#Connect AzureAD Account
Connect-AzureAD -TenantId "34bb6ca0-854e-4d46-96fa-204df387d876"
 
#Variables for inviting apprentices and giving them permissions
$messageInfo = New-Object Microsoft.Open.MSGraph.Model.InvitedUserMessageInfo
$message = ''
$numClasse = ''
$nameClasse = ''
$subscriptionId = '9d1efdf8-d1b9-4e6b-be5e-c41b4fc12361'
$labResourceGroup = ''
$labName = ''

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
			New-AzureADMSInvitation -InvitedUserEmailAddress $user.PrimarySMTPAddress -SendInvitationMessage $False -InviteRedirectUrl "https://portal.azure.com" -InvitedUserMessageInfo $messageInfo -Verbose	

			#Variable to test if the user id isn't "" or null
			$okAdd = $true
			
            #Loop as long as $okAdd is not equal to false. If $okAdd is equal to false, it means that the user id isn't null or empty and so we go to the next step
			While($okAdd){
                #Get the user created using his email address
			    $adObject = Get-AzADUser -Mail $user.PrimarySMTPAddress
                write-host "adObject "+$adObject
				#Check if $adObject value isn't "" or null
				if($adObject -ne $null){
                    write-host "adObject plein "+$adObject
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

#Variable to test if the number of the class isn't "" or null and for check if it's a number
$okNumClasse = $true

#Loop as long as $okNumClasse is not equal to false. If $okNumClasse is equal to false, it means that the number of class is ok and so we go to the next step
While($okNumClasse){
	#Reading the number entered by the user and store in $numClasse
	$numClasse = Read-Host 'Entrer le numero de la classe (ex. 300241)'
	#Check if $numClasse value isn't "" or null
	if(-not [string]::IsNullOrEmpty($numClasse)){
		#Check if $numClasse is a 6-digit sequence
		if($numClasse -cmatch "[0-9]{6}"){
			#Change the value of $nameClasse with the $numClasse
			$nameClasse = 'EMF Students CL EMF_'+$numClasse
			#Change of value in the variable $okNumClasse
			$okNumClasse = $false
		}
	}
}

#Variable to test if the text of the class isn't "" or null
$okMessage = $true

#Loop as long as $okMessage is not equal to false. If $okMessage is equal to false, it means that the text is ok and so we go to the next step
While($okMessage){
	#Reading the text entered by the user and store in $message
	$message = Read-Host "Entrer le message d'invitation"
	#Check if $message value isn't "" or null
	if(-not [string]::IsNullOrEmpty($message)){
        #Change of value in the variable $okMessage
        $okMessage = $false
        }
}

#Variable to test if the text of the class isn't "" or null
$okLabName = $true

#Loop as long as $okLabName is not equal to false. If $okLabName is equal to false, it means that the text is ok and so we go to the next step
While($okLabName){
	#Reading the text entered by the user and store in $labName
	$labName = Read-Host 'Entrer le nom du laboratoire'
	#Check if $labName value isn't "" or null
	if(-not [string]::IsNullOrEmpty($labName)){
           #Check if $labName contains 3 numbers-3 capital letters-6 numbers
           if($labName -cmatch "[0-9]{3}-[A-Z]{3}-[0-9]{6}"){
		#Add the name of the lab in the variable $labResourceGroup
		$labResourceGroup += $labName
        #Change of value in the variable $okLabName
        $okLabName = $false
            }
     }
}

#Start the Search-GAL function and send invitations
Search-GAL $nameClasse

#Confirmation that the user as read the information
pause