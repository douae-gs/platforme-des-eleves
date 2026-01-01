class Config:
    SECRET_KEY = 'votre_cle_secrete_ici_123456'
    DB_HOST = 'localhost'
    DB_USER = 'root'
    DB_PASSWORD = 'DOUAE2005'  
    DB_NAME = 'eleveplatform'
    
    @staticmethod
    def get_db_config():
        return {
            'host': Config.DB_HOST,
            'user': Config.DB_USER,
            'password': Config.DB_PASSWORD,
            'database': Config.DB_NAME
        }