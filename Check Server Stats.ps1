$files = get-childitem .\ -Recurse -Filter '*.py'

#$files | Get-Member

$files | Copy-Item

if(!(Test-Path -path "C:\Users\pmedley\Desktop\demo-folder")) {
New-Item -Itemtype "directory" -Path "C:\Users\pmedley\Desktop\demo-folder"
}

Foreach($file in $files){
Copy-Item -path $file.Fullname -Destination "C:\Users\pmedley\Desktop\demo-folder"
}
