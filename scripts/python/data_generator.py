import pandas as pd
import numpy as np
from faker import Faker
import uuid
import random
from datetime import datetime, timedelta
from decimal import Decimal, ROUND_HALF_UP

Faker.seed(4321)
random.seed(4321)
np.random.seed(4321)

class OmegaBankGenerator:
    
    def __init__(self):
        self.fake = Faker('es_ES')
        self.clients = []
        self.accounts = []
        self.branches = []
        self.merchants = []
        self.transactions = []

        self.transaction_types = [
            {'id': 'DEP_VEN', 'name': 'Depósito en Ventanilla', 'is_credit': True, 'category': 'Presencial'},
            {'id': 'RET_ATM', 'name': 'Retiro en Cajero (ATM)', 'is_credit': False, 'category': 'Presencial'},
            {'id': 'COM_POS', 'name': 'Compra con Tarjeta (POS)', 'is_credit': False, 'category': 'Presencial'},
            {'id': 'COM_WEB', 'name': 'Compra E-Commerce', 'is_credit': False, 'category': 'Digital'},
            {'id': 'TRF_REC', 'name': 'Transferencia Recibida', 'is_credit': True, 'category': 'Digital'},
            {'id': 'TRF_ENV', 'name': 'Transferencia Enviada', 'is_credit': False, 'category': 'Digital'},
            {'id': 'PAG_SERV', 'name': 'Pago de Servicios', 'is_credit': False, 'category': 'Digital'}
        ]

    def generate_clients(self, n=50):
        print(f"Generando {n} clientes...")
        for _ in range(n):
            client = {
                'client_id': str(uuid.uuid4()),
                'dni': str(self.fake.unique.random_number(digits=8, fix_len=True)),
                'nombre': self.fake.first_name(),
                'apellido': self.fake.last_name(),
                'email': self.fake.email(),
                'job': self.fake.job(),
                'fecha_alta': self.fake.date_between(start_date='-5y', end_date='today'),
                'created_at_dt': self.fake.date_time_between(start_date='-5y', end_date='now'),
                'source_system': 'OMEGA_CORE_V1'
            }
            self.clients.append(client)
    
    def generate_accounts(self, n_extra=0):
        if not self.clients:
            print("ERROR: No hay clientes. Genera clientes primero.")
            return

        print(f"Generando cuentas (1:1 + {n_extra} extras)...")
        
        for cliente in self.clients:
            self._crear_una_cuenta(cliente)

        if n_extra > 0:
            for _ in range(n_extra):
                cliente_aleatorio = random.choice(self.clients)
                self._crear_una_cuenta(cliente_aleatorio)
        
        print(f"Total: {len(self.accounts)} cuentas generadas")

    def _crear_una_cuenta(self, cliente_obj):
        moneda = random.choice(['USD', 'EUR', 'PEN'])
        tipo = random.choice(['Ahorros', 'Corriente', 'Sueldo'])
        
        fecha_alta_cliente = cliente_obj['fecha_alta']
        
        cuenta_created_at = self.fake.date_time_between(
            start_date=fecha_alta_cliente + timedelta(days=1),
            end_date='now'
        )
        
        audit_created_at = cuenta_created_at + timedelta(
            days=random.randint(0, 30),
            hours=random.randint(0, 23),
            minutes=random.randint(0, 59)
        )
        
        account = {
            'account_id': str(uuid.uuid4()),
            'client_id': cliente_obj['client_id'],
            'tipo_cuenta': tipo,
            'saldo_actual': Decimal(str(round(random.uniform(100.00, 50000.00), 2))),
            'moneda': moneda,
            'estado': random.choice(['ACTIVA', 'ACTIVA', 'ACTIVA', 'BLOQUEADA']),
            'fecha_apertura': cuenta_created_at,
            'created_at_dt': audit_created_at
        }
        self.accounts.append(account)
    
    def generate_branches(self, n=20):
        print(f"Generando {n} sucursales...")
        for _ in range(n):
            branch = {
                'branch_id': str(uuid.uuid4()),
                'nombre_sucursal': f"Sucursal {self.fake.city()}",
                'ciudad': self.fake.city(),
                'manager_id': str(uuid.uuid4()),
                'created_at_dt': self.fake.date_time_between(start_date='-3y', end_date='now')
            }
            self.branches.append(branch)

    def generate_merchants(self, n=50):
        print(f"Generando {n} comercios...")
        for _ in range(n):
            merchant = {
                'merchant_id': str(uuid.uuid4()),
                'merchant_name': self.fake.company(),
                'category': random.choice([
                    'Retail', 'Restaurante', 'Tecnología', 'Salud', 'Entretenimiento'
                ]),
                'created_at_dt': self.fake.date_time_between(start_date='-2y', end_date='now')
            }
            self.merchants.append(merchant)
    
    def generate_transactions(self, n=1000):
        print(f"Generando {n} transacciones...")
        for _ in range(n):
            cuenta_elegida = random.choice(self.accounts)
            fecha_apertura_cuenta = cuenta_elegida['fecha_apertura']
            
            tt = random.choice(self.transaction_types)
            
            monto = Decimal(str(round(random.uniform(1.00, 1000.00), 2)))
            
            if not tt['is_credit']:
                monto = -monto

            fecha_transaccion = self.fake.date_time_between(
                start_date=fecha_apertura_cuenta,
                end_date='now'
            )
            
            audit_created_at = fecha_transaccion + timedelta(
                days=random.randint(0, 7),
                hours=random.randint(0, 23),
                minutes=random.randint(0, 59)
            )

            transaction = {
                'transaction_id': str(uuid.uuid4()),
                'account_id': cuenta_elegida['account_id'],
                'branch_id': random.choice(self.branches)['branch_id'],
                'merchant_id': random.choice(self.merchants)['merchant_id'],
                'transaction_type_id': tt['id'],
                'monto': monto,
                'fecha_hora': fecha_transaccion,
                'device_id': str(uuid.uuid4()),
                'created_at_dt': audit_created_at
            }
            self.transactions.append(transaction)

    def export_csv(self):
        print("\n--- EXPORTANDO A CSV ---")
        
        files_to_generate = {
            'dim_clientes.csv': self.clients,
            'dim_cuentas.csv': self.accounts,
            'dim_sucursales.csv': self.branches,
            'dim_comercios.csv': self.merchants,
            'fact_transacciones.csv': self.transactions
        }

        for filename, data_list in files_to_generate.items():
            if not data_list:
                print(f"⚠️ {filename} vacío, omitiendo...")
                continue
                
            df = pd.DataFrame(data_list)
            df.to_csv(filename, index=False, encoding='utf-8')
            print(f"✅ {filename}: {len(df)} registros")
        
        print("🎯 Datasets limpios listos para uso")
    
if __name__ == "__main__":
    generator = OmegaBankGenerator()
    print("=== OMEGA BANK: GENERADOR DE DATOS SINTÉTICOS ===")

    print("\n📊 DIMENSIONES BASE")
    generator.generate_clients(1000)
    generator.generate_branches(20)
    generator.generate_merchants(100)
    
    print("\n🔗 DIMENSIONES DEPENDIENTES")
    generator.generate_accounts(n_extra=500)
    
    print("\n💰 TABLA DE HECHOS")
    generator.generate_transactions(50000)

    generator.export_csv()
    
    print("\n🎉 PIPELINE COMPLETADO - Datasets listos")