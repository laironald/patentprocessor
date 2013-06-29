import os
import ConfigParser

from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker
from schema import *


def fetch_engine():
    """
    Read from config.ini file and load appropriate database
    """
    echo = False
    config = ConfigParser.ConfigParser()
    config.read('{0}/config.ini'.format(os.path.dirname(os.path.realpath(__file__))))
    if config.get('global', 'database') == "sqlite":
        engine = create_engine('sqlite:///{0}'.format(config.get('sqlite', 'database')), echo=echo)
    else:
        engine = create_engine('mysql+mysqldb://{0}:{1}@{2}/{3}?charset=latin1'.format(
            config.get('mysql', 'user'),
            config.get('mysql', 'password'),
            config.get('mysql', 'host'),
            config.get('mysql', 'database')), echo=echo)
    return engine


def add(obj, override=True):
    """
    PatentGrant Object converting to tables via SQLAlchemy
    Necessary to convert dates to datetime because of SQLite (OK on MySQL)
    """

    # if a patent exists, remove it so we can replace it
    if override:
        pat_query = session.query(Patent).filter(Patent.number == obj.patent)
        if pat_query.count():
            session.delete(pat_query.one())

    #add
    # lots of abstracts seem to be missing. why?

    pat = Patent(**obj.pat)
    pat.application = Application(**obj.app)

    #+asg
    for asg, loc in obj.assignee_list():
        asg = Assignee(**asg)
        loc = Location(**loc)
        session.merge(loc)
        asg.location = loc
        pat.assignees.append(asg)

    #+inv
    for inv, loc in obj.inventor_list():
        inv = Inventor(**inv)
        loc = Location(**loc)
        session.merge(loc)
        inv.location = loc
        pat.inventors.append(inv)

    #+cit, +othercit
    cits, refs = obj.citation_list()
    for cit in cits:
        cit = Citation(**cit)
        pat.citations.append(cit)
    for ref in refs:
        ref = OtherReference(**ref)
        pat.otherreferences.append(ref)

    #+law
    for law in obj.lawyer_list():
        law = Lawyer(**law)
        pat.lawyers.append(law)

    #+usreldoc
    for usr in enumerate(obj.us_relation_list()):
        usr = USRelDoc(**usr)
        pat.usreldocs.append(usr)

    # ----------------------------------------

    #+classes (TODO for later)
    for i, cls in enumerate(obj.classes):
        uspc = USPC(i)
        mc = MainClass(cls[0])
        sc = SubClass("/".join(cls))
        session.merge(mc)
        session.merge(sc)
        uspc.mainclass = mc
        uspc.subclass = sc
        pat.classes.append(uspc)

    session.merge(pat)
    try:
        session.commit()
    except Exception, e:
        session.rollback()
        print str(e)


engine = fetch_engine()
Base.metadata.create_all(engine)
Session = sessionmaker(bind=engine)
session = Session()