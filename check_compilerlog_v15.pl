#!/usr/bin/perl -w                                  

print "Enter the name of original file: ";        # User need to enter the file name for original version      
chomp($original_file = <STDIN>);

print "Enter the name of new file: ";             # User need to enter the file name for new version
chomp($new_file = <STDIN>);

open(ORIF, "<" ,$original_file) or die "\nError: can't open $original_file file.";
open(NEWF, "<" ,$new_file) or die "\nError: can't open $new_file file.";

open(TEMPORI, ">" , "temp_$original_file") or die "\nCould not create and write a temp file for original.";  
open(DIFFLIST, ">" ,"difference_list.txt") or die "\nCould not create and write a temp file for new.";   

$time_now = localtime;
print "\n" . "Start Time : " . $time_now . "\n";
print DIFFLIST "\n" . "Start Time : " . $time_now . "\n";

%warnings_new = (); %warnings_ori = ();		         # {$warning_no} => count for how many time warning appears in the new/ori
%warnings_table_new = (); %warnings_table_ori = ();  # {$warning_no} => adjusted content w/o line number for new/ori
%content_wof_ori = (); %content_wof_new = ();        # {$warning_no} => adjusted content w/o file path for new/ori
%content_ori = (); %content_new = ();                # {$warning_no} => content for new/ori
%filename_ori = (); %filename_new = ();              # {$warning_no} => file name for new/ori
%cnt_repeat_ori = (); %cnt_repeat_new = ();          # {$warning_no} => count for how many time warning appears in the same file
%check_list_ori = (); %check_list_new = ();          # {$warning_no} => if warning has been checked and result is the same, the value is 1

$cnt_ori = 0; $cnt_new = 0; $cnt_diff_all = 0;
$cnt_diff_ori = 0;$cnt_diff_new = 0;
$line_no_ori = 1; $line_no_new = 1;
 
print "======================================================================================================\n";
print "Start to find the error / warning messages form both files.\n";
print "------------------------------------------------------------------------------------------------------\n";
print DIFFLIST "============================================================================================================================================================================================================\n";
print DIFFLIST "Start to find the error / warning messages form both files.\n";
print DIFFLIST "------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------\n";

