function Get-MetaData {
    [CmdletBinding()][OutputType([object])]
    param
    (
        [ValidateNotNullOrEmpty()][string]$FileName
    )

    if ($IsWindows) {
        $MetaDataObject = New-Object -TypeName psobject
        $shell = New-Object -COMObject Shell.Application
        $folder = Split-Path $FileName
        $file = Split-Path $FileName -Leaf
        $shellfolder = $shell.Namespace($folder)
        $shellfile = $shellfolder.ParseName($file)
        # $MetaDataProperties = 0..322 | Foreach-Object { '{0} = {1}' -f $_, $shellfolder.GetDetailsOf($null, $_) }
        
        
        $MetaDataObject | Add-Member -MemberType NoteProperty -Name $Property -Value $Value
        
        $metaDataProperties = 


        for ($i = 0; $i -le 322; $i++) {
            $Property = ($MetaDataProperties[$i].split("="))[1].Trim()
            $Property = (Get-Culture).TextInfo.ToTitleCase($Property).Replace(' ', '')
            $Value = $shellfolder.GetDetailsOf($shellfile, $i)
            if ($Property -eq 'Attributes') {
                switch ($Value) {
                    'A' {
                        $Value = 'Archive (A)'
                    }
                    'D' {
                        $Value = 'Directory (D)'
                    }
                    'H' {
                        $Value = 'Hidden (H)'
                    }
                    'L' {
                        $Value = 'Symlink (L)'
                    }
                    'R' {
                        $Value = 'Read-Only (R)'
                    }
                    'S' {
                        $Value = 'System (S)'
                    }
                }
            }
            #Do not add metadata fields which have no information
            If ($Property -and ($Property -ne '') -and $Value -and ($Value -ne '')) {
                $MetaDataObject | Add-Member -MemberType NoteProperty -Name $Property -Value $Value
            }
        }
        # [string]$FileVersionInfo = (Get-ItemProperty $FileName).VersionInfo
        # $SplitInfo = $FileVersionInfo.Split([char]13)
        # foreach ($Item in $SplitInfo) {
        #     $Property = $Item.Split(":").Trim()
        #     switch ($Property[0]) {
        #         "InternalName" {
        #             $MetaDataObject | Add-Member -MemberType NoteProperty -Name InternalName -Value $Property[1]
        #         }
        #         "OriginalFileName" {
        #             $MetaDataObject | Add-Member -MemberType NoteProperty -Name OriginalFileName -Value $Property[1]
        #         }
        #         "Product" {
        #             $MetaDataObject | Add-Member -MemberType NoteProperty -Name Product -Value $Property[1]
        #         }
        #         "Debug" {
        #             $MetaDataObject | Add-Member -MemberType NoteProperty -Name Debug -Value $Property[1]
        #         }
        #         "Patched" {
        #             $MetaDataObject | Add-Member -MemberType NoteProperty -Name Patched -Value $Property[1]
        #         }
        #         "PreRelease" {
        #             $MetaDataObject | Add-Member -MemberType NoteProperty -Name PreRelease -Value $Property[1]
        #         }
        #         "PrivateBuild" {
        #             $MetaDataObject | Add-Member -MemberType NoteProperty -Name PrivateBuild -Value $Property[1]
        #         }
        #         "SpecialBuild" {
        #             $MetaDataObject | Add-Member -MemberType NoteProperty -Name SpecialBuild -Value $Property[1]
        #         }
        #     }
        # }
    
        #Check if file is read-only
        $ReadOnly = (Get-ChildItem $FileName) | Select-Object IsReadOnly
        $MetaDataObject | Add-Member -MemberType NoteProperty -Name ReadOnly -Value $ReadOnly.IsReadOnly
        # #Get digital file signature information
        # $DigitalSignature = get-authenticodesignature -filepath $FileName
        # $MetaDataObject | Add-Member -MemberType NoteProperty -Name SignatureCertificateSubject -Value $DigitalSignature.SignerCertificate.Subject
        # $MetaDataObject | Add-Member -MemberType NoteProperty -Name SignatureCertificateIssuer -Value $DigitalSignature.SignerCertificate.Issuer
        # $MetaDataObject | Add-Member -MemberType NoteProperty -Name SignatureCertificateSerialNumber -Value $DigitalSignature.SignerCertificate.SerialNumber
        # $MetaDataObject | Add-Member -MemberType NoteProperty -Name SignatureCertificateNotBefore -Value $DigitalSignature.SignerCertificate.NotBefore
        # $MetaDataObject | Add-Member -MemberType NoteProperty -Name SignatureCertificateNotAfter -Value $DigitalSignature.SignerCertificate.NotAfter
        # $MetaDataObject | Add-Member -MemberType NoteProperty -Name SignatureCertificateThumbprint -Value $DigitalSignature.SignerCertificate.Thumbprint
        # $MetaDataObject | Add-Member -MemberType NoteProperty -Name SignatureStatus -Value $DigitalSignature.Status
        return $MetaDataObject
    }
    elseif ($IsMacOS) {
        $metaData = @{
            MetaData = mdls $file.FullName;
        }
        return $metaData
    }
}