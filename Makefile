serve:
	bundle exec ruby main.rb

build:
	docker build -t explaincommand .

run:
	docker run -p 3000:3000 explaincommand