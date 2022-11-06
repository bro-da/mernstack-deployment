#!/bin/bash  
  
# Read the user input for ip address and website name 

confirm() {
    # call with a prompt string or use a default
    read -r -p "${1:-Are you sure? [y/N]} " response
    case "$response" in
        [yY][eE][sS]|[yY]) 
            true
            ;;
        *)
            false
            ;;
    esac
}
  
echo "Enter aws ip-address: "  
read IP_ADDR  

echo  
echo "Enter the website name: "  
read WEB_NAME  
echo "$WEB_NAME is the web_site name" 
echo "The ip address of you soon to be web app is $IP_ADDR"  

if confirm; then
    echo "continuing"
  fi



