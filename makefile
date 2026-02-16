.PHONY: sync run dev watch

sync:
	./sync_to_pi.sh

run:
	ssh pi@raspberrypi.local "cd ~/simpsons-tv && sudo python3 -m app"

dev:
	source .venv/bin/activate && python -m app

watch:
	source .venv/bin/activate && watchmedo auto-restart --patterns="*.py" --recursive --directory=./app --ignore-patterns="*__pycache__*" --signal SIGTERM -- python -m app
