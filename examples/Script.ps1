#updating and conneting to Online
Update-Module MicrosoftTeams
Connect-MicrosoftTeams
Connect-MsolService 

#import Queues to be configured from CSV
$Queues = import-csv -Path "c:\Users\Mads\OneDrive - zaulich\Arbejde\Scripts\Teams\CallQueue\Nameandnumbers.csv" -Delimiter ";"
#Get license overview
Get-MsolAccountSku  | ? AccountSkuId -eq "vallensbaekdk:PHONESYSTEM_VIRTUALUSER" |  Select AccountSkuId, SkuPartNumber, ActiveUnits, ConsumedUnits

#Variables
$VoicePolicy = "TDC-International"
$license = "vallensbaekdk:PHONESYSTEM_VIRTUALUSER"
$Domain = "vallensbaekdk.onmicrosoft.com"
# Your config

#Countdown function
function Start-countdown($seconds) {
    $doneDT = (Get-Date).AddSeconds($seconds)
    while ($doneDT -gt (Get-Date)) {
        $secondsLeft = $doneDT.Subtract((Get-Date)).TotalSeconds
        $percent = ($seconds - $secondsLeft) / $seconds * 100
        Write-Progress -Activity "Sleeping" -Status "Sleeping..." -SecondsRemaining $secondsLeft -PercentComplete $percent
        [System.Threading.Thread]::Sleep(500)
    }
    Write-Progress -Activity "Sleeping" -Status "Sleeping..." -SecondsRemaining 0 -Completed
}


