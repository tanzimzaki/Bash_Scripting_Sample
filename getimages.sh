#!/bin/bash

#Tanzim_Zaki_SAKLAYEN


# execute the program by enabling chmod 777 permission

declare -a pictures

function ask_directory(){                 # function program executed to search/create directory in the system  
    
    if [[ -z $directory ]]              #  if statement is executed 
    then
        read -p "Please insert the directory to save pictures: " directory     # user is prompt to insert the directory to save the pictures

        if ! [[ -d "$directory" ]]         # if statement is executed to make a new directory if no directory exists 
        then
            echo "....manufacturing $directory..."     # a loading bar that shows the directory is being created
            mkdir "$directory"                       
        fi
    fi
}

function Retrieve_file(){                      # function program executed to Retrieve pictures from the internet
    picture_name="$1"                           # $1 variable set for 'picture_name'

    if [[ -f "$directory/$picture_name" ]]       # if statement is executed to search if the chosen picture is present in the direcorty or not 
    then
        read -p "$picture_name exists. Do you wish to overwrite (1) it or skip (2) the picture? : " picture_exist   # a message will be echoed in the terminal if the file exists - user will be prompt to overwrite or skip the file
        if [[ $picture_exist == "S"  || $picture_exist == "s" ]]                         # if statement is executed 
        then
            return
        fi
    fi
    picture_number="${picture_name%%.*}"          # the 'picture_number' is set to a specific variable

    picture_link="https://secure.ecu.edu.au/service-centres/MACSC/gallery/ml-2018-campus/$picture_name"         # 'picture_link' is set to extract the pictures from the weblink
    file_size=$(curl -sI "$picture_link" | grep -i Content-Length | awk '{printf "%.2f", $2/1024}' )            # the size of the file is coded with the help of curl, grep, and awk command to extract the information from the weblink 
    totalFileSize=totalFileSize+file_size
    echo -n "....Retrieving $picture_number, with the file name $picture_name, with a file size of $file_size Kilobytes..."  # a loading bar that shows a certain picture is being Retrieveed (with file number and size) from the weblink
    wget --quiet "$picture_link" -P "$directory"       # wget command executed to transfer the Retrieveed picture to the directory 
    echo "File has been Retrieveed successfully"      # an echoed message in the terminal that the pircture has been Retrieveed  
}

function chosen_file(){                                          # function program executed to select a picture
      read -p "Insert last 4 digit of the file name: " last_digits        # user is prompt to insert last 4 digits of the picture 
        echo ".... Searching the file ..."          # a loading bar that is echoed to the terminal stating the file is being searched
        for picture in ${pictures[@]}               # for loop is initiated 
        do
            if [[ $picture =~ DSC.$last_digits ]]    # if statement is executed
            then                                     # then statement is executed if the chosen file is found/discovered 
                found=1
                chosen_file=$picture               
                break
            fi
        done

        if [[ -z $chosen_file ]]        # if statement is executed
        then                             # then statement is executed if the chosen file is NOT found/discovered 
            echo "The file is not found."
            continue
        fi

        picture_name="$chosen_file"

        if [[ -f "$directory/$picture_name" ]]          # if statement is executed
        then
            read -p "$picture_name is already present. Do you wish to overwrite (1) it or skip(2) the file? : " picture_exist   # a message will be echoed in the terminal if the file exists - user will be prompt to overwrite or skip the file
            if [[ $picture_exist == "S"  || $picture_exist == "s" ]]        # if statement is executed 
            then
                return
            fi
        fi
        picture_number="${picture_name%%.*}"   # the 'picture_number' is set to a specific variable

        picture_link="https://secure.ecu.edu.au/service-centres/MACSC/gallery/ml-2018-campus/$picture_name"       # 'picture_link' is set to extract the pictures from the weblink
        file_size=$(curl -sI "$picture_link" | grep -i Content-Length | awk '{printf "%.2f", $2/1024}' )     # the size of the file is coded with the help of curl, grep, and awk command to extract the information from the weblink 
        totalFileSize=totalFileSize+file_size
        echo -n ".... Retrieving $picture_number, with the file name $picture_name, with a file size of $file_size Kilobytes..."   # a loading bar that shows a certain picture is being Retrieveed (with file number and size) from the weblink
        wget --quiet "$picture_link" -P "$directory"           # wget command executed to transfer the Retrieveed picture to the directory
        echo "File has been Retrieveed successfully"   # an echoed message in the terminal that the pircture has been Retrieveed  
}

