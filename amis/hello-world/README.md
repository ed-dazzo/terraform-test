## Build
Run `build.sh` to create a new version of the AMI.

The packerfile will incorporate the cloudformation agent configuration (“agent-config.json”).

The deployment script was designed to grab the necessary variables and supply them to the packer command.
1. Fetches the aws user using “aws sts get-caller-identity”. This value is placed in the aws_user tag. Though only one person works on the project now, if the team were to grow, we might need to know who built a given ami if the revision is dirty or the branch only exists locally.
2. Fetches the git revision. This value is placed in the git_revision tag. If there are uncommitted files, it will append the string “-dirty” to the value. If need be, we can checkout the exact revision used to build the ami. We might also be able to get insight into what files were dirty from the author (stored in aws_user).
3. Fetches the git branch name. This value is placed in the git_branch tag. This also makes it easier to track down the exact version of code that built the ami, if need be.

Each ami will have a date string appended to its name in the format of YearMonthDayHourMinuteSecond.


#Deploy
In order to activate the ami, you must remove the "env" key (where the value is "prod") from the current production ami and create it on the new production AMI.
