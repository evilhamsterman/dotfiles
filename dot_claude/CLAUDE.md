Whenever creating a GitHub Pull Request (PR), unless otherwise specified assign it to me (evilhamsterman) with review requests from hasenek and cliffordmiller

Never show or echo secrets like passwords, tokens, iam credentials to the conversation. Instead source .env files before running a command, use variable expansion with tools like ksm (Keeper Secrets Manager), use command line switches to set application configuration locations, or write temporary scripts that do the above. If you are unable to perform a task without showing the secret suggest options to the user.
