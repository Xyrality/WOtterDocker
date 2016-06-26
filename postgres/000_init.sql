CREATE TABLE _dbupdater (
    lockowner character varying(100),
    modelname character varying(100) NOT NULL,
    updatelock integer NOT NULL,
    version integer NOT NULL
);

CREATE SEQUENCE account_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

CREATE TABLE account (
    id integer DEFAULT nextval('account_seq'::regclass) NOT NULL,
    name character varying(255) NOT NULL
);

CREATE SEQUENCE post_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

CREATE TABLE post (
    accountid integer NOT NULL,
    content character varying(255) NOT NULL,
    id integer DEFAULT nextval('post_seq'::regclass) NOT NULL,
    postedat timestamp without time zone NOT NULL
);


COPY _dbupdater (lockowner, modelname, updatelock, version) FROM stdin;
\N	WOtterModel	0	0
\.


COPY account (id, name) FROM stdin;
1	Test
2	Foo
\.

SELECT pg_catalog.setval('account_seq', 3, false);


COPY post (accountid, content, id, postedat) FROM stdin;
1	WOT?!	1	2016-06-03 16:49:35
2	FOOO	2	2016-06-21 13:12:45.551
2	bar 🤔	3	2016-06-21 13:14:27.033
\.

SELECT pg_catalog.setval('post_seq', 4, true);

ALTER TABLE ONLY _dbupdater
    ADD CONSTRAINT _dbupdater_pk PRIMARY KEY (modelname);
ALTER TABLE ONLY account
    ADD CONSTRAINT account_pk PRIMARY KEY (id);
ALTER TABLE ONLY post
    ADD CONSTRAINT post_pk PRIMARY KEY (id);

CREATE INDEX post_accountid_idx ON post USING btree (accountid);

ALTER TABLE ONLY post
    ADD CONSTRAINT post_accountid_id_fk FOREIGN KEY (accountid) REFERENCES account(id) DEFERRABLE INITIALLY DEFERRED;