###Create Queues
$i = 1
foreach ($queue in $Queues) {
    if($Queues.count -eq $null){
        $count = "1"
    }
    else{
        $count = $($Queues.count)
    }
    Write-Progress -Activity "Creating  Queue $($name)" -Status "Queue $i of $count" -PercentComplete (($i / $Queues.count) * 100)

    #-------------------------------------#
    #     Used for Call Queue             #
    #-------------------------------------#
    if ($queue.Type -eq "CallQueue") {        
        Write-host "Creating the Queue $($name)" -ForegroundColor Yellow

        $name = "$($queue.name)"
        if (Get-CsCallQueue | ? name -like "*$($queue.name)") {
            write-host "A Queue already exist with this name"
            continue
        }
        else {
            #-------------------------------------#
            #       Create Call Queue             #
            #-------------------------------------#
           
            New-CsCallQueue -Name $name -UseDefaultMusicOnHold $true -LanguageId da-DK  | Out-Null -ErrorAction stop -WarningAction SilentlyContinue
    
            #-------------------------------------#
            #      Create Resource Accounts       #
            #-------------------------------------#
            Write-host ".Creating the Resource Account"
            $CallQueueID = "11cd3e2e-fccb-42ad-ad00-878b93575e07" #fixed ID by Microsoft
            $name = "RA_CQ_$($queue.name)"
            $UPN = "$($name)@$($domain)"
            $UPN = $upn.Replace(' ',"")
            Write-host "..Waiting until we know that the Resource account is fully created"
            New-CsOnlineApplicationInstance -UserPrincipalName $UPN -DisplayName $Name -ApplicationId $CallQueueID -WarningAction SilentlyContinue | Out-Null 
            do {
                $applicationInstanceId = (Get-CsOnlineUser "$upn" -erroraction SilentlyContinue ).ObjectId 
            } until ($applicationInstanceId )
    
            #-------------------------------------#
            #Assign License for Resource Account  #
            #-------------------------------------#
            if ($Queue.Numbers -notlike "+45*") {
                Write-host "No Number - will not Assign license"
            }
            Else {
                Write-host ".Assigning License" 
                do {
                    $user = Get-MsolUser -UserPrincipalName $UPN -ErrorAction SilentlyContinue
                } until ($user)
                Set-MsolUser -UserPrincipalName $UPN -UsageLocation "DK"
                Set-MsolUserLicense -UserPrincipalName $upn  -AddLicenses $license 
                do {
        
                    $licensecheck = Get-MsolUser -UserPrincipalName $UPN 
                } until ($licensecheck.isLicensed -eq $true)
                write-host "..License ok"
                Start-countdown 10

                #-------------------------------------#
                #Assign Number for Resource Account  #
                #-------------------------------------#
                Write-host ".Assigning number" 
                Write-host "..This can take some time due to replication" -ForegroundColor DarkGray
                $tel = $queue.Numbers -replace '[^\d]'
                $tel = "+$($tel)"
                do {
                    $check = Get-CsOnlineApplicationInstance -Identity $upn

                } until ($check )
                do {
                    try {
     
                        $er = $null 
                        $a = Set-CsOnlineApplicationInstance -Identity $upn -OnpremPhoneNumber $tel -ErrorAction SilentlyContinue
        
                    }
                    catch {
                        #Write-Error $_
                        $er = $_
                    }
                } until ($a -and -not $er)
    
                write-host "..Sleeping 10 sec to replicate" 
                Start-countdown 10
    
            }
            #-------------------------------------#
            #Assosiate Resource Account with Queue#
            #-------------------------------------#
            Write-host ".Assosiating Resource Group and Call Queue"
            $name = "$($queue.name)"
            $applicationInstanceId = (Get-CsOnlineUser "$upn").ObjectId.guid
            $CallQueue = (Get-CsCallQueue -NameFilter $name -WarningAction SilentlyContinue).Identity 
            New-CsOnlineApplicationInstanceAssociation -Identities @($applicationInstanceId) -ConfigurationId $CallQueue -ConfigurationType CallQueue | Out-Null -WarningAction SilentlyContinue
  
            #-------------------------------------#
            #        Assign Voice Policy          #
            #-------------------------------------#
    
            Write-host ".Assinging Voice Policy" 
            Grant-CsOnlineVoiceRoutingPolicy -Identity $upn -PolicyName $VoicePolicy -ErrorAction SilentlyContinue
    

        }
    }




    #-------------------------------------#
    #     Used for AutoAttedant            #
    #-------------------------------------#

    if ($queue.Type -eq "AutoAttendant") {  
        Write-host "Creating the Queue $($name)" -ForegroundColor Yellow

        if (Get-CsAutoAttendant | ? name -like "*$($queue.name)") {
            write-host "A Queue already exist with this name"
            continue
        }
        #-------------------------------------#
        #      Create Resource Accounts       #
        #-------------------------------------#
        Write-host ".Creating the Resource Account"
        $AutoAttendantID = "ce933385-9390-45d1-9512-c8d228074e07" #fixed ID by Microsoft
        $name = "RA_AA_$($queue.name)"
        $UPN = "$($name)@$($domain)"
        Write-host "..Waiting until we know that the Resource account is fully created"
        New-CsOnlineApplicationInstance -UserPrincipalName $UPN -DisplayName $Name -ApplicationId $AutoAttendantID -WarningAction SilentlyContinue | Out-Null 
        do {
            $applicationInstanceId = (Get-CsOnlineUser "$upn" -erroraction SilentlyContinue ).ObjectId 
        } until ($applicationInstanceId )
    
        #-------------------------------------#
        #       Create Auto Attendant         #
        #-------------------------------------#
    
        # Callable entity
        $callableEntityParams = @{
            # Point to resource account, not call queue
            Identity = $applicationInstanceId.Guid
            Type     = 'ApplicationEndpoint'
        }
        $targetCqEntity = New-CsAutoAttendantCallableEntity @callableEntityParams
  
        # Menu option
        $menuOptionParams = @{
            Action       = 'DisconnectCall'
            DtmfResponse = 'Automatic' 
        }
        $menuOptionZero = New-CsAutoAttendantMenuOption @menuOptionParams
  
        # Finally, the menu
        $menuParams = @{
            Name        = "$name Default Menu"
            # Accepts list, so use array sub-expression operator
            MenuOptions = @($menuOptionZero)
        }
        $menu = New-CsAutoAttendantMenu @menuParams
  
        # And the call flow
        $defaultCallFlowParams = @{
            Name = "$name Default Call Flow"
            Menu = $menu
        }
        $defaultCallFlow = New-CsAutoAttendantCallFlow @defaultCallFlowParams
  
        # The Autoattendant
        $name = "$($queue.name)"
        $autoAttendantParams = @{
            Name            = $name
            LanguageId      = 'da-DK'
            TimeZoneId      = 'Romance Standard Time'
            DefaultCallFlow = $defaultCallFlow
            ErrorAction     = 'Stop'
        }
        $newAA = New-CsAutoAttendant @autoAttendantParams
    
        Write-host "Creating the Queue $($name)" -ForegroundColor Yellow
    
  
    
        #-------------------------------------#
        #Assign License for Resource Account  #
        #-------------------------------------#
        if ($Queue.Numbers -notlike "+45*") {
            Write-host "No Number - will not Assign license"
        }
        Else {
            Write-host ".Assigning License" 
            do {
                $user = Get-MsolUser -UserPrincipalName $UPN -ErrorAction SilentlyContinue
            } until ($user)
            Set-MsolUser -UserPrincipalName $UPN -UsageLocation "DK"
            Set-MsolUserLicense -UserPrincipalName $upn  -AddLicenses $license 
            do {
        
                $licensecheck = Get-MsolUser -UserPrincipalName $UPN 
            } until ($licensecheck.isLicensed -eq $true)
            write-host "..License ok"
            Start-countdown 10

            #-------------------------------------#
            #Assign Number for Resource Account  #
            #-------------------------------------#
            Write-host ".Assigning number" 
            Write-host "..This can take some time due to replication" -ForegroundColor DarkGray
            $tel = $queue.Numbers -replace '[^\d]'
            $tel = "+$($tel)"
            do {
                $check = Get-CsOnlineApplicationInstance -Identity $upn

            } until ($check )
            do {
                try {
     
                    $er = $null 
                    $a = Set-CsOnlineApplicationInstance -Identity $upn -OnpremPhoneNumber $tel -ErrorAction SilentlyContinue
        
                }
                catch {
                    #Write-Error $_
                    $er = $_
                }
            } until ($a -and -not $er)
    
            write-host "..Sleeping 10 sec to replicate" 
            Start-countdown 10
    
        }
    

        #-------------------------------------#
        #Assosiate Resource Account with Queue#
        #-------------------------------------#
        Write-host ".Assosiating Resource Group and Call Queue"
        # Last but not least, the association
        $aaAssociationParams = @{
            # As the previous association, array expected
            Identities        = $applicationInstanceId
            ConfigurationId   = $newAA.Identity
            ConfigurationType = 'AutoAttendant'
            ErrorAction       = 'Stop'
        }
        $associationRes = New-CsOnlineApplicationInstanceAssociation @aaAssociationParams  
        #-------------------------------------#
        #        Assign Voice Policy          #
        #-------------------------------------#
    
        Write-host ".Assinging Voice Policy" 
        Grant-CsOnlineVoiceRoutingPolicy -Identity $upn -PolicyName $VoicePolicy -ErrorAction SilentlyContinue
    
    
    }
    $i++
}








$users = Import-Csv "C:\Users\Mads\OneDrive - Zaulich\Arbejde\Scripts\Teams\CallQueue\UsersToQueue.csv"

$array = [System.Collections.ArrayList]@()
foreach($user in $users){
    $user = $user.upn+"@vallensbaek.dk"
    $objectID = (Get-MsolUser -UserPrincipalName $user).objectid
    
    $array.Add($objectID)

}
Set-CsCallQueue -Identity $cq.Identity -Users $array