while (<ORIF>){                                                         # For original file, search keywords and then save it to temp file
   my $line = $_;    # read a line from original version
   my $line_cut = $_;
   my $file_path=$_;
   my $warning_no = "z";

    if ($line =~ /^Warning: .*$/){  	                                # check keywords exist by using if else
       $cnt_ori++; $warning_no = "x"; print TEMPORI $line;              # If yes, the data save to temp file
    }else{                                       
        if ($line =~/^(Critical |\s*)Warning\s+\(([0-9]+)\):\s+.*$/){
            $cnt_ori++; $warning_no = $2; print TEMPORI $line;
        }else{
            if ($line =~ /^Critical Warning: supported quartus version.*$/){

            }else{
                if ($line =~ /^Critical Warning: project is run on.*$/){

                }else{
                    if ($line =~ /^(Critical |\s*)Error\s+\(([0-9]+)\):\s+.*$/){
                        $cnt_ori++; $warning_no = $2; print TEMPORI $line;                     
                    }else{
                        if ($line =~ /^Error: .*$/){
                            $cnt_ori++; $warning_no = "y"; print TEMPORI $line;                          
                        }else{

                        }
                    }
                }
            }
        }
    }
 
   if ($warning_no ne "z") {
        my $where_file = index($line, "File: /");
		
		if ($where_file != -1){                             #delete content after File: / 
		    $line_cut = substr ($line, 0, $where_file);	
            $file_path  = substr ($line, $where_file);
            my @file_step1 = split " ", $file_path;
			my @file_step2 = split "/", $file_step1[1];;
			my $key_filename = $file_step2[-1]."(";
			my $key_length = length($key_filename);
			my $where_key = index($line_cut, $key_filename);			

		    if (exists($warnings_ori{$warning_no})){ 
		        $warnings_ori{$warning_no}++;
		        
				if ($where_key != -1){
		            my $string_1 = substr ($line_cut, 0, $where_key+$key_length-1);  
			        my $string_2 = substr ($line_cut, $where_key+$key_length-1);
			        $string_2 =~ tr/^\([0-9]+\)//d;
					$content_wof_ori{$warning_no}->[$warnings_ori{$warning_no}] = $file_step2[-1].$line_cut;
			        $warnings_table_ori{$warning_no}->[$warnings_ori{$warning_no}] = $file_step2[-1].$string_1.$string_2;
				    $content_ori{$warning_no}->[$warnings_ori{$warning_no}] = "Log\#=".$original_file." | Line\#=".$line_no_ori." | File\#=".$file_step2[-1]." | $line";
                    $filename_ori{$warning_no}->[$warnings_ori{$warning_no}] = $file_step2[-1];		
                    $check_list_ori{$warning_no}->[$warnings_ori{$warning_no}] = 0;					
				}else{
				    $content_wof_ori{$warning_no}->[$warnings_ori{$warning_no}] = $file_step2[-1].$line_cut;
                    $warnings_table_ori{$warning_no}->[$warnings_ori{$warning_no}] = $file_step2[-1].$line_cut;
					$content_ori{$warning_no}->[$warnings_ori{$warning_no}] = "Log\#=".$original_file." | Line\#=".$line_no_ori." | File\#=".$file_step2[-1]." | $line";
                    $filename_ori{$warning_no}->[$warnings_ori{$warning_no}] = $file_step2[-1];	
					$check_list_ori{$warning_no}->[$warnings_ori{$warning_no}] = 0;	
				}		
		    }else{
			    $warnings_ori{$warning_no} = 0;
			    if ($where_key != -1){
		            my $string_1 = substr ($line_cut, 0, $where_key+$key_length-1);  
			        my $string_2 = substr ($line_cut, $where_key+$key_length-1);
			        $string_2 =~ tr/^\([0-9]+\)//d;
					$content_wof_ori{$warning_no}->[$warnings_ori{$warning_no}] = $file_step2[-1].$line_cut;
			        $warnings_table_ori{$warning_no}->[$warnings_ori{$warning_no}] = $file_step2[-1].$string_1.$string_2;
					$content_ori{$warning_no}->[$warnings_ori{$warning_no}] = "Log\#=".$original_file." | Line\#=".$line_no_ori." | File\#=".$file_step2[-1]." | $line";
                    $filename_ori{$warning_no}->[$warnings_ori{$warning_no}] = $file_step2[-1];		
                    $check_list_ori{$warning_no}->[$warnings_ori{$warning_no}] = 0;						
				}else{
				    $content_wof_ori{$warning_no}->[$warnings_ori{$warning_no}] = $file_step2[-1].$line_cut;
                    $warnings_table_ori{$warning_no}->[$warnings_ori{$warning_no}] = $file_step2[-1].$line_cut;	
					$content_ori{$warning_no}->[$warnings_ori{$warning_no}] = "Log\#=".$original_file." | Line\#=".$line_no_ori." | File\#=".$file_step2[-1]." | $line";
                    $filename_ori{$warning_no}->[$warnings_ori{$warning_no}] = $file_step2[-1];	
                    $check_list_ori{$warning_no}->[$warnings_ori{$warning_no}] = 0;						
				}
			}			
		}else{
		    $line_cut = $line;
		    $where_v = index($line_cut, ".v"); 
            $where_sv = index($line_cut, ".sv"); 
            $where_sdc = index($line_cut, ".sdc");
			$where_vh = index($line_cut, ".vh");

		    if (exists($warnings_ori{$warning_no})){ 
		        $warnings_ori{$warning_no}++;
		
                if (($where_v != -1) && ($where_vh == -1)){
				    @file = split "/", $line_cut;
                    @file_final = split ' ', $file[-1];
					$content_wof_ori{$warning_no}->[$warnings_ori{$warning_no}] = $line_cut;
					$warnings_table_ori{$warning_no}->[$warnings_ori{$warning_no}] = $line_cut; 
					$content_ori{$warning_no}->[$warnings_ori{$warning_no}] = "Log\#=".$original_file." | Line\#=".$line_no_ori." | File\#=".$file_final[0]." | $line";
				    $filename_ori{$warning_no}->[$warnings_ori{$warning_no}] = $file_final[0];
					$check_list_ori{$warning_no}->[$warnings_ori{$warning_no}] = 0;	
		        }elsif($where_sv != -1){ 
				    @file = split "/", $line_cut;
                    @file_final = split ' ', $file[-1];
					$content_wof_ori{$warning_no}->[$warnings_ori{$warning_no}] = $line_cut;
					$warnings_table_ori{$warning_no}->[$warnings_ori{$warning_no}] = $line_cut; 
                    $content_ori{$warning_no}->[$warnings_ori{$warning_no}] = "Log\#=".$original_file." | Line\#=".$line_no_ori." | File\#=".$file_final[0]." | $line";					
                    $filename_ori{$warning_no}->[$warnings_ori{$warning_no}] = $file_final[0];	
                    $check_list_ori{$warning_no}->[$warnings_ori{$warning_no}] = 0;						
		        }elsif ($where_sdc != -1){	
                    @file = split ":", $line_cut;
                    $content_wof_ori{$warning_no}->[$warnings_ori{$warning_no}] = $line_cut;					
					$warnings_table_ori{$warning_no}->[$warnings_ori{$warning_no}] = $line_cut; 
					$content_ori{$warning_no}->[$warnings_ori{$warning_no}] = "Log\#=".$original_file." | Line\#=".$line_no_ori." | File\#=".$file[1]." | $line";
                    $filename_ori{$warning_no}->[$warnings_ori{$warning_no}] = $file[1];
                    $check_list_ori{$warning_no}->[$warnings_ori{$warning_no}] = 0;						
		        }else{
				    $content_wof_ori{$warning_no}->[$warnings_ori{$warning_no}] = $line_cut;
                    $warnings_table_ori{$warning_no}->[$warnings_ori{$warning_no}] = $line_cut;	
					$content_ori{$warning_no}->[$warnings_ori{$warning_no}] = "Log\#=".$original_file." | Line\#=".$line_no_ori." | File\#=         | $line";
                    $filename_ori{$warning_no}->[$warnings_ori{$warning_no}] = " "; 
                    $check_list_ori{$warning_no}->[$warnings_ori{$warning_no}] = 0;						
				}	 
		    }else{
		        $warnings_ori{$warning_no} = 0;

                if (($where_v != -1) && ($where_vh == -1)){
				    @file = split "/", $line_cut;
                    @file_final = split ' ', $file[-1];
					$content_wof_ori{$warning_no}->[$warnings_ori{$warning_no}] = $line_cut;
			        $warnings_table_ori{$warning_no}->[$warnings_ori{$warning_no}] = $line_cut; 	
					$content_ori{$warning_no}->[$warnings_ori{$warning_no}] = "Log\#=".$original_file." | Line\#=".$line_no_ori." | File\#=".$file_final[0]." | $line";
				    $filename_ori{$warning_no}->[$warnings_ori{$warning_no}] = $file_final[0];
					$check_list_ori{$warning_no}->[$warnings_ori{$warning_no}] = 0;	
		        }elsif($where_sv != -1){
				    @file = split "/", $line_cut;
                    @file_final = split ' ', $file[-1];
					$content_wof_ori{$warning_no}->[$warnings_ori{$warning_no}] = $line_cut;
                    $warnings_table_ori{$warning_no}->[$warnings_ori{$warning_no}] = $line_cut; 
                    $content_ori{$warning_no}->[$warnings_ori{$warning_no}] = "Log\#=".$original_file." | Line\#=".$line_no_ori." | File\#=".$file_final[0]." | $line";					
                    $filename_ori{$warning_no}->[$warnings_ori{$warning_no}] = $file_final[0];	
                    $check_list_ori{$warning_no}->[$warnings_ori{$warning_no}] = 0;						
		        }elsif ($where_sdc != -1){
				    @file = split ":", $line_cut;
                    $content_wof_ori{$warning_no}->[$warnings_ori{$warning_no}] = $line_cut;					
			        $warnings_table_ori{$warning_no}->[$warnings_ori{$warning_no}] = $line_cut; 
					$content_ori{$warning_no}->[$warnings_ori{$warning_no}] = "Log\#=".$original_file." | Line\#=".$line_no_ori." | File\#=".$file[1]." | $line";
                    $filename_ori{$warning_no}->[$warnings_ori{$warning_no}] = $file[1];
                    $check_list_ori{$warning_no}->[$warnings_ori{$warning_no}] = 0;						
		        }else{
				    $content_wof_ori{$warning_no}->[$warnings_ori{$warning_no}] = $line_cut;
                    $warnings_table_ori{$warning_no}->[$warnings_ori{$warning_no}] = $line_cut;	
					$content_ori{$warning_no}->[$warnings_ori{$warning_no}] = "Log\#=".$original_file." | Line\#=".$line_no_ori." | File\#=         | $line";
                    $filename_ori{$warning_no}->[$warnings_ori{$warning_no}] = " ";	
					$check_list_ori{$warning_no}->[$warnings_ori{$warning_no}] = 0;	
				}		
		    }			
		}		
    } 
    $line_no_ori++;
}

