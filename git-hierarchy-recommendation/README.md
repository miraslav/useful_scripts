Here's a step-by-step guide for creating a new project with Git, including creating two branches (main and nonprod):
===
It will be abstract info, but I don't know that write me here. If you have an idea, please to make pull request!

## Paper Information
  - Title: Default project
  - Author: Someone else
  - Ticket: [Here's a link](https://github.com/atlet99/Useful_scripts/tree/main/git-hierarchy-recommendation)
    - Ticket short description: Here's short info about project and IT Owner Division


##  Tips for create default project
  - Create a new directory for your project (your name instead of project-name):
    ```
    mkdir project-name
    ```
  - Navigate into the new directory:
    ```
    cd project-name
    ```
  - Initialize Git in the directory:
    ```
    git init
    ```
  - Create the main branch (which will serve as the default branch):
    ```
    git checkout -b main
    ```
  - Create the nonprod branch:
    ```
    git branch nonprod
    ```
  - Switch back to the main branch:
    ```
    git checkout main
    ```
  - Create a new file called README.md:
    ```
    touch README.md
    ```
  - Open the README.md file in your preferred text editor (like VIM, NANO, VSCode and etc) and add a brief description of the project and any instructions for getting started. Usually, we have title and short definitions about project.
  - To check the status of your repository and see which files have been modified, added, or deleted, use the git status command:
    ```
    git status
    ```
  - To view the differences between the working directory and the staging area, use the git diff command:
    ```
    git diff
    ```
  - Add the README.md file to Git:
    ```
    git add README.md
    ```
  - Commit the changes:
    ```
    git commit -m "Initial commit with README.md"
    ```
  - Add the remote repository to your local Git repository, also your link name (like an alias) maybe used instead of origin:
    ```
    git remote add origin <repository-url>
    ```
  - Verify that the remote repository was added successfully:
    ```
    git remote -v
    ```
  - Push the changes to the main branch:
    ```
    git push -u origin main
    ```
  - Push the nonprod branch to the remote repository:
    ```
    git push -u origin nonprod
    ```
  - To view information about the last commit in your Git repository, you can use the git log command:
    ```
    git log
    ```
  - If you only want to see the most recent commit, you can use the git log -1 command:
    ```
    git log -1
    ```
  - You can also use the git show command to view information about the most recent commit:
    ```
    git show
    ```
  - To create a new tag in Git, you can use the git tag command, followed by the name of the tag and the commit hash that you want to tag. For example, to create a new tag called "v1.0" at the most recent commit in your repository, you can use the following command:
    ```
    git tag v1.0 HEAD
    ```
  - To push the "v1.0" tag to the remote repository, you can use the following command:
    ```
    git push origin v1.0
    ```
  - You can also list all of the tags in your repository using the git tag command:
    ```
    git tag
    ```


## A little bit about best practices for README.md files

  - Use clear, concise language to describe your project and its purpose.
  - Include any necessary setup instructions or prerequisites for getting started with the project.
  - Use headings and bullet points to organize information and make it easier to read.
  - Include any relevant links or resources, such as documentation, tutorials, or other projects.
  - Use tags or badges to indicate the status of the project (e.g. "in development", "stable", "deprecated", etc.).
  - Keep the README.md file up-to-date as the project evolves and changes.