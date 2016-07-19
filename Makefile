#Step 0 Already performed cloning the project
#Step 1 Install Docker (Enginge) and Docker Compose:
#MAC | WIN Install Docker Toolbox https://docs.docker.com/
#Linux: https://docs.docker.com/compose/install/
#and https://docs.docker.com/engine/installation/linux/ubuntulinux/
stop:  
	docker-compose stop
clean:
#Note -f means with force and cleaning of container, -v for Volumes Add ID for after stop and -v for a speccific container
	docker-compose stop && docker-compose rm -f -v

# Alteranive:
# Show all active contaienr : docker ps  
# docker stop ID
# Show all images : docker images 
# docker rmi -f IMAGEID

setup:
	#Start docker with: docker-machine start default
	$eval $(docker-machine env)
	docker-compose build box
	docker-compose build ruby_base
	docker-compose build db
	docker-compose build redis
	docker-compose build web
init:
	docker-compose start db
	docker-compose start redis
	
	# setup database
	docker-compose run web rake db:create db:migrate
	docker-compose run web rake db:test:prepare

rebuild_web_only:
	docker-compose build web

rebuild_web_and_ruby_base_gemssremain_cached:
	docker-compose build ruby_base && docker-compose build web

web_test:
	docker-compose run web rake

web_bash:
	docker-compose run web bash