while (my $warnings = each %warnings_table_ori){
    foreach $items_ori (0.. $#{$warnings_table_ori{$warnings}}){
	    my $cnt_repeat = 0;
        foreach my $items_check (0.. $#{$warnings_table_ori{$warnings}}){
		    $cnt_repeat++ if ($warnings_table_ori{$warnings}->[$items_ori] eq $warnings_table_ori{$warnings}->[$items_check]);			
        }
	    $cnt_repeat_ori{$warnings}->[$items_ori] = $cnt_repeat;
    }
}

close (ORIF); close (TEMPORI);                                    # close the files that we do not use anymore        
open(TEMPNEW, ">" , "temp_$new_file") or die "\nCould not create and write a temp file for new.";

while (<NEWF>){                                                                  # For new file, search keywords and then save it to temp file
   my $line = $_;    # read a line from new version
   my $line_cut = $_;
   my $warning_no = "z";
   
    if ($line =~ /^Warning: .*$/){                                          # check keywords exist by using if else
        $cnt_new++; $warning_no = "x"; print TEMPNEW $line;                  # If yes, the data save to temp file
    }else{
        if ($line =~ /^(Critical |\s*)Warning\s+\(([0-9]+)\):\s+.*$/){
            $cnt_new++; $warning_no = $2; print TEMPNEW $line;
        }else{
            if ($line =~ /^Critical Warning: supported quartus version.*$/){

            }else{
                if ($line =~ /^Critical Warning: project is run on.*$/){

                }else{
                    if ($line =~ /^(Critical |\s*)Error\s+\(([0-9]+)\):\s+.*$/){
                        $cnt_new++; $warning_no = $2; print TEMPNEW $line;                     
                    }else{
                        if ($line =~ /^Error: .*$/){
                            $cnt_new++; $warning_no = "y"; print TEMPNEW $line;                          
                        }else{

                        }
                    }
                }
            }
        }
    }

   if ($warning_no ne "z") {
        my $where_file = index($line, "File: /");
		my $where_v = $_; my $where_hex = $_;
        my $where_sv = $_; my $where_tdf = $_; 
		my $where_sdc = $_; my $where_svh = $_;
        my $where_vh = $_;				
		
		if ($where_file != -1){                             #delete content after File: / 
		    $line_cut = substr ($line, 0, $where_file);	
            $file_path  = substr ($line, $where_file);
            my @file_step1 = split " ", $file_path;
			my @file_step2 = split "/", $file_step1[1];;
			my $key_filename = $file_step2[-1]."(";
			my $key_length = length($key_filename);
			my $where_key = index($line_cut, $key_filename);			

		    if (exists($warnings_new{$warning_no})){ 
		        $warnings_new{$warning_no}++;
		        
				if ($where_key != -1){
		            my $string_1 = substr ($line_cut, 0, $where_key+$key_length-1);  
			        my $string_2 = substr ($line_cut, $where_key+$key_length-1);
			        $string_2 =~ tr/^\([0-9]+\)//d;
					$content_wof_new{$warning_no}->[$warnings_new{$warning_no}] = $file_step2[-1].$line_cut;
			        $warnings_table_new{$warning_no}->[$warnings_new{$warning_no}] = $file_step2[-1].$string_1.$string_2;
					$content_new{$warning_no}->[$warnings_new{$warning_no}] = "Log\#=".$new_file." | Line\#=".$line_no_new." | File\#=".$file_step2[-1]." | $line";
                    $filename_new{$warning_no}->[$warnings_new{$warning_no}] = $file_step2[-1];		
                    $check_list_new{$warning_no}->[$warnings_new{$warning_no}] = 0;					
				}else{
				    $content_wof_new{$warning_no}->[$warnings_new{$warning_no}] = $file_step2[-1].$line_cut;
                    $warnings_table_new{$warning_no}->[$warnings_new{$warning_no}] = $file_step2[-1].$line_cut;	
					$content_new{$warning_no}->[$warnings_new{$warning_no}] = "Log\#=".$new_file." | Line\#=".$line_no_new." | File\#=".$file_step2[-1]." | $line";
                    $filename_new{$warning_no}->[$warnings_new{$warning_no}] = $file_step2[-1];
                    $check_list_new{$warning_no}->[$warnings_new{$warning_no}] = 0;					
				}		
		    }else{
			    $warnings_new{$warning_no} = 0;
			    if ($where_key != -1){
		            my $string_1 = substr ($line_cut, 0, $where_key+$key_length-1);  
			        my $string_2 = substr ($line_cut, $where_key+$key_length-1);
			        $string_2 =~ tr/^\([0-9]+\)//d;
					$content_wof_new{$warning_no}->[$warnings_new{$warning_no}] = $file_step2[-1].$line_cut;
			        $warnings_table_new{$warning_no}->[$warnings_new{$warning_no}] = $file_step2[-1].$string_1.$string_2;
					$content_new{$warning_no}->[$warnings_new{$warning_no}] = "Log\#=".$new_file." | Line\#=".$line_no_new." | File\#=".$file_step2[-1]." | $line";
                    $filename_new{$warning_no}->[$warnings_new{$warning_no}] = $file_step2[-1];	
                    $check_list_new{$warning_no}->[$warnings_new{$warning_no}] = 0;					
				
				}else{
				    $content_wof_new{$warning_no}->[$warnings_new{$warning_no}] = $file_step2[-1].$line_cut;
                    $warnings_table_new{$warning_no}->[$warnings_new{$warning_no}] = $file_step2[-1].$line_cut;	
					$content_new{$warning_no}->[$warnings_new{$warning_no}] = "Log\#=".$new_file." | Line\#=".$line_no_new." | File\#=".$file_step2[-1]." | $line";
                    $filename_new{$warning_no}->[$warnings_new{$warning_no}] = $file_step2[-1];	
                    $check_list_new{$warning_no}->[$warnings_new{$warning_no}] = 0;					
				}
			}			
		}else{
		    $line_cut = $line;
		    $where_v = index($line_cut, ".v");
            $where_sv = index($line_cut, ".sv");
            $where_sdc = index($line_cut, ".sdc");
			$where_vh = index($line_cut, ".vh");

		    if (exists($warnings_new{$warning_no})){ 
		        $warnings_new{$warning_no}++;
		
                if (($where_v != -1) && ($where_vh == -1)){
				    @file = split "/", $line_cut;
                    @file_final = split ' ', $file[-1];
					$content_wof_new{$warning_no}->[$warnings_new{$warning_no}] = $line_cut;
					$warnings_table_new{$warning_no}->[$warnings_new{$warning_no}] = $line_cut; 
					$content_new{$warning_no}->[$warnings_new{$warning_no}] = "Log\#=".$new_file." | Line\#=".$line_no_new." | File\#=".$file_final[0]." | $line";
				    $filename_new{$warning_no}->[$warnings_new{$warning_no}] = $file_final[0];
					$check_list_new{$warning_no}->[$warnings_new{$warning_no}] = 0;
		        }elsif($where_sv != -1){ 
				    @file = split "/", $line_cut;
                    @file_final = split ' ', $file[-1];
					$content_wof_new{$warning_no}->[$warnings_new{$warning_no}] = $line_cut;
					$warnings_table_new{$warning_no}->[$warnings_new{$warning_no}] = $line_cut; 
                    $content_new{$warning_no}->[$warnings_new{$warning_no}] = "Log\#=".$new_file." | Line\#=".$line_no_new." | File\#=".$file_final[0]." | $line";					
                    $filename_new{$warning_no}->[$warnings_new{$warning_no}] = $file_final[0];	
                    $check_list_new{$warning_no}->[$warnings_new{$warning_no}] = 0;					
		        }elsif ($where_sdc != -1){	
                    @file = split ":", $line_cut;			
					$content_wof_new{$warning_no}->[$warnings_new{$warning_no}] = $line_cut;
					$warnings_table_new{$warning_no}->[$warnings_new{$warning_no}] = $line_cut; 
					$content_new{$warning_no}->[$warnings_new{$warning_no}] = "Log\#=".$new_file." | Line\#=".$line_no_new." | File\#=".$file[1]." | $line";
                    $filename_new{$warning_no}->[$warnings_new{$warning_no}] = $file[1];
                    $check_list_new{$warning_no}->[$warnings_new{$warning_no}] = 0;					
		        }else{
				    $content_wof_new{$warning_no}->[$warnings_new{$warning_no}] = $line_cut;
                    $warnings_table_new{$warning_no}->[$warnings_new{$warning_no}] = $line_cut;	
					$content_new{$warning_no}->[$warnings_new{$warning_no}] = "Log\#=".$new_file." | Line\#=".$line_no_new." | File\#=         | $line";
                    $filename_new{$warning_no}->[$warnings_new{$warning_no}] = " "; 
                    $check_list_new{$warning_no}->[$warnings_new{$warning_no}] = 0;					
				}	 
		    }else{
		        $warnings_new{$warning_no} = 0;

                if (($where_v != -1) && ($where_vh == -1)){
				    @file = split "/", $line_cut;
                    @file_final = split ' ', $file[-1];
					$content_wof_new{$warning_no}->[$warnings_new{$warning_no}] = $line_cut;
			        $warnings_table_new{$warning_no}->[$warnings_new{$warning_no}] = $line_cut; 	
					$content_new{$warning_no}->[$warnings_new{$warning_no}] = "Log\#=".$new_file." | Line\#=".$line_no_new." | File\#=".$file_final[0]." | $line";
				    $filename_new{$warning_no}->[$warnings_new{$warning_no}] = $file_final[0];
					$check_list_new{$warning_no}->[$warnings_new{$warning_no}] = 0;
		        }elsif($where_sv != -1){
				    @file = split "/", $line_cut;
                    @file_final = split ' ', $file[-1];
					$content_wof_new{$warning_no}->[$warnings_new{$warning_no}] = $line_cut;
                    $warnings_table_new{$warning_no}->[$warnings_new{$warning_no}] = $line_cut; 
					$content_new{$warning_no}->[$warnings_new{$warning_no}] = "Log\#=".$new_file." | Line\#=".$line_no_new." | File\#=".$file_final[0]." | $line";
                    $filename_new{$warning_no}->[$warnings_new{$warning_no}] = $file_final[0];	
                    $check_list_new{$warning_no}->[$warnings_new{$warning_no}] = 0;					
		        }elsif ($where_sdc != -1){
				    @file = split ":", $line_cut;	
					$content_wof_new{$warning_no}->[$warnings_new{$warning_no}] = $line_cut;
			        $warnings_table_new{$warning_no}->[$warnings_new{$warning_no}] = $line_cut; 
					$content_new{$warning_no}->[$warnings_new{$warning_no}] = "Log\#=".$new_file." | Line\#=".$line_no_new." | File\#=".$file[1]." | $line";
                    $filename_new{$warning_no}->[$warnings_new{$warning_no}] = $file[1];
                    $check_list_new{$warning_no}->[$warnings_new{$warning_no}] = 0;					
		        }else{
				    $content_wof_new{$warning_no}->[$warnings_new{$warning_no}] = $line_cut;
                    $warnings_table_new{$warning_no}->[$warnings_new{$warning_no}] = $line_cut;	
					$content_new{$warning_no}->[$warnings_new{$warning_no}] = "Log\#=".$new_file." | Line\#=".$line_no_new." | File\#=         | $line";
                    $filename_new{$warning_no}->[$warnings_new{$warning_no}] = " ";	
					$check_list_new{$warning_no}->[$warnings_new{$warning_no}] = 0;
				}		
		    }			
		}		
    }	
    $line_no_new++;  
}

