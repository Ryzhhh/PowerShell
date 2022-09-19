#Ryzhhh
#Ce script permet de copier les données des utilisateurs (Bureau, téléchargement, documents ...) // Liste des éléments copiés $ListeFichiersCopié
#V1.0



#Lance l'UAC pour utiliser les droits admins (nécessaire pour la copie des données)

if (-Not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] 'Administrator')) {
    if ([int](Get-CimInstance -Class Win32_OperatingSystem | Select-Object -ExpandProperty BuildNumber) -ge 6000) {
        $Command = "-File `"" + $MyInvocation.MyCommand.Path + "`" " + $MyInvocation.UnboundArguments
        Start-Process -FilePath PowerShell.exe -Verb RunAs -ArgumentList $Command
        Exit
 }
}


#Création de la liste des fichers à copier

$ListeFichiersCopié = @(
    'Desktop'
    'Downloads'
    'Favorites'
    'Documents'
    'Pictures'
    'Videos'
    )



#Variable de test
$TestConnexion = "false"
$TestUser = "false"
$TestConnexionDistant = "false"
$TestUserDistant = "false"



while( $TestConnexion -eq "false" ){
    $Computer = Read-Host -Prompt 'Entrer le nom du PC source à copier : '

    if( -not ( Test-Connection -ComputerName $Computer -Count 2 -Quiet ) ){
        Write-Warning "$Computer n'est pas connecté au réseau. Veuillez réessayer."        #Test le nom du PC en envoyant un paquet ICMP, si aucune réponse, on redemande le nom du PC.
        continue
        $TestConnexion = "false"
        }
    else {
        $TestConnexion = "true"
    }
}


while( $TestUser -eq "false" ){
    $User = Read-Host -Prompt 'Nom du login à copier'

    if( -not ( Test-Path -Path "\\$Computer\c$\Users\$User" -PathType Container ) ){
        Write-Warning "$User introuvable dans $Computer. Veuillez entrez un autre login."       #Test le répertoire de l'utilisateur inséré dans la variable $User
        continue
        $TestUser = "false"
        }
    else{
        $TestUser = "true"
    }
}


while( $TestConnexionDistant -eq "false" ){
    $ComputerDistant = Read-Host -Prompt 'Entrer le nom du PC destination à copier'

    if( -not ( Test-Connection -ComputerName $ComputerDistant -Count 2 -Quiet ) ){
        Write-Warning "$ComputerDistant n'est pas connecté au réseau. Veuillez réessayer."       #Test le nom du PC distant en envoyant un paquet ICMP, si aucune réponse, on redemande le nom du PC.
        continue
        $TestConnexionDistant = "false"
        }
    else{
        $TestConnexionDistant = "true"
    }
}


while( $TestUserDistant -eq "false" ){
    $UserDistant = Read-Host -Prompt 'Nom du login à copier'

    if( -not ( Test-Path -Path "\\$Computer\c$\Users\$UserDistant" -PathType Container ) ){
        Write-Warning "$UserDistant introuvable dans $Computer. Pensez à lancer une première fois la session avant la copie !"     #Test le répertoire de l'utilisateur inséré dans la variable $UserDistant
        continue
        $TestUserDistant = "false"
        }
    else{
        $TestUserDistant = "true"
    }
}



$SourceRoot      = "\\$Computer\c$\Users\$User"
$DestinationRoot = "\\$ComputerDistant\c$\Users\$UserDistant"

foreach( $Folder in $ListeFichiersCopié ){
    $Source      = Join-Path -Path $SourceRoot -ChildPath $Folder
    $Destination = Join-Path -Path $DestinationRoot -ChildPath $Folder           

    if( -not ( Test-Path -Path $Source -PathType Container ) ){
        Write-Warning "Could not find path`t$Source"
        continue
        }

    Robocopy.exe $Source $Destination /E /IS /NP /NFL
    }


Write-Host -NoNewLine 'Copie terminé, appuyez sur une touche pour continuer...';
$null = $Host.UI.RawUI.ReadKey('NoEcho,IncludeKeyDown');