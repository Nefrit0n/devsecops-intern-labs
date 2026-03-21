#!/usr/bin/env python3
"""
Пример моделирования угроз через pytm.
Адаптируйте под Juice Shop.

Запуск:
    pip install pytm
    python pytm-example.py --dfd | dot -Tpng -o dfd-example.png
    python pytm-example.py --report report.md
"""
from pytm import TM, Server, Datastore, Dataflow, Boundary, Actor

tm = TM("Vulnerable App — Threat Model")
tm.description = "Модель угроз для учебного уязвимого приложения"
tm.isOrdered = True

internet = Boundary("Internet")
dmz = Boundary("DMZ")
internal = Boundary("Internal Network")

user = Actor("User")
user.inBoundary = internet

web_frontend = Server("Frontend (JS)")
web_frontend.OS = "Linux"
web_frontend.inBoundary = dmz

api_backend = Server("Backend (Flask)")
api_backend.OS = "Linux"
api_backend.inBoundary = dmz

database = Datastore("Database")
database.OS = "Linux"
database.inBoundary = internal
database.isSQL = True

user_to_frontend = Dataflow(user, web_frontend, "HTTP request")
user_to_frontend.protocol = "HTTP"
user_to_frontend.isEncrypted = False  # Уязвимость!

frontend_to_backend = Dataflow(web_frontend, api_backend, "API call")
frontend_to_backend.protocol = "HTTP"

backend_to_db = Dataflow(api_backend, database, "SQL query")
backend_to_db.protocol = "SQL"
backend_to_db.sanitizedInput = False  # SQL injection!

db_to_backend = Dataflow(database, api_backend, "Query result")
backend_to_frontend = Dataflow(api_backend, web_frontend, "JSON response")
frontend_to_user = Dataflow(web_frontend, user, "HTML page")

if __name__ == "__main__":
    tm.process()
