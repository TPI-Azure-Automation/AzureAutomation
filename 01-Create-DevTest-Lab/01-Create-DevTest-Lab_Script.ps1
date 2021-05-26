###################################################################################################################################################
# Purpose : This script allows you to create a new DevTest Lab in the region you want, with the name you want and in the resource group you want
# Creation date: 26.05.2021
# Version: 1.0
# Author: Arnaud Kolly / KollyA05@studentfr.ch
###################################################################################################################################################

#Variable for the creation of the devtest lab
$name = ''
$regionChoose = ''
$resourceGroup = ''

#Variable to show the user the correct regions
$locationNE = 'North Europe'
$locationWE = 'West Europe'
$locationSN = 'Switzerland North'
$locationSW = 'Switzerland West'

#Display of possibilities to the user 
Write-Host "1 : "$locationNE
Write-Host "2 : "$locationWE
Write-Host "3 : "$locationSN
Write-Host "4 : "$locationSW

#Variable to test if one of the switch responses has been chosen.
$ok = $true;

#Array for all region possibility
$possibilityArray = 1..4

#Loop as long as $ok is not equal to false. If $ok is equal to false, it means that one of the answers has been chosen and so we go to the next step
While($ok){
    #Reading the number entered by the user
    $locationRead = Read-Host 'Choose a location (1- 4)'
    #Check if $locationRead value is in $possibilityArray
    if($locationRead -in $possibilityArray){
        #Change of value in the variable $ok
        $ok = $false
    }
}
#Verification of the return number and correspondence with the values imposed by Azure. If the number is not in the list, we start the while loop again
switch ($locationRead)
 {
     '1' {
         #Change of value in the variable $regionChoose
         $regionChoose = "northeurope"
		 break
     } '2' {
         #Change of value in the variable $regionChoose
         $regionChoose = "westeurope"
		 break
     } '3' {
         #Change of value in the variable $regionChoose
         $regionChoose = "switzerlandnorth"
		 break
     } '4' {
         #Change of value in the variable $regionChoose
         $regionChoose = "switzerlandwest"
		 break
     }
 }

#Reading the name entered by the user and store in $name
$name = Read-Host 'Enter the name of the new lab'

#Reading the resource group entered by the user and store in $name
$resourceGroup = Read-Host 'Enter the name of the resources group'

#Connect Azure Account
Connect-AzAccount

#Create a new lab with the 3 parameters
New-AzResourceGroupDeployment -ResourceGroupName $resourceGroup -TemplateFile .\01-Create-DevTest-Lab_Template.json -regionId $regionChoose -nameFromTemplate $name

#Notification to the user that the DevTest Lab has been created 
Write-Host 'Vous venez de créer le lab '$name' dans la region '$regionChoose' le tout dans le resource group '$resourceGroup' !'
pause