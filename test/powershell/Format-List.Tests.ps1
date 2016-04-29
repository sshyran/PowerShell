Describe "Format-List" {
    $nl = [Environment]::NewLine
    BeforeEach {
        $in = New-Object PSObject
        Add-Member -InputObject $in -MemberType NoteProperty -Name testName -Value testValue
    }

    It "Should call format list without error" {
        { $in | Format-List } | Should Not BeNullOrEmpty
    }

    It "Should be able to call the alias" {
        { $in | fl } | Should Not BeNullOrEmpty
    }

    It "Should have the same output whether choosing alias or not" {
        $expected = $in | Format-List | Out-String
        $actual   = $in | fl          | Out-String

        $actual | Should Be $expected
    }

    It "Should produce the expected output" {
        $expected = "${nl}${nl}testName : testValue${nl}${nl}${nl}${nl}"
        $in = New-Object PSObject
        Add-Member -InputObject $in -MemberType NoteProperty -Name testName -Value testValue

        $in | Format-List                  | Should Not BeNullOrEmpty
        $in | Format-List   | Out-String   | Should Not BeNullOrEmpty
        $in | Format-List   | Out-String   | Should Be $expected
    }

    It "Should be able to call a property of the piped input" {
        # Tested on two input commands to verify functionality.
        { Get-Command | Format-List -Property Name }        | Should Not BeNullOrEmpty

        { Get-Date    | Format-List -Property DisplayName } | Should Not BeNullOrEmpty
    }

    It "Should be able to display a list of props when separated by a comma" {

        (Get-Command | Format-List -Property Name,Source | Out-String) -Split "${nl}" |
          Where-Object { $_.trim() -ne "" } |
          ForEach-Object { $_ | Should Match "(Name)|(Source)" }
    }

    It "Should show the requested prop in every element" {
        # Testing each element of format-list, using a for-each loop since the Format-List is so opaque
        (Get-Command | Format-List -Property Source | Out-String) -Split "${nl}" |
          Where-Object { $_.trim() -ne "" } |
          ForEach-Object { $_ | Should Match "Source :" }
    }

    It "Should not show anything other than the requested props" {
        $output = Get-Command | Format-List -Property Name | Out-String

        $output | Should Not Match "CommandType :"
        $output | Should Not Match "Source :"
        $output | Should Not Match "Module :"
    }

    It "Should be able to take input without piping objects to it" {
        $output = { Format-List -InputObject $in }

        $output | Should Not BeNullOrEmpty

    }
}

Describe "Format-List DRT basic functionality" -Tags DRT{
	It "Format-List with array should work"{
		$al = (0..255)
		$info = @{}
		$info.array = $al
		$result = $info | Format-List | Out-String
		$result | Should Match "Name  : array\s+Value : {0, 1, 2, 3...}"
	}
	
	It "Format-List with No Objects for End-To-End should work"{
		$p = @{}
		$result = $p | Format-List -Property "foo","bar" | Out-String
		$result | Should BeNullOrEmpty
	}
	
	It "Format-List with Null Objects for End-To-End should work"{
		$p = $null
		$result = $p | Format-List -Property "foo","bar" | Out-String
		$result | Should BeNullOrEmpty
	}
	
	#pending on issue#900
	It "Format-List with single line string for End-To-End should work" -pending{
		$p = "single line string"
		$result = $p | Format-List -Property "foo","bar" | Out-String
		$result | Should BeNullOrEmpty
	}
	
	#pending on issue#900
	It "Format-List with multiple line string for End-To-End should work" -pending{
		$p = "Line1\nLine2"
		$result = $p | Format-List -Property "foo","bar" | Out-String
		$result | Should BeNullOrEmpty
	}
	
	#pending on issue#900
	It "Format-List with string sequence for End-To-End should work" -pending{
		$p = "Line1","Line2"
		$result = $p | Format-List -Property "foo","bar" | Out-String
		$result | Should BeNullOrEmpty
	}
	
	It "Format-List with complex object for End-To-End should work"{
		Add-Type -TypeDefinition "public enum MyDayOfWeek{Sun,Mon,Tue,Wed,Thr,Fri,Sat}"
		$eto = New-Object MyDayOfWeek
		$info = @{}
		$info.intArray = 1,2,3,4
		$info.arrayList = "string1","string2"
		$info.enumerable = [MyDayOfWeek]$eto
		$info.enumerableTestObject = $eto
		$result = $info|Format-List|Out-String
		$result | Should Match "Name  : enumerableTestObject"
		$result | Should Match "Value : Sun"
		$result | Should Match "Name  : arrayList"
		$result | Should Match "Value : {string1, string2}"
		$result | Should Match "Name  : enumerable"
		$result | Should Match "Value : Sun"
		$result | Should Match "Name  : intArray"
		$result | Should Match "Value : {1, 2, 3, 4}"
	}
}
