login:
	docker login -u gitlab-ci-token -p $${CI_BUILD_TOKEN} registry.gitlab.itsdonewhenitsdone.net
build: login
	docker build -t registry.gitlab.itsdonewhenitsdone.net/itsdonewhenitsdone.net/rundeck:$${CI_REF_NAME} .
	docker push registry.gitlab.itsdonewhenitsdone.net/itsdonewhenitsdone.net/rundeck:$${CI_REF_NAME}
trigger:
	curl -X POST \
     	 -F token=dee3334e5baaf4db859f72e461e0dd \
     	 -F ref=master \
     	 https://gitlab.itsdonewhenitsdone.net/api/v3/projects/2/trigger/builds
