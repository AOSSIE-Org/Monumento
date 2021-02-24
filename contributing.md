# Contributing

### Workflow

We are using the [Feature Branch Workflow (also known as GitHub Flow)](https://guides.github.com/introduction/flow/),
and prefer delivery as pull requests.

Create a feature branch:

```sh
git checkout -b branch
```


### Commits

-   Make sure your PR's description contains Gitlab's special keyword references that automatically close the related issue when the PR is merged. 
-   When you make very minor changes to a PR of yours (like for example fixing a failing Travis build or some small style corrections or minor changes requested by reviewers) make sure you squash your commits afterward so that you don't have an absurd number of commits for a very small fix. (Learn how to squash at [https://davidwalsh.name/squash-commits-git](https://davidwalsh.name/squash-commits-git) )
-   When you're submitting a PR for a UI-related issue, it would be really awesome if you add a screenshot of your change or a link to a deployment where it can be tested out along with your PR. It makes it very easy for the reviewers and you'll also get reviews quicker.

-   When reporting an issue/ making a MR, use the issue/ MR template for better understanding of changes.  

### Git commit conventions


We accept commits as per [Conventional Changelog](https://github.com/ajoslin/conventional-changelog):

```none
<type>(<scope>): <subject>
```

Example:

```none
docs(CONTRIBUTE.md): add contributing conventions
```

The allowed ```<types>``` are :

*   **feat**: A new feature
*   **fix**: A bug fix
*   **docs**: Documentation only changes
*   **style**: Changes that do not affect the meaning of the code (white-space, formatting, missing semi-colons, newline, line endings, etc)
*   **perf**: A code change that improves performance
*   **test**: Adding missing tests

### Feature Requests and Bug Reports

When you file a feature request or when you are submitting a bug report to the [issue tracker](https://gitlab.com/aossie/aossie-scholar/issues), make sure you add steps to reproduce it. Especially if that bug is some weird/rare one.

### Before Creating a MR request

* make sure to run ```flutter format lib``` in 'monumento_module' directory to format your code.


### Join the development

-   Before you join the development, please set up the project on your local machine, run it and go through the application completely. Press on any button you can find and see where it leads to. Explore. (Don't worry ... Nothing will happen to the app or to you due to the exploring :wink: Only thing that will happen is, you'll be more familiar with what is where and might even get some cool ideas on how to improve various aspects of the app.)
-   If you would like to work on an issue, drop in a comment at the issue. If it is already assigned to someone, but there is no sign of any work being done, please feel free to drop in a comment so that the issue can be assigned to you if the previous assignee has dropped it entirely.



