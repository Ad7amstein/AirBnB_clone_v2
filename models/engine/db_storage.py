#!/usr/bin/python3
"""DataBase Storage"""
from sqlalchemy import create_engine, text
import os
from models.base_model import BaseModel
from models.base_model import Base
from models.user import User
from models.place import Place
from models.state import State
from models.city import City
from models.amenity import Amenity
from models.review import Review
from sqlalchemy.orm import sessionmaker, scoped_session


environ = os.environ


class DBStorage:
    """Represents the database storage"""
    __engine = None
    __session = None

    def __init__(self):
        """Initialization method"""
        user, password, host_name, db_name = environ['HBNB_MYSQL_USER'],\
            environ['HBNB_MYSQL_PWD'], environ['HBNB_MYSQL_HOST'],\
            environ['HBNB_MYSQL_DB']
        self.__engine = create_engine(
                "mysql+mysqldb://{}:{}@{}/{}".format(
                    user, password, host_name, db_name), pool_pre_ping=True)
        if environ['HBNB_ENV'] == 'test':
            Base.metadata.drop_all(self.__engine)

    def all(self, cls=None):
        """Query all objects"""
        classes = {
                    'State': State, 'City': City,
                    'User': User, 'Place': Place,
                    }
        objects = {}
        if cls is None:
            for class_name in classes:
                instances = self.__session.query(classes[class_name]).all()
                for instance in instances:
                    key = class_name + '.' + instance.id
                    objects[key] = instance
        else:
            if cls.__name__ in classes:
                instances = self.__session.query(cls).all()
                for instance in instances:
                    key = cls.__name__ + '.' + instance.id
                    objects[key] = instance
        return objects

    def new(self, obj):
        """Add new object"""
        self.__session.add(obj)

    def save(self):
        """Save all changes"""
        self.__session.commit()

    def delete(self, obj=None):
        """Deletes an object"""
        if obj:
            self.__session.delete(obj)

    def reload(self):
        """Reloads the database"""
        Base.metadata.create_all(self.__engine)
        Session = sessionmaker(bind=self.__engine, expire_on_commit=False)
        session = scoped_session(Session)
        self.__session = session()