function input_selected_files(){                     # function program executed to select a picture
    read -p "Insert starting range (last 4 digits): " starting_range   # user is prompt to enter a starting range of last 4 digits
    while ! [[ $starting_range =~ ^[0-9]{4}$ ]]         # while loop is initiated of the starting range 
    do                                                   # a loop will be executed as showned below if the user prompts a mistake 
        echo "Invalid digits - please enter the last 4 digits of starting range." 
        read -p "Insert starting range (last 4 digits): " starting_range
    done


    read -p "Insert ending range (last 4 digits): " ending_range  # user is prompt to enter a ending range of last 4 digits
    while ! [[ $ending_range =~ ^[0-9]{4}$ ]]              # while loop is initiated of the ending range
    do                                                # a loop will be executed as showned below if the user prompts a mistake 
        echo "Invalid digits, please Insert LAST 4 DIGITS of starting picture."
        read -p "Insert ending range (last 4 digits): " ending_range
    done

    selected_files=()
    echo "... Searching pictures in the chosen range..." # a loading bar will be echoed in the terminal stating the search execution of the chosen range 
    for picture in ${pictures[@]}                       # for loop is executed 
    do                                     # a loop will be executed as showned below - to get the picture number and validating the last 4 digits of the chosen picture 
        
        picture_number=${picture%%.*}
       
        if [ ${picture_number:(-4)} -ge $starting_range ] && [ ${picture_number:(-4)} -le $ending_range ]
        then
            
            selected_files+=("$picture")            # an attachement into the 'selected_files' array
        fi
    done

}


