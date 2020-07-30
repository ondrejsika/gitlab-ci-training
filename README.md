[Ondrej Sika (sika.io)](https://sika.io) | <ondrej@sika.io>

# Gitlab CI Training

    Ondrej Sika <ondrej@ondrejsika.com>
    https://github.com/ondrejsika/gitlab-ci-training

## Agenda

- [What is CI](#what-is-ci)
- [Setup Gitlab CI](#setup-gitlab-ci)
- [CI Jobs](#ci-jobs)
- [Deployments from CI](#deployments-from-ci)
- [Example Project Pipeline](#example-project-pipeline)

## What is CI

### Git

Git is a version control system for tracking changes in computer files and coordinating work on those files among multiple people.

### Gitlab

From project planning and source code management to CI/CD and monitoring, GitLab is a complete DevOps platform, delivered as a single application.

### CI

In software engineering, continuous integration is the practice of merging all developer working copies to a shared mainline several times a day.

### Usage of CI

Automatization of:

- build process
- testing - unit tests, integration tests, linting, formating
- deployment - dev, staging, production

### Gitlab CI Features

- Integration into Gitlab (CE & EE)
- Versioned (YAML file in repository)
- Easy to scale
- Docker & Kubernetes support

### Gitlab CI Architecture

![gitlab-ci-architecture](./gitlab-ci-architecture.png)

### Gitlab Runner

Runs on every platform - Linux, Mac, Windows, Docker, Kubernetes

How to install & configure:

- https://docs.gitlab.com/runner/install/
- https://docs.gitlab.com/runner/register/

My scripts to bootstrap Gitlab Runner in Docker: https://github.com/ondrejsika/gitlab-ci-runner

## Setup Gitlab CI

### Demo Gitlab

#### Setup

You can setup Gitlab on Digital Ocean & Cloudflare using Terraform

<https://github.com/ondrejsika/terraform-demo-gitlab>

#### Login

- Gitlab - <https://gitlab.sikademo.com>
- User - `demo`
- Password - `asdfasdf`

### Install Runners into Gitlab

Go to [**Admin** -> **Runners**](https://gitlab.sikademo.com/admin/runners)

And **Set up a shared Runner manually**

## CI Jobs

### Gitlab CI YAML

Configuration of everything aroud Gitlab CI is stored inside Git repository in file `.gitlab-ci.yml`

If you don't know YAML format, check out this simple YAML tutorial - <https://learnxinyminutes.com/docs/yaml/>

Here is a Gitlab CI YAML reference - <https://docs.gitlab.com/ce/ci/yaml/README.html>

### First Job

Create new projet and create there file `.gitlab-ci.yml` with following content:

```yaml
# .gitlab-ci.yml

job:
  script: echo Hello World!
```

Push to Gitlab and check it out.

### Job

Jobs are smalles units which can be executed by Gitlab CI. Here are samples of common job configurations.

Jobs are top level object in Gitlab CI YAML files instead of [few keywords](https://docs.gitlab.com/ce/ci/yaml/README.html#unavailable-names-for-jobs). Keywords are: `image`, `services`, `stages`, `types`, `before_script`, `after_script`, `variables`, `cache`

#### Script

Every job require `script` - it's a shell scrip which will be executed by job. Script can be string or list of strings.

```yaml
# .gitlab-ci.yml

job1:
  script: echo Hello World!
job2:
  script:
    - echo Hello World!
    - echo Ahoj Svete!
```

#### Stages

You can define order of jobs by stages. You can define stages and their order. Jobs in same stage run in parallel and after CI finishes all job in stage, then start jobs from next.

```yaml
# .gitlab-ci.yml

stages:
  - build
  - test

build:
  stage: build
  script: echo Build!

test1:
  stage: test
  script: echo Test1!

test2:
  stage: test
  script: echo Test2!
```

#### Before & After Script

You can define script which will be executed befor and after job script. You can define those script globally or per job.

```yaml
# .gitlab-ci.yml

before_script:
  - echo Global before

after_script:
  - echo Global after

job1:
  script: echo Job1!

job2:
  script: echo Job2! && false

job3:
  before_script:
    - echo Local before
  after_script: []
  script: echo Job3!
```

#### When

You can control when do you want run your jobs. By default, jobs are executed automatically when previous stage succeed. You can specify another condition, you can run jobs manually, always or on error.

```yaml
# .gitlab-ci.yml

test:
  script: echo Run test ...

deploy:
  script: echo Run deploy ...
  when: manual

diagnostics:
  script: echo Run diagnostics ...
  when: on_failure

reporting:
  script: echo Run CI reporting ...
  when: always
```

#### Allow Failure

You can specify flag `allow_failure` to `true`, job can fail but pipeline will succeed.

```yaml
# .gitlab-ci.yml

test:
  script: echo test ... && false
  allow_failure: true
```

Manual jobs are allowed to fail by default, if you want to disallow failure, you have to set `allow_failure` to `false`.

```yaml
# .gitlab-ci.yml

test:
  when: manual
  script: echo test ... && false

test2:
  when: manual
  script: echo test ... && false
  allow_failure: false
```

#### Only & Except

You can specify another condition when you can run jobs. You can specify branches and tags on which you want to run your jobs or not.

```yaml
# .gitlab-ci.yml

test1:
  script: echo Test1 ...
  # use regexp
  only:
    - /^issue-.*$/

test2:
  script: echo Test2 ...
  # use special keyword
  except:
    - branches
```

Full reference here - <https://docs.gitlab.com/ce/ci/yaml/README.html#onlyexcept-basic>

#### Only Changes

You can run job when are changes is some files. That's great for monorepos.

```yaml
# .gitlab-ci.yml

Build A:
  script: echo Cuild A ...
  only:
    changes:
      - a/**

Build B:
  script: echo Cuild B ...
  only:
    changes:
      - b/**
```

- Example monorepo with only changes - <https://github.com/ondrejsika/ondrejsikawebs>
- Full Reference - <https://docs.gitlab.com/ce/ci/yaml/README.html#onlychangesexceptchanges>

### Variables

Gitlab CI offers you lots of usable variables like:

- `CI`
- `CI_PROJECT_NAME`, `CI_PROJECT_PATH_SLUG`
- `CI_COMMIT_REF_NAME`, `CI_COMMIT_REF_SLUG`
- `CI_COMMIT_SHA`, `CI_COMMIT_TAG`
- `CI_PIPELINE_ID`, `CI_JOB_ID`
- `CI_REGISTRY`, `CI_REGISTRY_USER`, `CI_REGISTRY_PASSWORD`

See all varibles: <https://docs.gitlab.com/ce/ci/variables/predefined_variables.html#variables-reference>

You can define own variables in:

- Group CI Settings
- Project CI Setting
- Globally in CI YAML
- In job in CI YAML

You can define varible in **Settings -> CI / CD -> Variables**. Same for project and group. You can define for example connection to your Kubernetes cluster, AWS credentials, ...

Variables can be defined as:

- **Masked** - Value is hidden from the CI output. You probably dont want to show any credential, even development one.
- **Protected** - Protected variable appears only in jobs on protected branches. If developers can't push to protected branches, there have no chance to get production deployment keys or deploy to production. After code has been merged to master (protected), then protected variables appears and you can deploy to production.

Example job:

```yaml
# .gitlab-ci.yml

variables:
  XXX_GLOBAL: global

job1:
  script: env | grep XXX

job2:
  variables:
    XXX_LOCAL: local
  script: env | grep XXX
```

You can also create variables from variables, but you can't use varible defined in same place. If you create global variabl, you can use only CI default variables and custom variables setted up in project or group CI settings.

```yaml
# .gitlab-ci.yml

variables:
  IMAGE: $CI_REGISTRY_IMAGE:$CI_COMMIT_REF_SLUG
```

### Cache

Cache is used to specify a list of files and directories which should be cached between jobs. You can only use paths that are within the project workspace.

If cache is defined outside the scope of jobs, it means it is set globally and all jobs will use that definition.

You can specify cache key for better caching of different branches

```yaml
# .gitlab-ci.yml

job:
  cache:
    key: ${CI_COMMIT_REF_SLUG}
    paths:
      - now
  script:
    - date >> now
    - cat now
```

More about caches: <https://docs.gitlab.com/ce/ci/caching/index.html>

#### Git Clean Flags

Instead of cache, you can use faster option how to keep some data in repository. If you are using cache, your repository is cleaned by `git clean -ffdx`, which means remove all ignored & untracked files and directories. Then your cache is downloaded and extracted into your working directory. This way is not fastest way if you have thousands files in cache (like node modules, for example).

Instead of cache, you can specify variable `GIT_CLEAN_FLAGS` and use own git clean arguments. If you want to ignore node modules from git clean, you can set `-ffdx -e node_modules`.

```yaml
# .gitlab-ci.yml

job:
  variables:
    GIT_CLEAN_FLAGS: -ffdx -e node_modules
  script:
    - yarn
    - yarn build
```

### Artifacts

Artifacts is used to specify a list of files and directories which should be attached to the job when it succeeds, fails, or always.

The artifacts will be sent to GitLab after the job finishes and will be available for download in the GitLab UI.

Artifact are also distributed to jobs in next stages.

```yaml
# .gitlab-ci.yml

stages:
  - build
  - test

build:
  stage: build
  script:
    - mkdir -p out
    - echo '<h1>Hello World!</h1>' > out/index.html
  artifacts:
    paths:
      - out

test:
  stage: test
  script:
    - cat out/index.html
```

When the job succed, you can browse and download job from Gitlab.

More about artifacts: <https://docs.gitlab.com/ce/user/project/pipelines/job_artifacts.html>

#### Artifacts Dependencies

By default, all artifacts will be passed to jobs in following stages. If you want artifact only from specific jobs, you can use dependencies to choose which articact you want.

Fists usage is when artifact are on same path and there will be colision, see:

```yaml
# .gitlab-ci.yml

stages:
  - build
  - test

build_A:
  stage: build
  script: mkdir -p out && echo '<h1>Hello from Project A!</h1>' > out/index.html
  artifacts: { paths: [out] }

build_B:
  stage: build
  script: mkdir -p out && echo '<h1>Hello from Project B!</h1>' > out/index.html
  artifacts: { paths: [out] }

test A:
  stage: test
  script: cat out/index.html
  dependencies: [build_A]

test B:
  stage: test
  script: cat out/index.html
  dependencies: [build_B]
```

Or you can use dependencies when you have lots of artifact and dont want to slow down your jobs by downloading unnecessary artifacts.

### Docker

- Fully supported
- Easiest way how to create build environment
- Easiest way how to run and distribute your software

If you have a Docker or Kubernetes executor ([we have](https://github.com/ondrejsika/gitlab-ci-runner/blob/master/register-runner.sh#L12)) you can define image where you want to run your job.

You can specify image globally or in job:

```yaml
# .gitlab-ci.yml

image: ondrejsika/ci

build:
  image: node
  script:
    - yarn
    - yarn run build

deploy:
  script:
    - kubectl apply -f kubernetes.yml
```

You can also run docker commands from job because we have added Docker socket there. See [here](https://github.com/ondrejsika/gitlab-ci-runner/blob/master/create-runner.sh#L6)
and [here](https://github.com/ondrejsika/gitlab-ci-runner/blob/master/register-runner.sh#L14).

```yaml
# .gitlab-ci.yml

job:
  script:
    - docker login $CI_REGISTRY -u $CI_REGISTRY_USER -p $CI_REGISTRY_PASSWORD
    - docker build -t $CI_REGISTRY_IMAGE .
    - docker push $CI_REGISTRY_IMAGE
```

### Docker Image `ondrejsika/ci`

That is my image which I use for most of CI jobs.

It contains lots of common tools like git, zip, curl, wget, Docker client, Docker Compose, Kubernetes client, ...

You can see the repository on Github - <https://github.com/ondrejsika/ondrejsika-ci-docker>

#### Pass Environment Variables to Docker

If you want to run Docker container and pass there all environment variables, you can use this:

```yaml
# .gitlab-ci.yml

job:
  script:
    - env > .env
    - docker run --rm --env-file .env debian env
```

### Environments

Environment is used to define that a job deploys to a specific environment.

If environment is specified and no environment under that name exists, a new one will be created automatically.

```yaml
# .gitlab-ci.yml

deploy:
  script: echo 'Deploy!'
  environment:
    name: $CI_COMMIT_REF_SLUG
    url: https://$CI_COMMIT_REF_SLUG.dev.company.com
```

#### Stop Environmet

You can define stop job for the environment which you can stop manually from Gitlab. If stop job is defined, Gitlab automatically stop unnecessary environments, like envirments created from merged or deleted branches.

```yaml
# .gitlab-ci.yml

deploy:
  script: echo Deploy!
  environment:
    name: $CI_COMMIT_REF_SLUG
    url: https://$CI_COMMIT_REF_SLUG.dev.company.com
    on_stop: stop

stop:
  script: echo Stop!
  when: manual
  environment:
    name: $CI_COMMIT_REF_SLUG
    action: stop
```

## Resources

- Gitlab CI Runner Setup (in Docker) - <https://github.com/ondrejsika/gitlab-ci-runner>
- Gitlab on Digital Ocean using Terraform - <https://github.com/ondrejsika/terraform-demo-gitlab>
- `ondrejsika/ci` Docker image - <https://github.com/ondrejsika/ondrejsika-ci-docker>
- [Traefik](https://traefik.io) (proxy) with Let's Encrypt - <https://github.com/ondrejsika/traefik-le>

### Examples

- Docker Compose deployment with Traefik - <https://github.com/ondrejsika/gitlab-ci-docker-compose-traefik--example>
- Kubernetes Deployment - <https://github.com/ondrejsika/gitlab-ci-example-kubernetes>