while (my $warnings = each %warnings_table_new){
    foreach $items_new (0.. $#{$warnings_table_new{$warnings}}){
	    my $cnt_repeat = 0;
        foreach my $items_check (0.. $#{$warnings_table_new{$warnings}}){
		    $cnt_repeat++ if ($warnings_table_new{$warnings}->[$items_new] eq $warnings_table_new{$warnings}->[$items_check]);			
        }
	    $cnt_repeat_new{$warnings}->[$items_new] = $cnt_repeat;
    }
}

close (NEWF); close (TEMPNEW);               
print "Search and temp file completed.\n";
print "     \"temp_$original_file\" was found with $cnt_ori related messages.\n";
print "     \"temp_$new_file\" was found with $cnt_new related messages.\n";
print "------------------------------------------------------------------------------------------------------\n";
print "Please just wait for a while, the file name of result is difference_list.txt\n"; 
print DIFFLIST "Search and temp file completed.\n";
print DIFFLIST "     \"temp_$original_file\" was found with $cnt_ori related messages.\n";
print DIFFLIST "     \"temp_$new_file\" was found with $cnt_new related messages.\n";
print DIFFLIST "------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------\n";
print DIFFLIST "The following message could not be found\:\n\n";
		
if ($cnt_new >= $cnt_ori){
    my $in_diff = 0;
	my $ind_special_case = 0;
	
    while (my $warnings = each %warnings_table_new){        #read one warning number at a time	
	    while (my $items_new = each @{$warnings_table_new{$warnings}}){      #read different descriptions in sequence for the same warning number
		    my $items_ori = $_;	
            if (exists($warnings_table_ori{$warnings})){ 		                   #determine whether the warning number exists or not 	
				foreach $items_ori (0.. $#{$warnings_table_ori{$warnings}}){
			        if ((($warnings_table_new{$warnings}->[$items_new]) eq ($warnings_table_ori{$warnings}->[$items_ori])) && (($cnt_repeat_new{$warnings}->[$items_new]) eq ($cnt_repeat_ori{$warnings}->[$items_ori]))){
						$check_list_ori{$warnings}->[$items_ori] = 1;
						$check_list_new{$warnings}->[$items_new] = 1;
						$ind_diff = 0;
						$ind_special_case = 0;
						last;
                    }elsif ((($warnings_table_new{$warnings}->[$items_new]) eq ($warnings_table_ori{$warnings}->[$items_ori])) && (($cnt_repeat_new{$warnings}->[$items_new]) ne ($cnt_repeat_ori{$warnings}->[$items_ori]))){ 	
					    if (($content_wof_new{$warnings}->[$items_new]) eq ($content_wof_ori{$warnings}->[$items_ori])){
						    $check_list_ori{$warnings}->[$items_ori] = 1;
						    $check_list_new{$warnings}->[$items_new] = 1;
						    $ind_diff = 0;
							$ind_special_case = 0;
						    last;						
						}else{
						    $check_list_ori{$warnings}->[$items_ori] = 1;
						    $check_list_new{$warnings}->[$items_new] = 1;
						    $ind_diff = 1;	
							$ind_special_case = 1;
						}
		            }elsif (($warnings_table_new{$warnings}->[$items_new]) ne ($warnings_table_ori{$warnings}->[$items_ori])){
				        $ind_diff = 1;
                        $ind_special_case = 0;						
		            }
	            }			
	        }else{
			    $check_list_new{$warnings}->[$items_new] = 1;
                $ind_diff = 1;
                $ind_special_case = 0;				
	        }
            if ($ind_diff eq 1){ 		#if indicator is high, and then the line need to be save and print
                $cnt_diff_all++;
				$cnt_diff_new++;
				if ($ind_special_case eq 0){
				    print DIFFLIST "[" . $cnt_diff_all. "]".$content_new{$warnings}->[$items_new]."\n";
				}else{
				    print DIFFLIST "[" . $cnt_diff_all. "] * | ".$content_new{$warnings}->[$items_new];
					print DIFFLIST "    *: Risk, this message appears abnormally in the same file, although the description excluding the line number is the same.\n\n";
				}
            }else{
	    
            }		
        }	
    }
	$ind_diff = 0;
	$ind_special_case = 0;
	while (my $warnings = each %warnings_table_ori){		
	    while (my $items_ori = each @{$warnings_table_ori{$warnings}}){
            if ($check_list_ori{$warnings}->[$items_ori] == 0){ 		
                if (exists($warnings_table_new{$warnings})){                			
                    foreach $items_new (0.. $#{$warnings_table_new{$warnings}}){				
			            if ((($warnings_table_new{$warnings}->[$items_new]) eq ($warnings_table_ori{$warnings}->[$items_ori])) && (($cnt_repeat_new{$warnings}->[$items_new]) eq ($cnt_repeat_ori{$warnings}->[$items_ori]))){
						    $ind_diff = 0;
							$ind_special_case = 0;
						    last;
                        }elsif ((($warnings_table_new{$warnings}->[$items_new]) eq ($warnings_table_ori{$warnings}->[$items_ori])) && (($cnt_repeat_new{$warnings}->[$items_new]) ne ($cnt_repeat_ori{$warnings}->[$items_ori]))){ 	
					        if (($content_wof_new{$warnings}->[$items_new]) eq ($content_wof_ori{$warnings}->[$items_ori])){
						        $ind_diff = 0;
								$ind_special_case = 0;
						        last;						
						    }else{
						        $ind_diff = 1;
                                $ind_special_case = 1;								
						    }
		                }elsif (($warnings_table_new{$warnings}->[$items_new]) ne ($warnings_table_ori{$warnings}->[$items_ori])){
							$ind_diff = 1;
                            $ind_special_case = 0;							
		                }
	                }									
	            }else{
                    $ind_diff = 1;	
                    $ind_special_case = 0;					
	            }		
                if ($ind_diff eq 1){		# if indicator is high, and then the line need to be save and print
                    $cnt_diff_all++;
				    $cnt_diff_ori++;
					if ($ind_special_case eq 0){
				        print DIFFLIST "[" . $cnt_diff_all . "]" . $content_ori{$warnings}->[$items_ori]."\n";
				    }else{
					    print DIFFLIST "[" . $cnt_diff_all. "] * | ".$content_ori{$warnings}->[$items_ori];
						print DIFFLIST "    *: Risk, this message appears abnormally in the same file, although the description excluding the line number is the same.\n\n";
					}
                }else{
	    
                }
            }			
        }
    }
    print DIFFLIST "Task completed, and \<$cnt_diff_all\> different error / warning messages were found.\n";
	print DIFFLIST "     There are \<$cnt_diff_new\> differences could not be found in \"temp_$original_file\".\n";
	print DIFFLIST "     There are \<$cnt_diff_ori\> differences could not be found in \"temp_$new_file\".\n";
    print DIFFLIST "============================================================================================================================================================================================================\n"; 
	print "------------------------------------------------------------------------------------------------------\n";
    print "Task completed, and \<$cnt_diff_all\> different error / warning messages were found.\n";
	print "     There are \<$cnt_diff_new\> differences could not be found in \"temp_$original_file\".\n";
	print "     There are \<$cnt_diff_ori\> differences could not be found in \"temp_$new_file\".\n";
    print "======================================================================================================\n"; 
	
}else{
    while (my $warnings = each %warnings_table_ori){
        my $ind_diff = 0;
		my $ind_special_case = 0;
		
	    while (my $items_ori = each @{$warnings_table_ori{$warnings}}){ 
		
            if (exists($warnings_table_new{$warnings})){ 		
                foreach $items_new (0.. $#{$warnings_table_new{$warnings}}){				
			        if ((($warnings_table_new{$warnings}->[$items_new]) eq ($warnings_table_ori{$warnings}->[$items_ori])) && (($cnt_repeat_new{$warnings}->[$items_new]) eq ($cnt_repeat_ori{$warnings}->[$items_ori]))){
						$check_list_ori{$warnings}->[$items_ori] = 1;
						$check_list_new{$warnings}->[$items_new] = 1;
						$ind_diff = 0;
						$ind_special_case = 0;
						last;
                    }elsif ((($warnings_table_new{$warnings}->[$items_new]) eq ($warnings_table_ori{$warnings}->[$items_ori])) && (($cnt_repeat_new{$warnings}->[$items_new]) ne ($cnt_repeat_ori{$warnings}->[$items_ori]))){ 	
					    if (($content_wof_new{$warnings}->[$items_new]) eq ($content_wof_ori{$warnings}->[$items_ori])){
						    $check_list_ori{$warnings}->[$items_ori] = 1;
						    $check_list_new{$warnings}->[$items_new] = 1;
						    $ind_diff = 0;
							$ind_special_case = 0;
						    last;						
						}else{
						    $check_list_ori{$warnings}->[$items_ori] = 1;
						    $check_list_new{$warnings}->[$items_new] = 1;
						    $ind_diff = 1;
                            $ind_special_case = 1;							
						}
		            }elsif (($warnings_table_new{$warnings}->[$items_new]) ne ($warnings_table_ori{$warnings}->[$items_ori])){
				        $ind_diff = 1;
                        $ind_special_case = 0;						
		            }
	            }									
	        }else{
			    $check_list_ori{$warnings}->[$items_ori] = 1;
                $ind_diff = 1;	
                $ind_special_case = 0;				
	        }	
            if ($ind_diff eq 1){		# if indicator is high, and then the line need to be save and print
                $cnt_diff_all++;
				$cnt_diff_ori++;
				if ($ind_special_case eq 0){
				    print DIFFLIST "[" . $cnt_diff_all . "]" . $content_ori{$warnings}->[$items_ori]."\n";
				}else{
				    print DIFFLIST "[" . $cnt_diff_all. "] * | ".$content_ori{$warnings}->[$items_ori];
					print DIFFLIST "    *: Risk, this message appears abnormally in the same file, although the description excluding the line number is the same.\n\n";
				}
            }else{
	    
            }				
        }
    }
    $ind_diff = 0;
    while (my $warnings = each %warnings_table_new){        #read one warning number at a time	
	    while (my $items_new = each @{$warnings_table_new{$warnings}}){      #read different descriptions in sequence for the same warning number
		    if ($check_list_new{$warnings}->[$items_new] == 0){
		        my $items_ori = $_;	
                if (exists($warnings_table_ori{$warnings})){ 		                   #determine whether the warning number exists or not 	
				    foreach $items_ori (0.. $#{$warnings_table_ori{$warnings}}){
			            if ((($warnings_table_new{$warnings}->[$items_new]) eq ($warnings_table_ori{$warnings}->[$items_ori])) && (($cnt_repeat_new{$warnings}->[$items_new]) eq ($cnt_repeat_ori{$warnings}->[$items_ori]))){
						    $ind_diff = 0;
							$ind_special_case = 0;	
						    last;
                        }elsif ((($warnings_table_new{$warnings}->[$items_new]) eq ($warnings_table_ori{$warnings}->[$items_ori])) && (($cnt_repeat_new{$warnings}->[$items_new]) ne ($cnt_repeat_ori{$warnings}->[$items_ori]))){ 	
					        if (($content_wof_new{$warnings}->[$items_new]) eq ($content_wof_ori{$warnings}->[$items_ori])){
						        $ind_diff = 0;
								$ind_special_case = 0;	
						        last;						
						    }else{					
						        $ind_diff = 1;	
								$ind_special_case = 1;	
						    }
		                }elsif (($warnings_table_new{$warnings}->[$items_new]) ne ($warnings_table_ori{$warnings}->[$items_ori])){
				            $ind_diff = 1;	
                            $ind_special_case = 0;								
		                }
	                }			
	            }else{
                    $ind_diff = 1;	
                    $ind_special_case = 0;					
	            }
                if ($ind_diff eq 1){ 		# if indicator is high, and then the line need to be save and print
                    $cnt_diff_all++;
				    $cnt_diff_new++;
					if ($ind_special_case eq 0){
				        print DIFFLIST "[" . $cnt_diff_all . "]".$content_new{$warnings}->[$items_new]."\n";
				    }else{
					    print DIFFLIST "[" . $cnt_diff_all. "] * | ".$content_new{$warnings}->[$items_new];
						print DIFFLIST "    *: Risk, this message appears abnormally in the same file, although the description excluding the line number is the same.\n\n";
					}
                }else{
	    
                }
            }			
        }	
    }	
    print DIFFLIST "Task completed, and \<$cnt_diff_all\> different error / warning messages were found.\n";
	print DIFFLIST "     There are \<$cnt_diff_new\> differences could not be found in \"temp_$original_file\".\n";
	print DIFFLIST "     There are \<$cnt_diff_ori\> differences could not be found in \"temp_$new_file\".\n";
    print DIFFLIST "============================================================================================================================================================================================================\n"; 
	print "------------------------------------------------------------------------------------------------------\n";
    print "Task completed, and \<$cnt_diff_all\> different error / warning messages were found.\n";
	print "     There are \<$cnt_diff_new\> differences could not be found in \"temp_$original_file\".\n";
	print "     There are \<$cnt_diff_ori\> differences could not be found in \"temp_$new_file\".\n";
    print "======================================================================================================\n";
}

$time_now = localtime;
print "End Time : $time_now" . "\n";
print DIFFLIST "End Time : $time_now" . "\n";
close (DIFFLIST);