#!/bin/bash

while true; do
    echo "1. Add all users from a source group to a destination group"
    echo "2. View list of all groups"
    echo "3. Exit"
    read -p "Enter choice: " CHOICE

    case "$CHOICE" in
        1)
            # ask user if they want to enter a username to find in all groups
            read -p "Do you want to enter a username to find in all groups? (y/n) " ENTER_USERNAME

            # if user wants to enter a username, prompt for the username
            if [[ "$ENTER_USERNAME" == "y" ]]; then
                read -p "Enter username to find in all groups: " USERNAME

                # check if the user exists
                if ! id "$USERNAME" >/dev/null 2>&1; then
                    echo "User $USERNAME does not exist"
                    continue
                fi

                # ask user if they want to view the list of groups for the specified user
                read -p "Do you want to view the list of groups for $USERNAME? (y/n) " VIEW_GROUPS_FOR_USER

                # if user wants to view the list of groups for the specified user, display it and continue
                if [[ "$VIEW_GROUPS_FOR_USER" == "y" ]]; then
                    groups "$USERNAME"
                    continue
                fi
            fi

            # prompt user to enter source and destination groups
            read -p "Enter source group: " SOURCE_GROUP
            read -p "Enter destination group: " DESTINATION_GROUP

            # loop through each user in the source group
            for USER in $(getent group "$SOURCE_GROUP" | cut -d: -f4 | sed 's/,/ /g'); do
                # check if the user is already in the destination group
                if id -nG "$USER" | grep -qw "$DESTINATION_GROUP"; then
                    echo "$USER is already in $DESTINATION_GROUP"
                else
                    # add the user to the destination group
                    sudo usermod -a -G "$DESTINATION_GROUP" "$USER"
                    echo "Added $USER to $DESTINATION_GROUP"
                fi
            done
            ;;
        2)
            # ask user if they want to view the list of all groups
            read -p "Do you want to view the list of all groups? (y/n) " VIEW_ALL_GROUPS

            # if user wants to view the list of all groups, display it
            if [[ "$VIEW_ALL_GROUPS" == "y" ]]; then
                getent group | cut -d: -f1 | sort
            fi
            ;;
        3)
            exit
            ;;
        *)
            echo "Invalid choice"
            ;;
    esac
done



# Here's how it works:

# The script uses a while loop to implement a menu that allows the user to choose between three options: adding users from a source group to a destination group, viewing the list of all groups, and exiting the script.

# When the user chooses option 1, the script prompts for a username to find in all groups, if desired, and prompts for the source and destination groups. It then loops through each user in the source group, checks if the user is already in the destination group, and adds the user to the destination group if they are not.

# When the user chooses option 2, the script prompts whether the user wants to view the list of all groups. If the user chooses to view the list of all groups, the script displays it using the getent group command, which retrieves information about groups from the system's group database.

# When the user chooses option 3, the script exits.

# If the user enters an invalid choice, the script displays an error message.

# Overall, the menu provides a more user-friendly interface for the script, allowing the user to choose the task they want to perform and providing prompts for necessary information.