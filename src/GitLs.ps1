function Out-Default {
      [CmdletBinding(HelpUri='http://go.microsoft.com/fwlink/?LinkID=113362', RemotingCapability='None')]
    param(
         [switch] ${Transcript},
         [Parameter(Position=0, ValueFromPipeline=$true)]
         [psobject] ${InputObject})
 
    begin
    {		  
        $outBuffer = $null
        if ($PSBoundParameters.TryGetValue('OutBuffer', [ref]$outBuffer))
        {
            $PSBoundParameters['OutBuffer'] = 1
        }
        $wrappedCmd = $ExecutionContext.InvokeCommand.GetCommand('Microsoft.PowerShell.Core\Out-Default', [System.Management.Automation.CommandTypes]::Cmdlet)
        $scriptCmd = {& $wrappedCmd @PSBoundParameters }

        $steppablePipeline = $scriptCmd.GetSteppablePipeline()
        $steppablePipeline.Begin($PSCmdlet)
    }
      
    process
    {
      if( ($_ -is [System.IO.FileInfo]))
      {
          ProcessFile $_
          $_ = $null
      }
      elseif ($_ -is [System.IO.DirectoryInfo])
      {
          ProcessDirectory $_
          $_ = $null
      }
      else 
      {
          $steppablePipeline.Process($_)
      }
   } 
  end {
      write-host ""
      $script:showHeader=$true
      $steppablePipeline.End()
  }
}

Function ProcessFile {
  param (
    [Parameter(Mandatory=$True, Position=1)]
    $file
  )
  Write-File-Ls $file
  Write-Host ""
}


Function ProcessDirectory {
  param (
    [Parameter(Mandatory=$True, Position=1)]
    $dir
  )

  Write-File-Ls $dir

  if (IsGitRepositoryRoot $dir)
  {
    $status = Get-GitStatus $dir
    Write-GitStatus $status
  }
  write-host ""
}

function Write-File-Ls
{
   param ([Parameter(Mandatory=$True, Position=1)]$file)
    Write-host ("{0,-7} {1,25} {2,10} {3}" -f $file.mode, ([String]::Format("{0,10}  {1,8}", $file.LastWriteTime.ToString("d"), $file.LastWriteTime.ToString("t"))), ($file.length), $file.name) -NoNewLine
}

function Write-FileLength
{
    param ($length)

    if ($length -eq $null)
    {
        return ""
    }
    elseif ($length -ge 1GB)
    {
        return ($length / 1GB).ToString("F") + 'GB'
    }
    elseif ($length -ge 1MB)
    {
        return ($length / 1MB).ToString("F") + 'MB'
    }
    elseif ($length -ge 1KB)
    {
        return ($length / 1KB).ToString("F") + 'KB'
    }

    return $length.ToString() + '  '
}