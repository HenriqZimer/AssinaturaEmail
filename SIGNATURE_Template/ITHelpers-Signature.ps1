Copy-Item -Path "\\DC01\SIGNATURE_Template\ITHelpers_files*" -Destination "C:\Users\$env:UserName\AppData\Roaming\Microsoft\Signatures"

### https://dev.to/jcoelho/how-to-deploy-email-signatures-through-group-policies-4aj1

# Gets the path to the user appdata folder
$AppData = (Get-Item env:appdata).value
# This is the default signature folder for Outlook
$localSignatureFolder = $AppData+'\Microsoft\Signatures'
# This is a shared folder on your network where the signature template should be
$templateFilePath = "\\DC01\SIGNATURE_Template"

# Get the current logged in username
$userName = $env:username

# The following 5 lines will query AD and get an ADUser object with all information
$filter = "(&(objectCategory=User)(samAccountName=$userName))"
$searcher = New-Object System.DirectoryServices.DirectorySearcher
$searcher.Filter = $filter
$ADUserPath = $searcher.FindOne()
$ADUser = $ADUserPath.GetDirectoryEntry()

# Now extract all the necessary information for the signature
$name = $ADUser.DisplayName
$email = $ADUser.mail
$job = $ADUser.title
$department = $ADUser.department
$phone = $ADUser.telephoneNumber
$mobile = $ADUser.mobile
$CITY = $ADUser.l
$POSTALCODE = $ADUser.POSTALCODE
$STREETADDRESS  = $ADUser.STREETADDRESS


#################################################################################################################

$namePlaceHolder = "NAME"
$emailPlaceHolder = "EMAIL"
$jobPlaceHolder = "Description"
$departmentPlaceHolder = "DEPARTMENT"
$phonePlaceHolder = "OFFICEPHONE1"
$POSTALCODEPlaceHolder = "POSTALCODE"
$mobilePlaceHolder = "mobile1"
$STREETADDRESSPlaceHolder = "STREETADDRESS"
$CITYPlaceHolder = "CITY"

$rawTemplate = get-content $templateFilePath"\ITHelpers.htm"

$signature = $rawTemplate -replace $namePlaceHolder,$name
$rawTemplate = $signature

$signature = $rawTemplate -replace $emailPlaceHolder,$email
$rawTemplate = $signature

$signature = $rawTemplate -replace $phonePlaceHolder,$phone
$rawTemplate = $signature

$signature = $rawTemplate -replace $jobPlaceHolder,$job
$rawTemplate = $signature

$signature = $rawTemplate -replace $POSTALCODEPlaceHolder,$POSTALCODE
$rawTemplate = $signature

$signature = $rawTemplate -replace $departmentPlaceHolder,$department

$signature = $rawTemplate -replace $mobilePlaceHolder,$mobile
$rawTemplate = $signature

$signature = $rawTemplate -replace $STREETADDRESSPlaceHolder,$STREETADDRESS
$rawTemplate = $signature

$signature = $rawTemplate -replace $CITYPlaceHolder,$CITY
$rawTemplate = $signature


# Save it as <username>.htm
$fileName = $localSignatureFolder + "\" + "ITHelpers" + ".htm"

###########################################################################################################################

# Gets the last update time of the template.
if(test-path $templateFilePath){
    $templateLastModifiedDate = [datetime](Get-ItemProperty -Path $templateFilePath -Name LastWriteTime).lastwritetime
}

# Checks if there is a signature and its last update time
if(test-path $filename){
    $signatureLastModifiedDate = [datetime](Get-ItemProperty -Path $filename -Name LastWriteTime).lastwritetime
    if((get-date $templateLastModifiedDate) -gt (get-date $signatureLastModifiedDate)){
        $signature > $fileName
    }
}else{
    $signature > $fileName
}

Copy-Item -Path "\\DC01\SIGNATURE_Template\ITHelpers_files*" -Destination "C:\Users\$env:UserName\AppData\Roaming\Microsoft\Signatures" -Recurse