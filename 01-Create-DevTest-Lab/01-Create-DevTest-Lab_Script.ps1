###################################################################################################################################################
# Purpose : This script allows you to create a new DevTest Lab in the region you want, with the name you want and in the resource group you want
# Creation date: 26.05.2021
# Version: 1.0
# Author: Arnaud Kolly / KollyA05@studentfr.ch
###################################################################################################################################################

#Variable for the creation of the devtest lab
[string]$name = ''
[string]$regionChoose = ''
$jsonPath = ".\01-Create-DevTest-Lab_Template.json"

#Variable to show the user the correct regions
$locationNE = 'North Europe'
$locationWE = 'West Europe'
$locationSN = 'Switzerland North'

#Display of possibilities to the user 
Write-Host "1 : "$locationNE
Write-Host "2 : "$locationWE
Write-Host "3 : "$locationSN

#Variable to test if one of the switch responses has been chosen.
$okLocation = $true;

#Array for all region possibility
$possibilityArray = 1..3

#Loop as long as $okLocation is not equal to false. If $okLocation is equal to false, it means that one of the answers has been chosen and so we go to the next step
While($okLocation){
    #Reading the number entered by the user
    $locationRead = Read-Host 'Choose a location (1- 3)'
    #Check if $locationRead value is in $possibilityArray
    if($locationRead -in $possibilityArray){
        #Change of value in the variable $okLocation
        $okLocation = $false
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
     }
 }

#Variable to test if one of the name isn't "" or null.
$okName = $true;

#Loop as long as $okName is not equal to false. If $okName is equal to false, it means that one of the answers has been chosen and so we go to the next step
While($okName){
    #Reading the name entered by the user and store in $name
    $name = Read-Host 'Enter the name of the new lab (ex. 159-GRE-300222)'
    #Check if $name value isn't "" or null
    if(-not [string]::IsNullOrEmpty($name)){
        if($name -cmatch "[0-9]{3}-[A-Z]{3}-[0-9]{6}"){
        #Change of value in the variable $okName
        $okName = $false
        }
    }
}

#Test if the json file is in the same folder then the script
if(Test-Path -Path $jsonPath){

            #Connect Azure Account
            Connect-AzAccount

            #Create a new resource group with the same name and location then the lab
            New-AzResourceGroup -Name $name -Location $regionChoose

            #Create a new lab with the 3 parameters
            New-AzResourceGroupDeployment -ResourceGroupName $name -TemplateFile $jsonPath -regionId $regionChoose -nameFromTemplate $name
   
            #Notification to the user that the DevTest Lab has been created 
            Write-Host 'You have just created the lab '$name' in the region '$regionChoose' all in the resource group '$name' !'

   }else{

     #Notification to the user that the json file is not at the same folder then the script 
     Write-Host 'Please copy the json file to the same folder as the script and run the script again'

    }



pause