function Retrieve_files_in_range(){  # function program executed to Retrieve a picture in a range
    
    input_selected_files

    [[ ${#selected_files[@]} -eq 0 ]] && echo "No thumbnail found in the range $starting_range-$ending_range" && return  # a coomand has been set to meet the criteria of range of selected pictures from the weblink
    for picture in ${selected_files[@]}   # for loop initiated 
    do                                    # a loop will be executed to Retrieve the pictures with the criteria as mentioned so far (codes are shown below)
        picture_name="$picture"

        if ! [[ -f "$directory/$picture_name" ]]
        then
            picture_number="${picture_name%%.*}"

            picture_link="https://secure.ecu.edu.au/service-centres/MACSC/gallery/ml-2018-campus/$picture_name"
            file_size=$(curl -sI "$picture_link" | grep -i Content-Length | awk '{printf "%.2f", $2/1024}' )
            totalFileSize=totalFileSize+file_size
            echo -n "Retrieveing $picture_number, with the file name $picture_name, with a file size of $file_size Kilobytes..."
            wget --quiet "$picture_link" -P "$directory"
            echo "File has been Retrieveed successfully"
        fi
        
    done

}

function Retrieve_specific_number_pictures_range(){             # function program executed to Retrieve a picture in a specific range                
    
    input_selected_files
    [[ ${#selected_files[@]} -eq 0 ]] && echo "No thumbnail found in the range $starting_range-$ending_range" && return   # a command has been set to meet the criteria of range of selected pictures from the weblink
    
   
    read -p "How many pictures you wish to Retrieve? : " count_picture    # echoing the number of pictures to be Retrieveed in the terminal

    
    while ! [[ $count_picture =~ ^[0-9]+$ && $count_picture -le ${#selected_files[@]}  ]]          # validating if the input is not a number or input is not less than or equal to the pictures in the specified range
    do
        
        echo -e "Not a valid number, there can be maximum ${#selected_files[@]} pictures in the specified range. Insert a number in a range 0-${#selected_files[@]}."  # echoing to the terminal if the number is not valid specifying a maximum amount of pictures in a range
       
        read -p " Please insert again how many pictures you wish to Retrieve? : " count_picture    # the user is prompt again to insert a valid input to meet the criteria 
    done
    

    selected_files_mixup=($(shuf -e ${selected_files[@]}))   

    for ((i=0;i<$count_picture;i++))                               # for loop inititated to select certain pictures a user might prompt 
    do
 
        picture_name="${selected_files_mixup[i]}"

        if ! [[ -f "$directory/$picture_name" ]]                 # if statement directing for specific name of pictures and the chosen directory 
        then
            picture_number="${picture_name%%.*}"

            picture_link="https://secure.ecu.edu.au/service-centres/MACSC/gallery/ml-2018-campus/$picture_name"            # web link of the chosen pictures a user is prompt to Retrieve 
            file_size=$(curl -sI "$picture_link" | grep -i Content-Length | awk '{printf "%.2f", $2/1024}' )                   # the size of the file is coded with the help of curl, grep, and awk command to extract the information from the weblink 
            totalFileSize=totalFileSize+file_size
            echo -n "....Retrieving $picture_number, with the file name $picture_name, with a file size of $file_size Kilobytes..."        # the echoed message will display in the terminal 
            wget --quiet "$picture_link" -P "$directory"            # wget command has been initiated to Retrieve the pictures and transfer to the chosen directory 
            echo "File has been Retrieveed successfully"    
        fi
        
        
    done

}

Retrieve_all(){                                  # inititating to Retrieve all files
    for picture in "${pictures[@]}"              # for loop inititated to select all pictures 
    do
        picture_name="$picture"             # 'picture_name' variable has been set to '$picture' 

        if ! [[ -f "$directory/$picture_name" ]]         # if-then statement has been executed to look for directory of a particular picture 
        then
            picture_number="${picture_name%%.*}"

            picture_link="https://secure.ecu.edu.au/service-centres/MACSC/gallery/ml-2018-campus/$picture_name"    # web link of the chosen pictures a user is prompt to Retrieve 
            file_size=$(curl -sI "$picture_link" | grep -i Content-Length | awk '{printf "%.2f", $2/1024}' )     # the size of the file is coded with the help of curl, grep, and awk command to extract the information from the weblink 
            totalFileSize=totalFileSize+file_size
            echo -n "Retrieveing $picture_number, with the file name $picture_name, with a file size of $file_size Kilobytes..."             # the echoed message will display in the terminal 
            wget --quiet "$picture_link" -P "$directory"                             # wget command has been initiated to Retrieve the pictures and transfer to the chosen directory 
            echo "File has been Retrieveed successfully"
        fi
        
    done
}

loadhtml(){
    
    curl -s "https://www.ecu.edu.au/service-centres/MACSC/gallery/gallery.php?folder=ml-2018-campus" > temp.txt

    cat temp.txt | grep -Eo '(https)://[^"]+' | grep ".jpg" | sed 's/.*\///' > pictureList.txt  
    
    pictures=($(cat pictureList.txt))
    
    picture_array_len=${#pictures[@]} 
    
    
}

main(){
    loadhtml                           # user will be prompt to choose either options to continue (shown below)
    options="Click the either options:                  
    1- Retrieve a specific thumbnail by the last 4 digits of the file name
    2- Retrieve pictures in a range by the last 4 digits of the file name (example: starting range of
    0206 and ending range of 0259)
    3- Retrieve a specified number of pictures, as an example, if the user inserts the numeral 5, 5 random
    pictures in the specified range of DSC00200 to DSC00231 will be retrieved
    4- Retrieve ALL thumbnails
    5- Clean up ALL files
    6- Exit Program
    "
    Retrieve_url="https://secure.ecu.edu.au/service-centres/MACSC/gallery/ml-2018-campus"  

    echo "$options"        # list of options will be echoed in the terminal (the options are listed above)

    read -p "Option: " selected_option                 # user will be prompt to read the options selected
    while [[ "$selected_option" -ne 6 ]]              # while loop has been executed to generate numerous options as mentioned below (furhter if-else-elif statements are shown below to execute the criteria of the assignment)
    do
        if [[ "$selected_option" -eq 1 ]]
        then
            ask_directory
            chosen_file

        elif [[ "$selected_option" -eq 2 ]]
        then
            ask_directory
            Retrieve_files_in_range

        elif [[ "$selected_option" -eq 3 ]]
        then
            ask_directory
            Retrieve

        elif [[ "$selected_option" -eq 4 ]]
        then
            ask_directory
            Retrieve_all

        elif [[ "$selected_option" -eq 5 ]]
        then
            shopt -s extglob
            echo $(rm -rf !(getpictures.sh))        # the command is executed to remove the file
        else
            echo "Option is invalid."                    # the option chosen by the user is invalid. A loop will be inititated to either exit the program or try again. 
        fi

        echo "$options"
        read -p "Option: " selected_option
    done

}

main