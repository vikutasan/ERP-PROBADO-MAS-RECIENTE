--
-- PostgreSQL database dump
--

\restrict hozNg61Hxmi1Say2C41r7a7PzPG6JxAxSrYmwzEz7OufoXNEQgEwfAd8RTgQ1fA

-- Dumped from database version 15.17
-- Dumped by pg_dump version 15.17

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: alembic_version; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.alembic_version (
    version_num character varying(32) NOT NULL
);


--
-- Name: cash_movements; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.cash_movements (
    id integer NOT NULL,
    cash_session_id integer NOT NULL,
    movement_type character varying NOT NULL,
    amount double precision NOT NULL,
    concept character varying NOT NULL,
    created_at timestamp without time zone
);


--
-- Name: cash_movements_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.cash_movements_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: cash_movements_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.cash_movements_id_seq OWNED BY public.cash_movements.id;


--
-- Name: cash_sessions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.cash_sessions (
    id integer NOT NULL,
    terminal_id character varying NOT NULL,
    employee_id integer NOT NULL,
    employee_name character varying NOT NULL,
    opening_float double precision NOT NULL,
    status character varying NOT NULL,
    opened_at timestamp without time zone,
    closed_at timestamp without time zone,
    physical_cash double precision,
    physical_credit double precision,
    physical_debit double precision
);


--
-- Name: cash_sessions_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.cash_sessions_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: cash_sessions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.cash_sessions_id_seq OWNED BY public.cash_sessions.id;


--
-- Name: categories; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.categories (
    id integer NOT NULL,
    name character varying NOT NULL,
    icon character varying,
    vision_enabled boolean
);


--
-- Name: categories_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.categories_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: categories_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.categories_id_seq OWNED BY public.categories.id;


--
-- Name: employees; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.employees (
    id integer NOT NULL,
    name character varying NOT NULL,
    employee_code character varying NOT NULL,
    role character varying NOT NULL,
    is_active boolean,
    profile_id integer
);


--
-- Name: employees_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.employees_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: employees_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.employees_id_seq OWNED BY public.employees.id;


--
-- Name: products; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.products (
    id integer NOT NULL,
    sku character varying NOT NULL,
    barcode character varying,
    name character varying NOT NULL,
    price double precision NOT NULL,
    category_id integer,
    active boolean,
    image_url character varying,
    "position" integer
);


--
-- Name: products_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.products_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: products_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.products_id_seq OWNED BY public.products.id;


--
-- Name: security_profiles; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.security_profiles (
    id integer NOT NULL,
    name character varying NOT NULL,
    description character varying,
    permissions json NOT NULL,
    is_system boolean
);


--
-- Name: security_profiles_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.security_profiles_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: security_profiles_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.security_profiles_id_seq OWNED BY public.security_profiles.id;


--
-- Name: system_settings; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.system_settings (
    id integer NOT NULL,
    key character varying NOT NULL,
    value character varying NOT NULL,
    description character varying,
    category character varying,
    input_type character varying
);


--
-- Name: system_settings_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.system_settings_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: system_settings_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.system_settings_id_seq OWNED BY public.system_settings.id;


--
-- Name: terminal_sessions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.terminal_sessions (
    id integer NOT NULL,
    terminal_id character varying NOT NULL,
    opened_at timestamp without time zone,
    closed_at timestamp without time zone,
    is_active boolean
);


--
-- Name: terminal_sessions_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.terminal_sessions_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: terminal_sessions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.terminal_sessions_id_seq OWNED BY public.terminal_sessions.id;


--
-- Name: ticket_items; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.ticket_items (
    id integer NOT NULL,
    ticket_id integer,
    product_id integer,
    quantity integer NOT NULL,
    unit_price double precision NOT NULL,
    subtotal double precision NOT NULL
);


--
-- Name: ticket_items_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.ticket_items_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: ticket_items_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.ticket_items_id_seq OWNED BY public.ticket_items.id;


--
-- Name: tickets; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.tickets (
    id integer NOT NULL,
    account_num character varying NOT NULL,
    total double precision NOT NULL,
    created_at timestamp without time zone,
    status character varying,
    session_id integer,
    payment_details json,
    cash_session_id integer,
    captured_by_id integer,
    cashed_by_id integer
);


--
-- Name: tickets_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.tickets_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: tickets_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.tickets_id_seq OWNED BY public.tickets.id;


--
-- Name: cash_movements id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cash_movements ALTER COLUMN id SET DEFAULT nextval('public.cash_movements_id_seq'::regclass);


--
-- Name: cash_sessions id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cash_sessions ALTER COLUMN id SET DEFAULT nextval('public.cash_sessions_id_seq'::regclass);


--
-- Name: categories id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.categories ALTER COLUMN id SET DEFAULT nextval('public.categories_id_seq'::regclass);


--
-- Name: employees id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.employees ALTER COLUMN id SET DEFAULT nextval('public.employees_id_seq'::regclass);


--
-- Name: products id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.products ALTER COLUMN id SET DEFAULT nextval('public.products_id_seq'::regclass);


--
-- Name: security_profiles id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.security_profiles ALTER COLUMN id SET DEFAULT nextval('public.security_profiles_id_seq'::regclass);


--
-- Name: system_settings id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.system_settings ALTER COLUMN id SET DEFAULT nextval('public.system_settings_id_seq'::regclass);


--
-- Name: terminal_sessions id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.terminal_sessions ALTER COLUMN id SET DEFAULT nextval('public.terminal_sessions_id_seq'::regclass);


--
-- Name: ticket_items id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ticket_items ALTER COLUMN id SET DEFAULT nextval('public.ticket_items_id_seq'::regclass);


--
-- Name: tickets id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tickets ALTER COLUMN id SET DEFAULT nextval('public.tickets_id_seq'::regclass);


--
-- Data for Name: alembic_version; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.alembic_version (version_num) FROM stdin;
07ac8e13c9ab
\.


--
-- Data for Name: cash_movements; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.cash_movements (id, cash_session_id, movement_type, amount, concept, created_at) FROM stdin;
1	1	ENTRADA	40	REFUERZO	2026-03-17 01:09:20.848117
2	1	SALIDA	70	TRAPO	2026-03-17 01:09:37.154484
3	3	SALIDA	10	Chicle	2026-03-17 04:29:16.047396
4	3	ENTRADA	400	Refuerzo caja	2026-03-17 04:29:32.910284
5	5	SALIDA	10	Chicle	2026-03-17 22:37:55.291248
6	5	ENTRADA	700	Refuerzo	2026-03-17 22:38:16.041366
7	6	SALIDA	100	PRUEBA	2026-03-18 02:48:44.400179
8	8	SALIDA	8	CV	2026-03-18 22:39:46.323537
9	8	ENTRADA	78	FG	2026-03-18 22:39:54.636572
10	9	SALIDA	2	SD	2026-03-18 22:42:23.327565
11	9	ENTRADA	78	GH	2026-03-18 22:42:31.340285
12	10	SALIDA	1	DF	2026-03-18 22:44:13.069753
13	10	ENTRADA	70	DT	2026-03-18 22:44:21.818422
15	11	ENTRADA	74	Refuerzo	2026-03-18 23:10:53.845085
16	11	SALIDA	70	Leche	2026-03-18 23:11:12.562733
17	12	SALIDA	70	Chicles	2026-03-18 23:23:22.403718
18	12	ENTRADA	500	Refuerzo	2026-03-18 23:23:36.316144
19	16	SALIDA	108	Leche	2026-03-19 12:56:53.669909
20	16	ENTRADA	500	Refuerzo	2026-03-19 12:57:18.961261
\.


--
-- Data for Name: cash_sessions; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.cash_sessions (id, terminal_id, employee_id, employee_name, opening_float, status, opened_at, closed_at, physical_cash, physical_credit, physical_debit) FROM stdin;
1	CAJA	1	Administrador Sistema	150	CLOSED	2026-03-17 00:47:50.008823	2026-03-17 01:09:53.50998	0	0	0
2	CAJA	1	Administrador Sistema	400	CLOSED	2026-03-17 03:25:39.219415	2026-03-17 04:26:41.808705	0	0	0
3	CAJA	2	LETICIA	400	CLOSED	2026-03-17 04:27:58.542067	2026-03-17 04:30:14.144772	0	0	0
4	CAJA	2	LETICIA	100	CLOSED	2026-03-17 21:48:53.729032	2026-03-17 22:36:18.17258	0	0	0
5	CAJA	2	LETICIA	400	CLOSED	2026-03-17 22:37:12.252836	2026-03-17 22:38:54.096676	0	0	0
6	CAJA	2	LETICIA	100	CLOSED	2026-03-17 22:55:07.12112	2026-03-18 22:16:30.633857	0	0	0
7	CAJA	1	VICTOR	700	CLOSED	2026-03-18 22:32:43.821874	2026-03-18 22:34:24.299761	0	0	0
8	CAJA	1	VICTOR	78	CLOSED	2026-03-18 22:38:42.307532	2026-03-18 22:40:01.614601	0	0	0
9	CAJA	1	VICTOR	74	CLOSED	2026-03-18 22:42:09.648244	2026-03-18 22:43:22.782006	0	0	0
10	CAJA	1	VICTOR	40	CLOSED	2026-03-18 22:44:04.368839	2026-03-18 22:45:26.361346	170	0	34
11	CAJA	2	LETICIA	500	CLOSED	2026-03-18 23:09:18.112487	2026-03-18 23:11:34.978764	500	43	50
12	CAJA	2	LETICIA	600	CLOSED	2026-03-18 23:23:09.360309	2026-03-18 23:24:30.966302	1111	43	40
13	CAJA	2	LETICIA	78	CLOSED	2026-03-18 23:44:36.140564	2026-03-19 00:22:27.49763	0	0	0
15	T6	1	VICTOR	50	CLOSED	2026-03-19 02:53:32.654683	2026-03-19 12:13:15.685025	0	0	0
14	CAJA	2	LETICIA	70	CLOSED	2026-03-19 00:23:05.067795	2026-03-19 12:16:00.388922	0	0	0
16	CAJA	3	SAGRARIO	3500	CLOSED	2026-03-19 12:52:50.137168	2026-03-19 12:58:01.518554	525	85	45
17	CAJA	3	SAGRARIO	3600	CLOSED	2026-03-19 13:07:56.719372	2026-03-19 20:51:23.352967	0	0	0
19	T6	1	VICTOR	700	CLOSED	2026-03-19 22:19:05.28211	2026-03-19 22:56:59.220893	0	0	0
18	CAJA	2	Omega	3500	CLOSED	2026-03-19 21:07:22.084874	2026-03-20 20:44:34.86421	\N	\N	\N
20	CAJA	1	VICTOR	100	CLOSED	2026-03-21 00:00:04.45144	2026-03-21 00:15:11.618489	0	0	0
21	CAJA	20	OMEGA	1000	CLOSED	2026-03-21 00:17:11.178886	2026-03-21 03:51:42.305928	0	0	0
22	T6	1	VICTOR	111	CLOSED	2026-03-21 00:40:46.640921	2026-03-21 21:33:45.646695	0	0	0
24	T6	1	VICTOR	100	CLOSED	2026-03-21 23:23:21.049485	2026-03-21 23:26:29.794997	0	0	0
25	T6	1	VICTOR	100	CLOSED	2026-03-22 03:04:42.508112	2026-03-22 03:05:11.227121	0	0	0
23	CAJA	20	OMEGA	3500	CLOSED	2026-03-21 12:52:00.437763	2026-03-22 03:51:38.53805	0	0	0
26	CAJA	3	Alfa	3500	CLOSED	2026-03-22 13:14:50.295858	2026-03-22 14:37:53.217438	\N	\N	\N
27	CAJA	3	Alfa	200	CLOSED	2026-03-22 15:09:41.636816	2026-03-23 04:12:24.629525	0	0	0
28	CAJA	20	OMEGA	3500	CLOSED	2026-03-23 14:49:08.363891	2026-03-24 03:36:32.541296	0	0	0
29	CAJA	20	OMEGA	3500	CLOSED	2026-03-24 12:50:31.907023	2026-03-25 00:11:35.295782	\N	\N	\N
30	CAJA	3	Alfa	100	CLOSED	2026-03-25 00:16:30.978699	2026-03-25 03:38:51.629146	0	0	0
31	CAJA	20	OMEGA	3500	CLOSED	2026-03-25 13:48:32.542354	2026-03-25 20:10:04.676765	0	0	0
32	CAJA	20	OMEGA	3500	CLOSED	2026-03-25 20:15:54.252899	2026-03-25 21:07:42.898964	\N	\N	\N
34	CAJA	1	VICTOR	1000	CLOSED	2026-03-25 21:09:00.63942	2026-03-25 21:37:57.650679	0	0	0
33	T4	20	OMEGA	3000	CLOSED	2026-03-25 20:29:38.640246	2026-03-26 01:27:02.815713	\N	\N	\N
35	CAJA	3	Alfa	1000	CLOSED	2026-03-25 21:39:06.499988	2026-03-26 03:49:28.064784	0	0	0
36	CAJA	3	Alfa	1	CLOSED	2026-03-26 03:50:47.140423	2026-03-26 03:51:15.626173	0	0	0
69	CAJA	20	OMEGA	3500	CLOSED	2026-03-26 12:58:08.88162	2026-03-26 21:09:05.893721	\N	\N	\N
70	CAJA	1	VICTOR	1000	CLOSED	2026-03-26 21:10:34.098565	2026-03-27 03:36:40.815919	0	0	0
71	CAJA	20	OMEGA	3500	OPEN	2026-03-27 13:01:12.641069	\N	\N	\N	\N
\.


--
-- Data for Name: categories; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.categories (id, name, icon, vision_enabled) FROM stdin;
1	1.-EMPAQUE Y PAN BLANCO	\N	t
2	2.-A - B	\N	t
3	3.-C - D	\N	t
4	4.-E - K	\N	t
5	5.-L - M	\N	t
6	6.-N - P	\N	t
7	7.-R - S	\N	t
8	8.-T - Z	\N	t
9	17.-ROSCA DE REYES	\N	t
10	9.-LACTEOS	\N	t
11	10.-SOBRE PEDIDO	\N	t
12	11.-ESPORADICOS	\N	t
13	12.-CAFES Y CHOCOLATES	\N	t
14	13.-SOUVENIRS	\N	t
15	14.-HELADOS	\N	t
16	15.-PALETAS	\N	t
17	16.-AGUAS Y MALTEADAS	\N	t
\.


--
-- Data for Name: employees; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.employees (id, name, employee_code, role, is_active, profile_id) FROM stdin;
6	PROBADOR	0000	PRUEBA	f	\N
1	VICTOR	1111	ADMIN	t	1
7	JESUS	1980	RG	f	4
5	NATALIA	1970	RG	f	4
8	NATY	8888	RG	t	4
9	LUZ	7777	RG	t	4
11	Jesus	5813	RG	f	4
12	Pedro	7788	RG	f	4
13	ARELY	9999	RG	t	4
14	Martha	1234	RG	t	4
15	Juana	2259	RG	t	4
16	Paz	7008	RG	t	4
17	Lucy	2804	RG	t	4
4	LUPITA	0410	RG	t	4
10	DALIA	0529	RG	t	4
3	Alfa	3333	MANAGER	t	2
18	Jimena	7532	RG	t	4
2	Omega	2222	MANAGER	f	2
19	CHUCHO	4267	RG	f	4
21	Evelin	2589	RG	t	4
20	OMEGA	5020	MANAGER	t	2
22	Jetzemany	2211	RG	t	4
23	Saray	1105	CAJERO	t	\N
24	Alicia	1988	RG	t	4
25	Yami	0801	RG	t	4
26	Jes├║s Garc├¡a 	1204	RG	t	4
27	Luis	6660	RG	t	4
28	LUCA ANGELO	1557	RG	t	4
29	PAO	2105	RG	t	4
30	LORENZO	0802	CAJERO	f	3
31	RICO	0803	CAJERO	t	3
32	ALEX	1912	CAJERO	f	\N
33	RANGEL	1901	RG	t	4
\.


--
-- Data for Name: products; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.products (id, sku, barcode, name, price, category_id, active, image_url, "position") FROM stdin;
54	82	82	CONCHA DE CANELA GRANDE	35	3	t	\N	\N
77	106	106	HOJALDRA DE CANELA	18	4	t	\N	\N
78	107	107	HOJALDRA DE CANELA GRANDE	50	4	t	\N	\N
80	113	113	HOJALDRA DE NARANJA MEDIANA	115	4	t	\N	\N
81	114	114	HOJALDRA DE NARANJA GRANDE	210	4	t	\N	\N
82	115	115	HOJALDRA DE NARANJA JUMBO	279	4	t	\N	\N
87	108	108	HOJALDRA DE NUEZ CHICA	26	4	t	\N	\N
88	109	109	HOJALDRA DE NUEZ MEDIANA	130	4	t	\N	\N
89	110	110	HOJALDRA DE NUEZ GRANDE	230	4	t	\N	\N
90	111	111	HOJALDRA DE NUEZ JUMBO	349	4	t	\N	\N
92	116	116	LADRILLO AZUCAR	9	5	t	\N	\N
26	33	33	BARQUILLO DE CREMA PASTELERA	14	2	t	http://192.168.1.117:3001/static/catalog/33.png	\N
27	34	34	BARRA DE MANTECA	8	2	t	http://192.168.1.117:3001/static/catalog/34.png	\N
29	36	36	BERLINES DE CREMA PASTELERA	12	2	t	http://192.168.1.117:3001/static/catalog/36.png	\N
40	57	57	CANASTA DE FRUTAS	19	3	t	http://192.168.1.117:3001/static/catalog/57.png	\N
6	6	6	BOLILLO RUSTICO MEDIANO	3	1	t	http://192.168.1.117:3001/static/catalog/6.png	\N
46	64	64	CHURRO FRESCO	6	3	t	http://192.168.1.117:3001/static/catalog/64.png	\N
51	68	68	CONCHA BLANCA	8	3	t	http://192.168.1.117:3001/static/catalog/68.png	\N
52	69	69	CONCHA CAFE	8	3	t	http://192.168.1.117:3001/static/catalog/69.png	\N
55	70	70	CUADRO DE COCO	8	3	t	http://192.168.1.117:3001/static/catalog/70.png	\N
57	72	72	CUERNO	9	3	t	http://192.168.1.117:3001/static/catalog/72.png	\N
58	73	73	CUERNO DE HIGO	13	3	t	http://192.168.1.117:3001/static/catalog/73.png	\N
60	76	76	DELICIOSA	8	3	t	http://192.168.1.117:3001/static/catalog/76.png	\N
66	92	92	EMPANADA DE FRESA	8	4	t	http://192.168.1.117:3001/static/catalog/92.png	\N
68	97	97	FLAUTAS	8	4	t	http://192.168.1.117:3001/static/catalog/97.png	\N
70	99	99	GALLETA DE CARITA	8	4	t	http://192.168.1.117:3001/static/catalog/99.png	\N
19	359	359	NESCAFE CAPUCHINO	15	13	t	\N	\N
11	11	11	COSTO EXTRA 1	1	1	t	http://192.168.1.117:3001/static/catalog/11.jpg	\N
94	118	118	LADRILLO UNTADO	9	5	t	http://192.168.1.117:3001/static/catalog/118.png	\N
96	120	120	MANTECADAS	8	5	t	http://192.168.1.117:3001/static/catalog/120.png	\N
98	122	122	MANTECONCHA DE VAINILLA	10	5	t	http://192.168.1.117:3001/static/catalog/122.png	\N
104	128	128	MUFFIN DE CHOCOLATE RELLENO DE CAPUCCINO	13	5	t	http://192.168.1.117:3001/static/catalog/128.png	\N
1	1	1	BOLSA BIODEGRADABLE	2	1	t	http://192.168.1.117:3001/static/catalog/1.png	\N
72	101	101	GALLETA DE CHOCOLATE CON NUEZ	8	4	t	http://192.168.1.117:3001/static/catalog/101.png	\N
75	103	103	GANSITO	12	4	t	http://192.168.1.117:3001/static/catalog/103.png	\N
76	104	104	HIGO	36	4	t	http://192.168.1.117:3001/static/catalog/104.png	\N
95	119	119	LAUREL	8	5	t	http://192.168.1.117:3001/static/catalog/119.png	\N
99	123	123	MEDIAS	12	5	t	http://192.168.1.117:3001/static/catalog/123.png	\N
101	125	125	MINI OREJA	3	5	t	http://192.168.1.117:3001/static/catalog/125.png	\N
13	13	13	COSTO EXTRA 4	4	1	t	http://192.168.1.117:3001/static/catalog/13.jpg	\N
106	130	130	MULTI CON CHOCOLATE	14	5	t	http://192.168.1.117:3001/static/catalog/130.png	\N
15	15	15	BOLSA DE PLASTICO DE 60 X 90	6	1	t	http://192.168.1.117:3001/static/catalog/15.png	\N
18	18	18	CHAROLA GRANDE DE CARTON	35	1	t	http://192.168.1.117:3001/static/catalog/18.png	\N
2	2	2	BOLSA DE PAPEL	2	1	t	http://192.168.1.117:3001/static/catalog/2.png	\N
3	3	3	TELERA ARTESANAL MEDIANA	3	1	t	http://192.168.1.117:3001/static/catalog/3.png	\N
24	31	31	BANDERILLA	8	2	t	http://192.168.1.117:3001/static/catalog/31.png	\N
31	38	38	BIGOTE DE CHOCOLATE	9	2	t	http://192.168.1.117:3001/static/catalog/38.png	\N
32	39	39	BIZQUET	8	2	t	http://192.168.1.117:3001/static/catalog/39.png	\N
33	40	40	BOLLO DE QUESO PHILADELPHIA	11	2	t	http://192.168.1.117:3001/static/catalog/40.png	\N
34	41	41	BROCA	8	2	t	http://192.168.1.117:3001/static/catalog/41.png	\N
5	5	5	BOLILLO ARTESANAL MEDIANO	3	1	t	http://192.168.1.117:3001/static/catalog/5.png	\N
37	54	54	CALVO DE COCO	8	3	t	http://192.168.1.117:3001/static/catalog/54.png	\N
39	56	56	CAMPECHANA	8	3	t	http://192.168.1.117:3001/static/catalog/56.png	\N
43	61	61	CHINO	12	3	t	http://192.168.1.117:3001/static/catalog/61.png	\N
44	62	62	CHIRIMOYA	8	3	t	http://192.168.1.117:3001/static/catalog/62.png	\N
49	66	66	CONCHA AMARILLA	8	3	t	http://192.168.1.117:3001/static/catalog/66.png	\N
61	77	77	DIAMANTE DE CHABACANO	8	3	t	http://192.168.1.117:3001/static/catalog/77.png	\N
63	79	79	DONA DE CHOCOLATE	9	3	t	http://192.168.1.117:3001/static/catalog/79.png	\N
64	80	80	DONA DE MOKA	13	3	t	http://192.168.1.117:3001/static/catalog/80.png	\N
65	91	91	ELOTE	8	4	t	http://192.168.1.117:3001/static/catalog/91.png	\N
22	44	44	ANCESTRAL MEDIANO	9	2	t	http://192.168.1.117:3001/static/catalog/44.png	\N
48	180	180	CHURRO OFERTA	10	3	t	http://192.168.1.117:3001/static/catalog/180.png	\N
53	81	81	CONCHA DE CANELA	9	3	t	http://192.168.1.117:3001/static/catalog/81.png	\N
79	112	112	HOJALDRA DE NARANJA CHICA	23	4	t	http://192.168.1.117:3001/static/catalog/112.png	\N
84	135	135	HOJALDRA DE NUEZ INDIVIDUAL RELLENA	65	4	t	http://192.168.1.117:3001/static/catalog/135.png	\N
102	133	133	MINI PAN DE MUERTO	5	5	t	http://192.168.1.117:3001/static/catalog/133.png	\N
144	186	186	REBANADA CON HIGO	9	7	t	\N	\N
155	199	199	ROSCA DE NARANJA	17	7	t	\N	\N
161	205	205	ROSCA DE CANELA RELLENA DE FRESA	8	7	t	\N	\N
162	206	206	ROSCA C. DE CANELA RELLENA DE FRESA	8	7	t	\N	\N
168	223	223	TOSTADAS DE MANTEQUILLA	15	8	t	\N	\N
174	209	209	ROSCA DE REYES NARANJA MEDIANA	190	9	t	\N	\N
175	210	210	ROSCA DE REYES NARANJA GRANDE	290	9	t	\N	\N
176	211	211	ROSCA DE REYES NARANJA JUMBO	390	9	t	\N	\N
178	212	212	ROSCA DE REYES NUEZ MEDIANA	270	9	t	\N	\N
179	213	213	ROSCA DE REYES NUEZ GRANDE	400	9	t	\N	\N
180	214	214	ROSCA DE REYES NUEZ JUMBO	530	9	t	\N	\N
182	215	215	ROSCA DE REYES ZARZAMORA PHIL MEDIANA	330	9	t	\N	\N
183	216	216	ROSCA DE REYES ZARZAMORA PHIL GRANDE	500	9	t	\N	\N
184	217	217	ROSCA DE REYES ZARZAMORA PHIL JUMBO	630	9	t	\N	\N
195	257	257	BARRA VIEJA HIERBAS FINAS	20	11	t	\N	\N
198	260	260	BOLILLO CON AJONJOLI CHICO	4	11	t	\N	\N
200	262	262	BOLILLO ARTESANAL CHICO	3	11	t	\N	\N
201	263	263	BOLILLO ARTESANAL GRA	7	11	t	\N	\N
202	264	264	BOLILLO ARTESANAL JUM	12	11	t	\N	\N
203	265	265	BOLLO	6.5	11	t	\N	\N
204	266	266	CHAPATA DE AJO PEREJIL CON QUESO PHILADELPHIA	15	11	t	\N	\N
113	147	147	OFERTA DE PANES	25	6	t	http://192.168.1.117:3001/static/catalog/147.png	\N
117	152	152	PAN MOLIDO	24	6	t	http://192.168.1.117:3001/static/catalog/152.png	\N
119	154	154	PASAS	31	6	t	http://192.168.1.117:3001/static/catalog/154.png	\N
121	156	156	PAN DE ELOTE	35	6	t	http://192.168.1.117:3001/static/catalog/156.png	\N
127	159	159	PEINETA DE FRESA	8	6	t	http://192.168.1.117:3001/static/catalog/159.png	\N
140	172	172	POLVORON NARANJA	8	6	t	http://192.168.1.117:3001/static/catalog/172.png	\N
164	208	208	SACRISTAN	9	7	t	http://192.168.1.117:3001/static/catalog/208.png	\N
167	222	222	TOSTADA DE CANELA	8	8	t	http://192.168.1.117:3001/static/catalog/222.png	\N
170	225	225	VIENESA DE CREMA, COCO, HIGO Y NUEZ	17	8	t	http://192.168.1.117:3001/static/catalog/225.png	\N
172	226	226	VOLTEADO DE NUEZ	13	8	t	http://192.168.1.117:3001/static/catalog/226.png	\N
191	243	243	LECHE SANTA CLARA DESLACTOSADA DE UN LITRO	30	10	t	http://192.168.1.117:3001/static/catalog/243.png	\N
192	244	244	LECHE SANTA CLARA ENTERA DE UN LITRO	30	10	t	http://192.168.1.117:3001/static/catalog/244.png	\N
193	245	245	NUTRI DE UN LITRO	22	10	t	http://192.168.1.117:3001/static/catalog/245.png	\N
199	261	261	BOLILLO CON AJONJOLI MEDIANO	5	11	t	http://192.168.1.117:3001/static/catalog/261.png	\N
196	258	258	BARRA VIEJA NATURAL	30	11	t	\N	\N
197	259	259	BARRA VIEJA RELLENA CON QUESO PHILADELPHIA	55	11	t	\N	\N
107	131	131	MULTI MARMOLEADO	14	5	t	http://192.168.1.117:3001/static/catalog/131.png	\N
110	144	144	NOVIA	9	6	t	http://192.168.1.117:3001/static/catalog/144.png	\N
112	146	146	NUEZ	41	6	t	http://192.168.1.117:3001/static/catalog/146.png	\N
115	149	149	OJO DE VENADO	8	6	t	http://192.168.1.117:3001/static/catalog/149.png	\N
125	157	157	PASTEL DE ELOTE	35	6	t	http://192.168.1.117:3001/static/catalog/157.png	\N
129	161	161	PIEDRA DE CHOCOLATE	9	6	t	http://192.168.1.117:3001/static/catalog/161.png	\N
130	162	162	PINGUINO	12	6	t	http://192.168.1.117:3001/static/catalog/162.png	\N
132	164	164	PIZZA PEPPERONI REBANADA	17	6	t	http://192.168.1.117:3001/static/catalog/164.png	\N
134	166	166	PIZZA HAWAIANA COMPLETA	129	6	t	http://192.168.1.117:3001/static/catalog/166.png	\N
135	167	167	PIZZA PEPPERONI COMPLETA	99	6	t	http://192.168.1.117:3001/static/catalog/167.png	\N
137	169	169	PLOMO CON COCO	8	6	t	http://192.168.1.117:3001/static/catalog/169.png	\N
139	171	171	PLUMA	8	6	t	http://192.168.1.117:3001/static/catalog/171.png	\N
143	185	185	REBANADA CARIOCA DE GRANILLO RELLENA DE CHABACANO	9	7	t	http://192.168.1.117:3001/static/catalog/185.png	\N
145	187	187	REBANADA DE AZUCAR	8	7	t	http://192.168.1.117:3001/static/catalog/187.png	\N
146	188	188	REBANADA SOL Y SOMBRA	9	7	t	http://192.168.1.117:3001/static/catalog/188.png	\N
148	191	191	ROL DE CANELA	17	7	t	http://192.168.1.117:3001/static/catalog/191.png	\N
150	193	193	ROLLO DE MANZANA CANELA	11	7	t	http://192.168.1.117:3001/static/catalog/193.png	\N
151	195	195	ROLLO DE QUESO ZARZA	17	7	t	http://192.168.1.117:3001/static/catalog/195.png	\N
153	197	197	ROSCA DE ARANDANO CON NUEZ	17	7	t	http://192.168.1.117:3001/static/catalog/197.png	\N
156	200	200	ROSCA C. DE NARANJA	200	7	t	http://192.168.1.117:3001/static/catalog/200.png	\N
157	201	201	ROSCA DE CHOCOLATE RELLENA DE QUESO ZARZA	17	7	t	http://192.168.1.117:3001/static/catalog/201.png	\N
159	203	203	ROSCA DE VAINILLA RELLENA DE QUESO ZARZA	17	7	t	http://192.168.1.117:3001/static/catalog/203.png	\N
160	204	204	ROSCA C. DE VAINILLA RELLENA DE QUESO ZARZA	200	7	t	http://192.168.1.117:3001/static/catalog/204.png	\N
165	220	220	TAPADO O MORDIDA	8	8	t	http://192.168.1.117:3001/static/catalog/220.png	\N
186	238	238	LECHE ALPURA DE CHOCOLATE DE UN LITRO	30	10	t	http://192.168.1.117:3001/static/catalog/238.png	\N
188	240	240	LECHE ALPURA DE VAINILLA DE UN LITRO	30	10	t	http://192.168.1.117:3001/static/catalog/240.png	\N
123	175	175	PAN DE MUERTO DOBLE	18	6	t	http://192.168.1.117:3001/static/catalog/175.png	\N
124	177	177	PAN DE MUERTO CHICO	5	6	t	http://192.168.1.117:3001/static/catalog/177.png	\N
177	1219	1219	ROSCA DE REYES NUEZ MINI	55	9	t	http://192.168.1.117:3001/static/catalog/1219.png	\N
181	1220	1220	ROSCA DE REYES ZARZAMORA PHIL MINI	80	9	t	http://192.168.1.117:3001/static/catalog/1220.png	\N
205	267	267	CHAPATA NATURAL	8	11	t	\N	\N
206	268	268	CHAPATA REPOSADA	8	11	t	\N	\N
207	269	269	HAMBURGUESA CHICA (MARINA)	7.5	11	t	\N	\N
208	270	270	HAMBURGUESA GRANDE	9.5	11	t	\N	\N
209	271	271	HAMBURGUESA JUMBO	10.5	11	t	\N	\N
211	273	273	HOGAZAS	0	11	t	\N	\N
212	274	274	HOJALDRA GRANDE	9	11	t	\N	\N
213	275	275	HOJALDRA MEDIANA	8	11	t	\N	\N
215	277	277	MINIPAMBACITOS	15	11	t	\N	\N
220	282	282	TELERA SUAVE CHICA	3	11	t	\N	\N
221	283	283	TELERA SUAVE GRANDE	4.5	11	t	\N	\N
222	284	284	TELERA SUAVE CON AJONJOLI CHICA	4	11	t	\N	\N
223	285	285	TELERA SUAVE CON AJONJOLI EXTRAGRANDE	9	11	t	\N	\N
225	287	287	TELERA SUAVE CON AJONJOLI MEDIANA	5	11	t	\N	\N
227	299	299	PUERQUITO	8	12	t	\N	\N
228	300	300	BOLINACHOS	17	12	t	\N	\N
229	302	302	BURRITAS	8	12	t	\N	\N
231	304	304	COCKTEL DE CHOCOLATE	8	12	t	\N	\N
232	305	305	DONA DECORADA	13	12	t	\N	\N
234	307	307	DOMINO CON CHANTILLY Y RAYAS DE CHOCOLATE	9	12	t	\N	\N
235	308	308	DOMINO CON GRANILLO DE COLORES	9	12	t	\N	\N
236	309	309	DOMINO INTEGRAL	10	12	t	\N	\N
237	310	310	DOMINO SALPICADO DE CHOCOLATE	9	12	t	\N	\N
239	312	312	EMPAREDADO	9	12	t	\N	\N
240	313	313	ESCUADRAS	9	12	t	\N	\N
241	314	314	Garibaldi	15	12	t	\N	\N
243	316	316	MINIPOLVORON CHOCOLATE	5	12	t	\N	\N
244	317	317	MINIPOLVORON SEVILLANO DE NUEZ	5	12	t	\N	\N
247	320	320	NIDO CON PASTA DE CONCHA Y MERMELADA DE FRESA AL CENTRO	8	12	t	\N	\N
248	322	322	NUEVES CON COCO Y CANELA	10	12	t	\N	\N
249	323	323	PASTELILLO DE CHOCOLATE	12	12	t	\N	\N
250	324	324	PASTELILLO DE VAINILLA	12	12	t	\N	\N
252	326	326	PAY DE LIMON GLASEADO	23	12	t	\N	\N
253	327	327	PAY DE QUESO EN CUADRITO	17	12	t	\N	\N
254	328	328	SANDIAS	9	12	t	\N	\N
255	329	329	TARTA DE NUEZ	30	12	t	\N	\N
256	330	330	TARTA DE QUESO FRESA CAJETA	30	12	t	\N	\N
214	276	276	HOT DOGS	8	11	t	\N	\N
217	279	279	PAN INTEGRAL	8	11	t	\N	\N
245	318	318	MUELA	9	12	t	http://192.168.1.117:3001/static/catalog/318.jpg	\N
233	306	306	COLADERAS	8	12	t	\N	\N
242	315	315	HOJALDRA CHICA 1600 BASTON (50g)	8	12	t	\N	\N
246	319	319	NIDO CON AZUCAR Y MERMELADA DE FRESA AL CENTRO	8	12	t	\N	\N
272	356	356	LATA CAL C TOSE 400G	69	13	t	http://192.168.1.117:3001/static/catalog/356.png	\N
210	272	272	HAMBURGUESA MEDIANA	8.5	11	t	http://192.168.1.117:3001/static/catalog/272.png	\N
218	280	280	TELERA ARTESANAL CHICA	3	11	t	http://192.168.1.117:3001/static/catalog/280.png	\N
224	286	286	TELERA SUAVE CON AJONJOLI GRANDE	7	11	t	http://192.168.1.117:3001/static/catalog/286.png	\N
226	298	298	ALMOHADA	8	12	t	http://192.168.1.117:3001/static/catalog/298.png	\N
258	342	342	SOBRE TE DE MANZANILLA MC CORMICK	3	13	t	http://192.168.1.117:3001/static/catalog/342.png	\N
259	343	343	SOBRE TE VERDE MC CORMICK	3	13	t	http://192.168.1.117:3001/static/catalog/343.png	\N
261	345	345	SOBRE CHOCOMILK 18G	8	13	t	http://192.168.1.117:3001/static/catalog/345.png	\N
262	346	346	SOBRE NESCAFE CLASICO 28G	28	13	t	http://192.168.1.117:3001/static/catalog/346.png	\N
264	348	348	SOBRE COFFEE MATE 34G	10	13	t	http://192.168.1.117:3001/static/catalog/348.png	\N
265	349	349	FRASCO NESCAFE CLASICO 60G	70	13	t	http://192.168.1.117:3001/static/catalog/349.png	\N
267	351	351	BOTE COFFEE MATE 160G	39	13	t	http://192.168.1.117:3001/static/catalog/351.png	\N
269	353	353	SOBRE CHOCOMILK 160G	27	13	t	http://192.168.1.117:3001/static/catalog/353.png	\N
270	354	354	SOBRE CAL C TOSE 160G	30	13	t	http://192.168.1.117:3001/static/catalog/354.png	\N
273	357	357	LATA CHOCOMILK 400G	69	13	t	http://192.168.1.117:3001/static/catalog/357.png	\N
275	369	369	LLAVERO CHICO	100	14	t	http://192.168.1.117:3001/static/catalog/369.png	\N
277	371	371	LLAVERO GRANDE	140	14	t	http://192.168.1.117:3001/static/catalog/371.png	\N
289	393	393	COBERTURA DE CHOCOLATE CON NUEZ PARA HELADO TRIPLE	17	15	t	http://192.168.1.117:3001/static/catalog/393.png	12
279	383	383	COBERTURA DE CHOCOLATE PARA HELADO SENCILLO	5	15	t	http://192.168.1.117:3001/static/catalog/383.png	2
281	385	385	COBERTURA DE CHOCOLATE CON NUEZ PARA HELADO SENCILLO	11	15	t	http://192.168.1.117:3001/static/catalog/385.png	4
282	386	386	HELADO DOBLE (2 BOLAS)	34	15	t	http://192.168.1.117:3001/static/catalog/386.png	5
283	387	387	COBERTURA DE CHOCOLATE PARA HELADO DOBLE	7	15	t	http://192.168.1.117:3001/static/catalog/387.png	6
285	389	389	COBERTURA DE CHOCOLATE CON NUEZ PARA HELADO DOBLE	15	15	t	http://192.168.1.117:3001/static/catalog/389.png	8
286	390	390	HELADO TRIPLE (3 BOLAS)	50	15	t	http://192.168.1.117:3001/static/catalog/390.png	9
291	395	395	CANASTA SENCILLA (I BOLA)	30	15	t	http://192.168.1.117:3001/static/catalog/395.png	\N
293	397	397	CANASTA TRIPLE (3 BOLAS)	65	15	t	http://192.168.1.117:3001/static/catalog/397.png	\N
294	398	398	FRUHESPE (2 BOLAS)	55	15	t	http://192.168.1.117:3001/static/catalog/398.png	\N
296	400	400	HELADO UN LITRO	170	15	t	http://192.168.1.117:3001/static/catalog/400.png	\N
297	401	401	CONO	3	15	t	http://192.168.1.117:3001/static/catalog/401.png	\N
299	403	403	GALLETA ROLLO	5	15	t	http://192.168.1.117:3001/static/catalog/403.png	\N
301	405	405	BOLA EXTRA DE HELADO	16	15	t	http://192.168.1.117:3001/static/catalog/405.png	\N
316	SIS-460	\N	CHAROLA DE PAN	20	1	t	\N	\N
317	SIS-461	\N	CAJA DE PAN	30	1	t	\N	\N
318	SIS-478	\N	CONDE	12	3	t	\N	\N
319	SIS-474	\N	MULTI COCO MOKA	14	5	t	\N	\N
320	SIS-475	\N	NEVADA DE NUTELLA	14	6	t	\N	\N
321	SIS-479	\N	PALILLO SALADO	3	6	t	\N	\N
251	325	325	PASTISETAS	3	12	t	\N	\N
322	SIS-470	\N	PAN DE ELOTE MEDIANO	25	6	t	\N	\N
323	SIS-473	\N	PAN DE ELOTE CHICO	20	6	t	\N	\N
324	SIS-471	\N	ROLLO DE FRESA CON AVENA	11	7	t	\N	\N
325	SIS-225	\N	VIENESA DE CREMA; COCO; HIGO Y NUEZ	17	8	t	\N	\N
326	SIS-476	\N	LECHE SANTA CLARA SABOR 180 ML	13	10	t	\N	\N
327	SIS-477	\N	LECHE SABOR ALPURA	11	10	t	\N	\N
328	SIS-360	\N	NESCAFE CAPUCHINO 20g	15	13	t	\N	\N
329	SIS-450	\N	HELADO 4 LITROS UN SABOR	560	15	t	\N	\N
330	SIS-451	\N	HELADO 5 LITROS UN SABOR	700	15	t	\N	\N
331	SIS-452	\N	HELADO 4 LITROS VARIOS SABORES	680	15	t	\N	\N
332	SIS-453	\N	HELADO 5 LITROS VARIOS SABORES	850	15	t	\N	\N
333	SIS-FIE	\N	FIGURA ESPANOLA	8	4	t	\N	\N
334	SIS-MOO	\N	MONO DE PAN	8	5	t	\N	\N
335	SIS-PPAN	\N	PAMBAZO PILONCILLO ANIS	5	6	t	\N	\N
336	SIS-CHUP	\N	CHURRO PROMOCION	10	3	t	\N	\N
337	SIS-DRG	\N	DEDO RELLENO PINA AZUCAR GLASS	9	3	t	\N	\N
338	SIS-BPF	\N	BARRITA PINA O FRESA	8	2	t	\N	\N
339	SIS-CDP	\N	CANASTA DE PINA	9	3	t	\N	\N
340	SIS-EMP2	\N	EMPANADA MADRILENA CREMA PASTELERA	15	4	t	\N	\N
341	SIS-EMP3	\N	EMPANADA TABASQUENA RELLENO PINA	9	4	t	\N	\N
342	SIS-RFP	\N	RIEL FRESA O PINA	9	7	t	\N	\N
343	SIS-RFA	\N	ROLLO FRESA CON AVENA	11	7	t	\N	\N
344	SIS-RPS	\N	ROLLO PINA CON SALVADO	11	7	t	\N	\N
345	SIS-VCH	\N	VIENESA CREMA COCO HIGO NUEZ	17	8	t	\N	\N
346	SIS-TAB	\N	TABASQUENO	8	8	t	\N	\N
347	SIS-LSCF	\N	LECHE SANTA CLARA SABOR 180ML	13	10	t	\N	\N
348	SIS-BUNU	\N	BUNUELOS	8	12	t	\N	\N
349	SIS-NENV	\N	NINO ENVUELTO	25	12	t	\N	\N
350	SIS-PDMM	\N	PAN DE MUERTO MUNECO	18	6	t	\N	\N
10	10	10	BAGUETTE GRANDE	24	1	t	http://192.168.1.117:3001/static/catalog/10.png	\N
71	100	100	GALLETA DE BOLSA CON NUEZ	8	4	t	http://192.168.1.117:3001/static/catalog/100.png	\N
73	102	102	GALLETA DE COCO CON PUNTO	8	4	t	http://192.168.1.117:3001/static/catalog/102.png	\N
91	105	105	HUESO DE MANTEQUILLA	8	4	t	http://192.168.1.117:3001/static/catalog/105.png	\N
93	117	117	LADRILLO CHOCOLATE	9	5	t	http://192.168.1.117:3001/static/catalog/117.png	\N
12	12	12	COSTO EXTRA 2	2	1	t	http://192.168.1.117:3001/static/catalog/12.jpg	\N
97	121	121	MANTECONCHA DE CHOCOLATE	10	5	t	http://192.168.1.117:3001/static/catalog/121.png	\N
100	124	124	MIL HOJAS	17	5	t	http://192.168.1.117:3001/static/catalog/124.png	\N
103	126	126	MINIS	31	5	t	http://192.168.1.117:3001/static/catalog/126.png	\N
105	129	129	MUFIN DE VAINILLA CON RELLENO DE MANGO	13	5	t	http://192.168.1.117:3001/static/catalog/129.png	\N
14	14	14	COSTO EXTRA 6	6	1	t	http://192.168.1.117:3001/static/catalog/14.jpg	\N
108	142	142	NEGRITO	8	6	t	http://192.168.1.117:3001/static/catalog/142.png	\N
109	143	143	NEVADA	14	6	t	http://192.168.1.117:3001/static/catalog/143.png	\N
111	145	145	NUBE	8	6	t	http://192.168.1.117:3001/static/catalog/145.png	\N
114	148	148	OJO DE BUEY	10	6	t	http://192.168.1.117:3001/static/catalog/148.png	\N
116	150	150	OREJA	8	6	t	http://192.168.1.117:3001/static/catalog/150.png	\N
118	153	153	PANADEROS	8	6	t	http://192.168.1.117:3001/static/catalog/153.png	\N
120	155	155	PANQUE DE ELOTE	18	6	t	http://192.168.1.117:3001/static/catalog/155.png	\N
126	158	158	PASTEL C. DE ELOTE	330	6	t	http://192.168.1.117:3001/static/catalog/158.png	\N
128	160	160	PIEDRA DE AZUCAR	9	6	t	http://192.168.1.117:3001/static/catalog/160.png	\N
131	163	163	PIZZA HAWAIANA REBANADA	22	6	t	http://192.168.1.117:3001/static/catalog/163.png	\N
133	165	165	PIZZA COMBINADA HAW/PEP COMPLETA	117	6	t	http://192.168.1.117:3001/static/catalog/165.png	\N
136	168	168	PLATANO	8	6	t	http://192.168.1.117:3001/static/catalog/168.png	\N
17	17	17	CHAROLA MEDIANA DE CARTON	30	1	t	http://192.168.1.117:3001/static/catalog/17.png	\N
138	170	170	PLOMO CON NUEZ	8	6	t	http://192.168.1.117:3001/static/catalog/170.png	\N
141	173	173	POLVORON SEVILLANO	5	6	t	http://192.168.1.117:3001/static/catalog/173.png	\N
142	184	184	REBANADA CARIOCA DE COCO RELLENA DE CHABACANO	9	7	t	http://192.168.1.117:3001/static/catalog/184.png	\N
147	189	189	REJA	8	7	t	http://192.168.1.117:3001/static/catalog/189.png	\N
149	192	192	ROLLO DE JAMON Y QUESO PHILADELPHIA	13	7	t	http://192.168.1.117:3001/static/catalog/192.png	\N
238	311	311	EMPANADA UNTADA CON RELLENO DE FRESA	8	12	t	http://192.168.1.117:3001/static/catalog/311.jpg	\N
302	406	406	FRESAS CON CREMA	40	15	t	http://192.168.1.117:3001/static/catalog/406.png	\N
312	426	426	PALETA DE KIWI	30	16	t	\N	10
306	420	420	COBERTURA DE CHOCOLATE CON NUEZ PARA PALETA MEDIANA	11	16	t	http://192.168.1.117:3001/static/catalog/420.png	4
307	421	421	PALETA GRANDE	24	16	t	http://192.168.1.117:3001/static/catalog/421.png	5
309	423	423	COBERTURA DE CHOCOLATE CON CONFITERIA PARA PALETA GRANDE	11	16	t	http://192.168.1.117:3001/static/catalog/423.png	7
313	436	436	AGUA DE MEDIO LITRO	16	17	t	http://192.168.1.117:3001/static/catalog/436.png	\N
314	437	437	AGUA DE UN LITRO	30	17	t	http://192.168.1.117:3001/static/catalog/437.png	\N
86	137	137	HOJALDRA DE CANELA	18	4	t	http://192.168.1.117:3001/static/catalog/137.png	\N
311	425	425	PALETA DE CREMA	30	16	t	http://192.168.1.117:3001/static/catalog/425.png	9
152	196	196	ROSCA BOLSA CON NUEZ	8	7	t	http://192.168.1.117:3001/static/catalog/196.png	\N
154	198	198	ROSCA C. DE ARANDANO CON NUEZ	200	7	t	http://192.168.1.117:3001/static/catalog/198.png	\N
158	202	202	ROSCA C. DE CHOCOLATE RELLENA DE QUESO ZARZA	200	7	t	http://192.168.1.117:3001/static/catalog/202.png	\N
163	207	207	RUEDA DE MANTECA	8	7	t	http://192.168.1.117:3001/static/catalog/207.png	\N
166	221	221	TEJAMANI DE MANTECA CON AZUCAR	8	8	t	http://192.168.1.117:3001/static/catalog/221.png	\N
169	224	224	TRONCO DE CANELA	8	8	t	http://192.168.1.117:3001/static/catalog/224.png	\N
185	237	237	NATA	50	10	t	http://192.168.1.117:3001/static/catalog/237.png	\N
187	239	239	LECHE ALPURA DE FRESA DE UN LITRO	30	10	t	http://192.168.1.117:3001/static/catalog/239.png	\N
189	241	241	LECHE ALPURA SEMI DE UN LITRO	30	10	t	http://192.168.1.117:3001/static/catalog/241.png	\N
190	242	242	LECHE ALPURA SEMI DESLACTOSADA DE UN LITRO	30	10	t	http://192.168.1.117:3001/static/catalog/242.png	\N
194	256	256	BAGUETTE CHICO	5	11	t	http://192.168.1.117:3001/static/catalog/256.png	\N
216	278	278	PAMBAZO MEXICANO	4	11	t	http://192.168.1.117:3001/static/catalog/278.png	\N
219	281	281	TELERA ARTESANAL GRANDE	4.5	11	t	http://192.168.1.117:3001/static/catalog/281.png	\N
20	29	29	ABANICO	8	2	t	http://192.168.1.117:3001/static/catalog/29.png	\N
21	30	30	ALMEJA	8	2	t	http://192.168.1.117:3001/static/catalog/30.png	\N
230	303	303	CALABAZA CON CREMA PASTELERA	12	12	t	http://192.168.1.117:3001/static/catalog/303.png	\N
25	32	32	BARQUILLO DE CHANTILLY	14	2	t	http://192.168.1.117:3001/static/catalog/32.png	\N
257	341	341	SOBRE TE DE LIMON MC CORMICK	3	13	t	http://192.168.1.117:3001/static/catalog/341.png	\N
260	344	344	SOBRE NESCAFE CLASICO 14G	16	13	t	http://192.168.1.117:3001/static/catalog/344.png	\N
263	347	347	SOBRE CAFE LEGAL DE GRANO 28G	10	13	t	http://192.168.1.117:3001/static/catalog/347.png	\N
28	35	35	BERLINES DE CHANTILLY	12	2	t	http://192.168.1.117:3001/static/catalog/35.png	\N
266	350	350	FRASCO CAFE ORO 50G	36	13	t	http://192.168.1.117:3001/static/catalog/350.png	\N
268	352	352	SOBRE CHOCOLATE MORELIA PRESIDENCIAL 155G	21	13	t	http://192.168.1.117:3001/static/catalog/352.png	\N
271	355	355	TABLETA CHOCOLATE ABUELITA 90G	24	13	t	http://192.168.1.117:3001/static/catalog/355.png	\N
274	358	358	AZUCAR A GRANEL 500G	15	13	t	http://192.168.1.117:3001/static/catalog/358.png	\N
30	37	37	BESO CON RELLENO DE DURAZNO	8	2	t	http://192.168.1.117:3001/static/catalog/37.png	\N
276	370	370	LLAVERO MEDIANO	120	14	t	http://192.168.1.117:3001/static/catalog/370.png	\N
290	394	394	COPA	55	15	t	http://192.168.1.117:3001/static/catalog/394.png	\N
292	396	396	CANASTA DOBLE (2 BOLAS)	50	15	t	http://192.168.1.117:3001/static/catalog/396.png	\N
295	399	399	HELADO MEDIO LITRO	85	15	t	http://192.168.1.117:3001/static/catalog/399.png	\N
4	4	4	TELERA SUAVE MEDIANA	3	1	t	http://192.168.1.117:3001/static/catalog/4.png	\N
298	402	402	GALLETA CANASTA	5	15	t	http://192.168.1.117:3001/static/catalog/402.png	\N
300	404	404	CUCHARADA EXTRA DE COBERTURA	4	15	t	http://192.168.1.117:3001/static/catalog/404.png	\N
35	42	42	BUDIN DE HIGO CON COCO	17	2	t	http://192.168.1.117:3001/static/catalog/42.png	\N
315	438	438	MALTEADA	65	17	t	http://192.168.1.117:3001/static/catalog/438.png	\N
36	53	53	CACAHUATE	8	3	t	http://192.168.1.117:3001/static/catalog/53.png	\N
38	55	55	CALVO DE GRANILLO DE COLORES	8	3	t	http://192.168.1.117:3001/static/catalog/55.png	\N
41	59	59	CAZUELA DE MANTEQUILLA	15	3	t	http://192.168.1.117:3001/static/catalog/59.png	\N
42	60	60	CHICHARRON	8	3	t	http://192.168.1.117:3001/static/catalog/60.png	\N
45	63	63	CHOCOFLAN	25	3	t	http://192.168.1.117:3001/static/catalog/63.png	\N
47	65	65	CHURRO FRIO	3	3	t	http://192.168.1.117:3001/static/catalog/65.png	\N
50	67	67	CONCHA AMARILLA CON BOLITA	8	3	t	http://192.168.1.117:3001/static/catalog/67.png	\N
7	7	7	BOLILLITO DE ARANDANO	6	1	t	http://192.168.1.117:3001/static/catalog/7.png	\N
56	71	71	CUBILETE	12	3	t	http://192.168.1.117:3001/static/catalog/71.png	\N
59	75	75	DEDO CON RELLENO DE ZARZAMORA Y CHOCOLATE	9	3	t	http://192.168.1.117:3001/static/catalog/75.png	\N
62	78	78	DONA DE AZUCAR	9	3	t	http://192.168.1.117:3001/static/catalog/78.png	\N
8	8	8	BOLILLITO DE NUEZ	6	1	t	http://192.168.1.117:3001/static/catalog/8.png	\N
9	9	9	BAGUETTE MEDIANO	12	1	t	http://192.168.1.117:3001/static/catalog/9.png	\N
67	95	95	ESPOLVOREADO	31	4	t	http://192.168.1.117:3001/static/catalog/95.png	\N
69	98	98	FLOR	9	4	t	http://192.168.1.117:3001/static/catalog/98.png	\N
288	392	392	COBERTURA DE CHOCOLATE CON CONFITERIA PARA HELADO TRIPLE	13	15	t	http://192.168.1.117:3001/static/catalog/392.png	11
287	391	391	COBERTURA DE CHOCOLATE PARA HELADO TRIPLE	9	15	t	http://192.168.1.117:3001/static/catalog/391.png	10
284	388	388	COBERTURA DE CHOCOLATE CON CONFITERIA PARA HELADO DOBLE	11	15	t	http://192.168.1.117:3001/static/catalog/388.png	7
280	384	384	COBERTURA DE CHOCOLATE CON CONFITERIA PARA HELADO SENCILLO	9	15	t	http://192.168.1.117:3001/static/catalog/384.png	3
278	382	382	HELADO SENCILLO (1 BOLA)	18	15	t	http://192.168.1.117:3001/static/catalog/382.png	1
16	16	16	CHAROLA CHICA DE CARTON	20	1	t	http://192.168.1.117:3001/static/catalog/16.png	\N
23	45	45	ANCESTRAL GRANDE	15	2	t	http://192.168.1.117:3001/static/catalog/45.png	\N
303	417	417	PALETA MEDIANA	13	16	t	http://192.168.1.117:3001/static/catalog/417.png	1
310	424	424	COBERTURA DE CHOCOLATE CON NUEZ PARA PALETA GRANDE	15	16	t	http://192.168.1.117:3001/static/catalog/424.png	8
308	422	422	COBERTURA DE CHOCOLATE PARA PALETA GRANDE	6	16	t	http://192.168.1.117:3001/static/catalog/422.png	6
74	132	132	GALLETA DE NUEZ	8	4	t	http://192.168.1.117:3001/static/catalog/132.png	\N
83	134	134	HOJALDRA DE NARANJA INDIVIDUAL RELLENA	60	4	t	http://192.168.1.117:3001/static/catalog/134.png	\N
85	136	136	HOJALDRA GLASEADA DE CANELA	23	4	t	http://192.168.1.117:3001/static/catalog/136.png	\N
122	174	174	PAN DE MUERTO	9	6	t	http://192.168.1.117:3001/static/catalog/174.png	\N
171	227	227	VOLCAN	8	8	t	http://192.168.1.117:3001/static/catalog/227.png	\N
173	218	218	ROSCA DE REYES NARANJA MINI	40	9	t	http://192.168.1.117:3001/static/catalog/218.png	\N
305	419	419	COBERTURA DE CHOCOLATE CON CONFITERIA PARA PALETA MEDIANA	9	16	t	http://192.168.1.117:3001/static/catalog/419.png	3
304	418	418	COBERTURA DE CHOCOLATE PARA PALETA MEDIANA	5	16	t	http://192.168.1.117:3001/static/catalog/418.png	2
\.


--
-- Data for Name: security_profiles; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.security_profiles (id, name, description, permissions, is_system) FROM stdin;
4	RG	Nuevo perfil personalizado	{"pos_retail": "full"}	f
3	CAJERO	Operaci├│n de ventas	{"overview": "full", "pos_retail": "full", "invoicing": null, "auditoria": "full"}	t
1	ADMIN	Acceso total al sistema	{"overview": "full", "pos_retail": "full", "inventory": "full", "warehouse": "full", "vision_train": "full", "production": "full", "financials": "full", "invoicing": "full", "purchasing": "full", "procurement": "full", "logistics": "full", "pos_tables": "full", "waiter": "full", "driver": "full", "seguridad_acceso": "full", "auditoria": "full", "pos_force_unlock": "full", "pos_force_cash_unlock": "full"}	t
2	MANAGER	Gesti├│n operativa	{"overview": "full", "pos_retail": "full", "inventory": null, "warehouse": null, "vision_train": "full", "production": null, "financials": null, "invoicing": null, "purchasing": null, "logistics": null, "seguridad_acceso": "full", "pos_tables": null, "driver": null, "auditoria": "full", "pos_force_unlock": "full", "pos_force_cash_unlock": null}	t
\.


--
-- Data for Name: system_settings; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.system_settings (id, key, value, description, category, input_type) FROM stdin;
1	pos_terminal_status_polling_ms	3000	Frecuencia de actualizaci├│n del estado de las terminales en milisegundos.	polling	number
2	pos_terminal_lock_ttl_m	15	Tiempo de expiraci├│n del bloqueo de terminal (minutos) si no hay latido.	security	number
3	pos_heartbeat_interval_ms	60000	Frecuencia de env├¡o de latido de vida desde el POS (milisegundos).	polling	number
\.


--
-- Data for Name: terminal_sessions; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.terminal_sessions (id, terminal_id, opened_at, closed_at, is_active) FROM stdin;
1	T6	2026-03-13 19:42:50.765239	\N	t
2	CAJA	2026-03-13 20:17:29.223665	\N	t
3	T2	2026-03-13 20:17:52.792385	\N	t
4	T4	2026-03-17 00:48:37.44475	\N	t
5	T3	2026-03-17 00:48:44.313139	\N	t
6	T5	2026-03-17 04:25:33.78757	\N	t
\.


--
-- Data for Name: ticket_items; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.ticket_items (id, ticket_id, product_id, quantity, unit_price, subtotal) FROM stdin;
1	1	229	1	8	8
2	1	233	1	7	7
3	1	232	2	13	26
4	1	231	1	8	8
5	1	235	1	9	9
6	1	230	1	12	12
7	1	234	1	9	9
172	17	20	1	8	8
173	17	21	2	8	16
174	17	25	2	12	24
11	3	2	1	2	2
12	3	1	1	2	2
13	3	3	1	3	3
14	3	4	1	3	3
175	17	22	1	9	9
176	17	26	1	12	12
177	17	23	1	15	15
178	17	27	1	7	7
179	17	168	1	15	15
180	17	167	2	7	14
181	17	171	1	8	8
182	16	21	1	8	8
183	16	25	1	12	12
184	16	22	1	9	9
185	16	26	1	12	12
186	16	23	1	15	15
27	6	3	1	3	3
28	6	7	1	6	6
29	6	8	1	6	6
30	6	4	1	3	3
187	16	27	1	7	7
188	16	31	1	9	9
189	16	30	1	8	8
867	129	1	1	2	2
868	129	112	1	41	41
378	75	286	1	50	50
380	76	147	1	8	8
386	77	36	1	8	8
869	129	48	1	10	10
196	26	37	3	8	24
197	26	41	2	15	30
198	26	38	1	8	8
28319	2442	5	5	3	15
28320	2442	1	1	2	2
28321	2442	20	1	8	8
28322	2442	62	2	9	18
199	26	42	7	8	56
200	26	43	1	12	12
201	26	39	78	7	546
870	129	5	4	3	12
871	129	3	2	3	6
2120	272	1	1	2	2
28323	2442	52	2	8	16
17414	1601	1	1	2	2
17415	1601	114	2	10	20
12407	1209	63	2	9	18
211	27	1	1	2	2
212	27	52	1	7	7
213	27	54	1	35	35
214	27	75	1	12	12
215	27	74	1	8	8
216	27	71	1	8	8
12408	1209	1	1	2	2
12409	1209	5	3	3	9
12410	1209	4	7	3	21
217	27	70	1	7	7
218	27	67	1	30	30
219	27	66	1	8	8
221	29	10	150	22	3300
223	30	98	40	10	400
228	31	174	1	190	190
229	31	175	1	290	290
230	31	178	1	270	270
231	31	179	1	400	400
236	28	67	1	30	30
237	28	66	1	8	8
238	28	71	1	8	8
239	28	68	1	7	7
123	4	1	1	2	2
124	22	1	1	2	2
125	23	1	1	2	2
126	24	1	1	2	2
127	21	1	1	2	2
128	25	1	1	2	2
129	15	5	1	3	3
130	15	1	1	2	2
131	15	2	1	2	2
132	15	6	1	3	3
133	15	3	1	3	3
134	15	7	1	6	6
135	15	4	1	3	3
136	15	8	1	6	6
137	9	37	1	8	8
138	9	38	1	8	8
139	9	42	1	8	8
140	9	41	1	15	15
141	8	1	1	2	2
142	8	2	1	2	2
143	8	3	1	3	3
144	19	167	1	7	7
145	19	166	1	7	7
146	19	170	1	17	17
147	19	171	1	8	8
148	19	168	1	15	15
149	12	110	1	9	9
150	12	114	2	10	20
151	12	109	2	17	34
152	12	113	1	25	25
153	12	117	1	24	24
154	12	118	1	7	7
155	12	119	1	30	30
156	12	115	1	10	10
163	18	167	1	7	7
164	18	171	1	8	8
165	18	166	1	7	7
166	18	170	1	17	17
167	14	26	1	12	12
168	14	22	1	9	9
169	13	23	10	15	150
170	13	27	4	7	28
171	13	26	9	12	108
2121	272	3	2	3	6
596	98	1	1	2	2
597	98	64	1	13	13
598	98	148	1	17	17
599	98	130	1	12	12
600	98	105	1	13	13
2122	272	8	3	6	18
2123	272	5	6	3	18
12390	1207	1	2	2	4
6704	693	95	4	8	32
12391	1207	106	1	14	14
12392	1207	63	2	9	18
269	37	166	1	7	7
270	37	170	1	17	17
271	37	167	1	7	7
272	37	171	1	8	8
12393	1207	43	1	12	12
12394	1207	116	1	8	8
12395	1207	51	1	8	8
12396	1207	5	5	3	15
12397	1207	3	2	3	6
17416	1601	165	1	8	8
14872	1416	1	1	2	2
14873	1416	4	11	3	33
14882	1417	1	1	2	2
628	100	2	1	2	2
629	100	63	1	9	9
419	38	277	1	140	140
424	44	25	1	12	12
425	44	24	1	8	8
426	44	26	1	12	12
427	44	29	4	12	48
428	44	21	1	8	8
433	56	38	1	8	8
434	56	39	1	7	7
435	56	43	1	12	12
436	56	42	1	8	8
438	54	37	2	8	16
439	54	38	1	8	8
440	54	42	1	8	8
441	54	41	80	15	1200
442	65	276	1	120	120
444	73	282	1	34	34
445	50	32	6	8	48
447	32	144	1	9	9
448	32	148	1	17	17
449	32	147	1	8	8
450	32	143	1	9	9
456	58	171	1	8	8
457	58	170	2	17	34
458	58	167	1	7	7
459	58	166	1	7	7
460	58	168	1	15	15
461	58	172	1	13	13
466	43	1	1	2	2
467	43	7	2	6	12
468	43	6	2	3	6
469	43	2	1	2	2
470	43	3	2	3	6
471	43	8	2	6	12
472	43	4	1	3	3
630	100	130	4	12	48
631	100	114	1	10	10
632	100	95	1	8	8
633	100	99	1	12	12
634	100	150	1	11	11
635	100	24	1	8	8
636	100	27	1	8	8
637	100	30	1	8	8
638	100	36	1	8	8
639	100	145	1	8	8
511	85	24	1	8	8
512	85	25	2	12	24
513	85	26	1	12	12
514	85	22	1	9	9
520	34	168	1	15	15
521	34	167	1	8	8
522	34	171	1	8	8
523	34	170	1	17	17
28330	2450	1	1	2	2
28331	2450	3	7	3	21
28332	2450	27	1	8	8
28333	2450	114	1	10	10
535	92	41	1	15	15
536	92	339	1	9	9
537	92	38	1	8	8
538	92	37	1	8	8
14883	1417	5	12	3	36
14884	1417	7	3	6	18
14885	1417	8	3	6	18
14886	1417	6	2	3	6
14887	1417	335	1	5	5
544	82	22	2	9	18
545	82	26	2	14	28
546	82	25	1	14	14
547	82	21	1	8	8
548	83	25	1	14	14
549	83	26	1	14	14
550	83	22	1	9	9
551	87	25	1	14	14
552	87	26	1	14	14
553	87	21	1	8	8
554	87	22	1	9	9
555	87	23	1	15	15
556	87	24	1	8	8
14888	1417	120	1	18	18
14889	1417	100	1	17	17
17417	1601	36	1	8	8
17418	1601	157	1	17	17
17419	1601	52	1	8	8
28334	2450	32	1	8	8
28335	2450	46	1	6	6
28336	2450	96	3	8	24
16321	1524	282	2	34	68
16322	1509	1	1	2	2
16323	1509	103	1	31	31
640	100	51	3	8	24
641	100	1	1	2	2
642	100	3	11	3	33
16367	1527	1	1	2	2
16368	1527	3	13	3	39
708	108	5	10	3	30
709	108	6	3	3	9
734	112	1	1	2	2
735	112	5	3	3	9
741	97	1	1	2	2
742	97	5	8	3	24
768	117	1	1	2	2
769	117	4	4	3	12
770	117	58	1	13	13
771	117	96	1	8	8
387	77	41	3	15	45
388	77	43	2	12	24
389	77	46	1	6	6
390	77	47	2	3	6
607	99	4	6	3	18
608	99	27	1	8	8
283	36	168	1	15	15
284	36	167	2	7	14
285	36	171	1	8	8
286	36	166	1	7	7
609	99	14	1	6	6
288	45	20	9	8	72
610	99	13	1	4	4
611	99	62	1	9	9
612	99	58	1	13	13
648	101	1	1	2	2
649	101	129	1	9	9
650	101	143	1	9	9
403	78	311	1	30	30
296	46	30	9	8	72
404	78	307	1	24	24
298	47	29	7	12	84
405	78	303	1	13	13
300	48	31	10	9	90
406	78	304	12	5	60
407	78	308	1	6	6
651	101	30	1	8	8
408	78	312	1	30	30
24002	2148	6	16	3	48
652	101	3	2	3	6
1612	223	1	1	2	2
664	103	1	1	2	2
665	103	30	1	8	8
311	52	185	6	50	300
666	103	62	1	9	9
667	103	64	1	13	13
668	103	165	1	8	8
669	103	114	1	10	10
670	103	41	1	15	15
671	103	27	1	8	8
672	103	56	1	12	12
673	103	107	1	14	14
679	104	1	1	2	2
680	104	3	5	3	15
681	104	58	1	13	13
682	104	20	1	8	8
683	104	52	2	8	16
1613	223	8	7	6	42
904	132	5	6	3	18
1614	223	7	9	6	54
692	105	1	1	2	2
693	105	145	1	8	8
694	105	52	1	8	8
695	105	151	1	17	17
696	105	6	1	3	3
697	106	1	1	2	2
698	106	6	2	3	6
335	33	168	1	15	15
336	33	167	2	7	14
337	33	171	1	8	8
338	33	172	1	13	13
339	49	27	11	7	77
20391	1851	1	1	2	2
20392	1851	63	3	9	27
5458	558	5	8	3	24
699	106	34	1	8	8
12411	1209	28	1	12	12
12433	775	1	1	2	2
718	109	1	1	2	2
719	109	4	2	3	6
720	109	5	4	3	12
721	109	32	1	8	8
20393	1851	56	2	12	24
351	62	143	45	9	405
420	53	191	2	28	56
353	63	41	12	15	180
421	53	187	1	30	30
355	64	98	12	10	120
356	20	37	1	8	8
357	20	38	1	8	8
358	20	42	3	8	24
359	20	41	1	15	15
360	20	46	1	6	6
722	109	114	1	10	10
422	53	188	1	30	30
12434	775	63	1	9	9
723	109	165	2	8	16
423	53	192	1	28	28
366	68	266	1	36	36
10256	1017	1	1	2	2
368	69	315	1	65	65
12435	775	64	1	13	13
370	70	188	1	30	30
20394	1851	51	1	8	8
20395	1851	46	5	6	30
437	57	43	50	12	600
443	67	265	1	70	70
446	74	286	1	50	50
451	35	166	1	7	7
452	35	170	1	17	17
453	35	169	1	7	7
454	35	165	1	8	8
455	35	167	1	7	7
462	59	168	1	15	15
463	59	166	1	7	7
464	59	167	1	7	7
465	59	172	1	13	13
724	109	56	1	12	12
508	88	20	1	8	8
509	88	21	1	8	8
510	88	22	1	9	9
515	81	42	1	8	8
516	81	38	1	8	8
517	81	39	1	8	8
518	80	38	1	8	8
519	80	43	1	12	12
528	90	39	1	8	8
529	90	38	1	8	8
530	90	41	1	15	15
531	90	42	1	8	8
532	91	38	1	8	8
533	91	41	1	15	15
534	91	42	1	8	8
562	84	24	2	8	16
563	84	25	1	14	14
564	84	26	1	14	14
565	84	29	1	12	12
566	84	30	1	8	8
1615	223	335	1	5	5
1202	165	105	2	13	26
28337	2450	118	1	8	8
28360	2452	1	1	2	2
28361	2452	6	15	3	45
28362	2452	110	1	9	9
24013	419	1	1	2	2
17447	1603	1	1	2	2
17448	1603	105	1	13	13
8331	862	114	2	10	20
28363	2452	109	1	14	14
28364	2452	165	1	8	8
8332	862	51	3	8	24
8333	862	57	1	9	9
14865	1414	1	1	2	2
905	132	4	5	3	15
912	134	1	2	2	4
913	134	48	1	10	10
914	134	5	4	3	12
14866	1414	5	4	3	12
14867	1414	57	2	9	18
8334	862	62	2	9	18
918	133	1	1	2	2
919	133	5	2	3	6
920	133	3	2	3	6
17449	1603	129	1	9	9
17450	1603	20	1	8	8
17451	1603	56	1	12	12
24014	419	3	10	3	30
8335	862	24	1	8	8
8336	862	116	2	8	16
14868	1414	63	1	9	9
14869	1414	263	1	10	10
28365	2452	347	2	13	26
20368	1846	5	2	3	6
20369	1846	32	1	8	8
20370	1846	339	1	9	9
20373	1849	1	1	2	2
10264	1018	1	1	2	2
10265	1018	129	1	9	9
20374	1849	3	3	3	9
20375	1849	43	1	12	12
20376	1849	27	1	8	8
20377	1848	5	4	3	12
20378	1848	58	1	13	13
956	140	5	3	3	9
957	140	3	21	3	63
20379	1848	44	1	8	8
17472	1605	303	5	13	65
1771	173	1	1	2	2
1772	173	6	10	3	30
17473	1605	314	1	30	30
17474	1605	335	2	5	10
17475	1605	319	1	14	14
20380	1848	145	1	8	8
20381	1848	131	2	22	44
979	144	1	1	2	2
980	144	3	5	3	15
981	144	5	4	3	12
988	130	1	1	2	2
989	130	40	1	19	19
990	130	56	1	12	12
991	130	73	1	8	8
6749	700	307	1	24	24
6750	700	311	1	30	30
1806	239	1	1	2	2
1807	239	3	3	3	9
1003	146	1	1	2	2
1004	146	4	4	3	12
1005	146	56	1	12	12
1006	146	64	1	13	13
1007	146	337	1	9	9
1008	146	20	1	8	8
1017	147	1	1	2	2
1018	147	5	3	3	9
1019	147	3	2	3	6
1020	147	27	1	8	8
1021	147	20	1	8	8
1022	147	342	1	9	9
1023	147	52	1	8	8
1024	147	58	1	13	13
1031	148	1	1	2	2
1032	148	5	10	3	30
1033	148	96	3	8	24
1034	148	120	2	18	36
1035	148	39	1	8	8
1036	148	52	1	8	8
6755	702	314	2	30	60
1808	239	6	5	3	15
1809	239	213	2	8	16
1810	239	91	1	8	8
1824	244	311	2	30	60
1825	243	1	1	2	2
1826	243	3	4	3	12
1827	243	5	3	3	9
1828	243	32	1	8	8
1829	243	57	1	9	9
1830	243	116	2	8	16
1831	243	63	1	9	9
1832	243	342	1	9	9
1115	158	1	1	2	2
1116	158	118	2	8	16
1117	158	62	2	9	18
1118	158	145	1	8	8
1119	158	5	2	3	6
1120	158	56	1	12	12
1121	158	319	1	14	14
1122	158	65	1	8	8
1126	142	5	5	3	15
1127	142	1	1	2	2
1133	137	5	2	3	6
1134	137	4	8	3	24
1136	156	3	6	3	18
1137	156	5	2	3	6
1138	157	5	2	3	6
1139	157	4	1	3	3
1140	157	71	1	8	8
1152	152	1	1	2	2
1153	152	3	2	3	6
1154	152	114	1	10	10
1155	152	96	1	8	8
1156	152	52	1	8	8
1157	152	64	1	13	13
1158	151	114	1	10	10
1159	151	41	2	15	30
1160	151	62	1	9	9
1185	162	1	1	2	2
1186	162	5	9	3	27
772	117	333	2	8	16
773	117	27	1	8	8
774	117	101	1	3	3
892	131	3	6	3	18
893	131	32	1	8	8
12418	1211	1	1	2	2
12419	1211	4	5	3	15
17423	1602	1	1	2	2
894	131	165	1	8	8
895	131	51	1	8	8
782	119	1	1	2	2
783	119	5	4	3	12
896	131	96	1	8	8
897	131	27	1	8	8
898	131	114	1	10	10
899	131	137	1	8	8
900	131	62	1	9	9
901	131	59	1	9	9
1195	165	1	1	2	2
1196	165	5	1	3	3
1197	165	3	1	3	3
793	120	1	1	2	2
794	120	5	2	3	6
795	120	3	2	3	6
796	120	129	1	9	9
797	120	143	1	9	9
798	120	74	1	8	8
799	121	1	1	2	2
800	121	5	4	3	12
801	121	4	4	3	12
1198	165	44	1	8	8
1199	165	20	1	8	8
1200	165	344	1	11	11
1201	165	333	1	8	8
2124	272	58	1	13	13
2125	272	51	1	8	8
808	122	1	1	2	2
809	122	3	4	3	12
810	122	129	1	9	9
811	122	63	1	9	9
812	122	116	1	8	8
813	122	73	1	8	8
2126	272	52	1	8	8
941	138	1	1	2	2
942	138	6	6	3	18
943	138	64	1	13	13
944	138	51	1	8	8
945	138	58	2	13	26
2127	272	335	1	5	5
2128	272	114	1	10	10
28338	1516	1	1	2	2
17424	1602	58	1	13	13
17425	1602	113	1	25	25
10257	1017	5	14	3	42
10258	1017	51	1	8	8
10259	1017	52	1	8	8
20354	1847	1	1	2	2
20355	1847	33	1	11	11
20356	1847	58	3	13	39
20357	1847	31	2	9	18
20358	1847	43	2	12	24
24015	419	41	1	15	15
24016	419	51	1	8	8
24017	419	57	1	9	9
965	141	1	1	2	2
966	141	5	5	3	15
967	141	114	1	10	10
968	141	116	1	8	8
969	141	34	1	8	8
970	141	150	1	11	11
971	141	339	1	9	9
24018	419	104	1	13	13
24019	419	120	1	18	18
855	125	48	1	10	10
856	114	1	1	2	2
857	114	6	3	3	9
858	114	3	2	3	6
16358	1526	3	9	3	27
16359	1526	26	1	14	14
16360	1526	106	2	14	28
864	128	1	1	2	2
865	128	6	5	3	15
866	128	107	1	14	14
16361	1526	165	1	8	8
992	143	5	1	3	3
993	143	53	1	9	9
994	139	1	1	2	2
995	139	5	2	3	6
996	139	4	2	3	6
1049	149	1	1	2	2
1050	149	3	10	3	30
1051	149	65	1	8	8
1052	149	36	1	8	8
1053	149	165	1	8	8
1054	149	58	1	13	13
1085	153	1	1	2	2
1086	153	5	6	3	18
1087	153	44	1	8	8
1088	153	52	1	8	8
1089	153	74	1	8	8
1090	153	114	1	10	10
1091	153	58	1	13	13
1123	135	5	4	3	12
1124	135	129	1	9	9
1125	135	96	1	8	8
1128	155	2	1	2	2
1129	155	5	5	3	15
1146	160	1	1	2	2
1147	160	5	8	3	24
1148	160	96	1	8	8
1149	160	52	1	8	8
1150	160	344	1	11	11
1151	159	5	10	3	30
1175	164	136	1	8	8
1176	164	5	4	3	12
1177	164	3	3	3	9
1178	164	342	1	9	9
1179	161	1	1	2	2
1180	161	5	10	3	30
1181	161	64	1	13	13
1182	161	58	1	13	13
1183	161	344	1	11	11
1184	161	101	2	3	6
2129	272	116	1	8	8
2130	272	56	1	12	12
1621	224	1	1	2	2
1622	224	5	1	3	3
1623	224	52	1	8	8
1624	224	150	1	11	11
1625	224	319	1	14	14
2201	278	40	2	19	38
2202	278	1	1	2	2
2203	278	6	8	3	24
2204	278	31	2	9	18
2205	278	58	2	13	26
1655	228	1	1	2	2
1656	228	6	10	3	30
1657	228	149	1	13	13
1658	228	145	1	8	8
1659	228	61	1	8	8
1664	229	1	1	2	2
1665	229	138	5	8	40
1666	229	137	2	8	16
1667	229	3	2	3	6
2206	278	57	1	9	9
2207	278	51	2	8	16
24020	419	145	1	8	8
24021	419	100	1	17	17
2208	278	151	1	17	17
2209	278	116	1	8	8
2210	278	63	1	9	9
2211	278	26	2	14	28
2219	279	1	1	2	2
2220	279	5	4	3	12
20359	1847	8	4	6	24
3514	390	5	4	3	12
3515	390	63	1	9	9
3516	390	43	1	12	12
3525	392	316	1	20	20
6745	699	1	1	2	2
6746	699	104	1	13	13
6747	699	149	2	13	26
6748	699	150	1	11	11
10260	1017	62	1	9	9
6759	703	1	1	2	2
6760	703	5	20	3	60
6761	703	77	1	18	18
6802	708	134	1	129	129
6803	708	278	1	18	18
6804	708	291	1	30	30
1750	236	1	1	2	2
1751	236	5	10	3	30
1752	236	114	2	10	20
1753	236	43	1	12	12
1754	236	46	2	6	12
1755	236	71	1	8	8
1756	236	20	1	8	8
6810	710	131	1	22	22
6811	710	132	1	17	17
6812	710	314	2	30	60
28339	1516	5	7	3	21
28340	1516	96	2	8	16
10261	1017	63	1	9	9
10262	1017	34	2	8	16
1797	241	3	4	3	12
1798	241	1	1	2	2
1799	241	58	1	13	13
1800	241	335	2	5	10
1801	241	43	1	12	12
1802	241	114	1	10	10
1803	241	26	1	14	14
10263	1017	116	1	8	8
20360	1847	335	1	5	5
20361	1847	51	1	8	8
20362	1847	109	1	14	14
20363	1847	339	1	9	9
20364	1847	40	1	19	19
20365	1847	63	1	9	9
1880	248	1	1	2	2
1881	248	3	8	3	24
1882	248	6	6	3	18
1893	250	1	1	2	2
1894	250	40	1	19	19
1895	250	96	2	8	16
1896	250	41	1	15	15
1897	250	36	1	8	8
1898	250	120	1	18	18
1899	250	19	1	15	15
1906	251	307	5	24	120
1910	252	1	1	2	2
1911	252	6	15	3	45
1912	252	149	2	13	26
1922	253	1	1	2	2
1923	253	6	2	3	6
1924	253	57	2	9	18
1925	253	8	1	6	6
1926	253	172	2	13	26
1927	253	26	1	14	14
1928	253	63	1	9	9
1929	253	34	1	8	8
1930	253	56	1	12	12
1939	254	1	1	2	2
1940	254	44	1	8	8
1941	254	114	2	10	20
1942	254	57	1	9	9
1943	254	62	1	9	9
1944	254	51	1	8	8
1945	254	56	1	12	12
1946	254	145	1	8	8
1962	257	1	1	2	2
1963	257	6	12	3	36
1964	257	57	1	9	9
1965	257	63	1	9	9
1966	257	20	1	8	8
1967	257	116	1	8	8
1968	257	131	1	22	22
2000	262	3	30	3	90
2013	264	1	2	2	4
2014	264	40	1	19	19
2015	264	52	2	8	16
2016	264	8	7	6	42
2017	264	7	7	6	42
2018	264	322	3	25	75
2019	264	25	1	14	14
2020	264	106	1	14	14
2021	264	313	2	16	32
2033	265	51	2	8	16
2034	265	114	1	10	10
2035	265	57	1	9	9
2036	265	1	1	2	2
2037	265	3	10	3	30
2038	265	165	1	8	8
2039	265	110	1	9	9
2040	265	116	1	8	8
10266	1018	96	1	8	8
10267	1018	116	2	8	16
10275	1019	1	1	2	2
10276	1019	6	2	3	6
5470	559	1	1	2	2
5471	559	3	5	3	15
5472	559	5	7	3	21
2133	273	1	1	2	2
2134	273	6	4	3	12
5473	559	6	3	3	9
5474	559	120	2	18	36
5475	559	104	1	13	13
5476	559	321	1	3	3
20366	1847	342	1	9	9
20367	1847	36	1	8	8
20413	1852	3	4	3	12
24022	419	132	1	17	17
24025	1778	6	15	3	45
28341	1516	34	1	8	8
28342	1516	24	1	8	8
28343	1516	62	2	9	18
28376	2453	3	15	3	45
28377	2453	1	1	2	2
28378	2453	335	3	5	15
28379	2453	114	1	10	10
28380	2453	52	2	8	16
28381	2453	57	1	9	9
28382	2453	43	1	12	12
1332	166	1	1	2	2
1333	166	341	2	9	18
1334	166	27	1	8	8
1335	166	142	1	9	9
1336	170	1	1	2	2
1337	170	5	5	3	15
1338	170	341	1	9	9
1339	170	70	2	8	16
1340	170	39	1	8	8
1341	171	1	1	2	2
1342	171	24	1	8	8
1343	171	20	1	8	8
1344	171	56	1	12	12
1345	171	74	1	8	8
1346	191	56	1	12	12
1347	191	278	2	18	36
1354	175	5	6	3	18
1355	175	264	1	10	10
1358	178	5	2	3	6
1359	178	48	1	10	10
1360	179	36	2	8	16
1361	179	142	1	9	9
1362	179	1	1	2	2
1363	180	1	1	2	2
1364	180	5	2	3	6
1365	180	3	3	3	9
1366	181	142	2	9	18
1367	181	341	1	9	9
1368	181	61	3	8	24
1369	181	120	1	18	18
1371	182	1	1	2	2
1372	182	5	6	3	18
1373	182	4	13	3	39
1374	183	5	10	3	30
1375	184	1	1	2	2
1376	184	5	4	3	12
1377	187	1	1	2	2
1378	187	3	12	3	36
1379	185	58	1	13	13
1384	188	1	1	2	2
1385	188	5	4	3	12
1386	188	20	1	8	8
1387	188	64	1	13	13
1388	188	56	1	12	12
1389	188	145	1	8	8
1390	189	1	1	2	2
1391	189	5	6	3	18
1399	196	1	1	2	2
1400	196	9	2	12	24
1401	196	7	1	6	6
1402	196	37	1	8	8
1403	196	52	3	8	24
1404	197	303	2	13	26
1405	193	3	10	3	30
1406	193	41	1	15	15
1407	193	39	1	8	8
1408	194	1	1	2	2
1409	194	3	10	3	30
1410	190	9	1	12	12
1411	190	7	1	6	6
1412	190	1	1	2	2
1413	190	6	1	3	3
1414	190	16	1	20	20
1426	195	1	1	2	2
1427	195	51	2	8	16
1428	195	138	1	8	8
1429	195	120	1	18	18
1430	195	32	1	8	8
1431	195	96	1	8	8
1432	195	110	1	9	9
1433	195	213	1	8	8
1434	195	129	1	9	9
1435	195	57	1	9	9
1453	198	63	2	9	18
1454	198	62	2	9	18
1455	198	59	1	9	9
1456	200	1	1	2	2
1457	200	35	1	17	17
1458	200	64	1	13	13
1459	200	99	1	12	12
1460	200	32	1	8	8
1461	200	96	1	8	8
1462	200	20	1	8	8
1463	200	339	1	9	9
1467	201	1	1	2	2
1468	201	57	2	9	18
1469	201	56	1	12	12
1475	202	6	2	3	6
1476	202	4	3	3	9
1477	202	172	1	13	13
1478	202	96	1	8	8
1479	202	1	1	2	2
1484	203	5	1	3	3
1485	203	6	1	3	3
1486	203	1	1	2	2
1487	203	2	1	2	2
1493	204	307	7	24	168
1494	204	311	1	30	30
1495	204	303	1	13	13
1496	204	76	1	36	36
1497	204	119	1	31	31
1628	225	2	1	2	2
1629	225	5	16	3	48
1500	205	303	2	13	26
1501	205	311	4	30	120
1634	60	3	5	3	15
1635	60	51	2	8	16
1504	206	307	4	24	96
1505	206	303	3	13	39
1636	60	1	1	2	2
1637	60	91	1	8	8
1509	207	282	1	34	34
1510	207	303	1	13	13
1511	207	311	1	30	30
2789	333	135	1	99	99
2804	335	1	1	2	2
2805	335	5	14	3	42
2806	335	108	1	8	8
2807	335	132	1	17	17
3484	389	286	1	50	50
1520	208	1	1	2	2
1521	208	5	10	3	30
1522	211	305	1	9	9
1523	211	309	1	11	11
1524	211	308	1	6	6
1525	211	304	1	5	5
1526	211	303	1	13	13
1527	211	307	1	24	24
6721	696	145	1	8	8
6722	696	56	1	12	12
12886	1250	34	2	8	16
12887	1250	1	1	2	2
8348	863	2	1	2	2
8349	863	40	2	19	38
1534	212	303	1	13	13
1535	212	307	1	24	24
6727	697	1	1	2	2
1537	214	292	2	50	100
12888	1250	43	1	12	12
12889	1250	58	2	13	26
6728	697	5	3	3	9
6729	697	61	1	8	8
12890	1250	51	3	8	24
1545	215	311	4	30	120
1546	215	292	1	50	50
1547	215	315	1	65	65
12891	1250	116	2	8	16
17460	1604	1	1	2	2
17461	1604	62	2	9	18
17462	1604	52	1	8	8
17463	1604	165	1	8	8
17464	1604	116	1	8	8
1555	218	2	1	2	2
1556	218	5	3	3	9
1557	218	3	8	3	24
1558	218	58	1	13	13
17465	1604	151	1	17	17
17466	1604	271	1	24	24
17467	1604	192	1	30	30
1698	232	57	1	9	9
1699	232	43	1	12	12
1700	232	172	4	13	52
1701	232	96	1	8	8
1575	219	2	1	2	2
1576	219	129	1	9	9
1577	219	32	1	8	8
1578	219	36	2	8	16
1579	219	114	1	10	10
1580	219	20	1	8	8
1581	219	71	1	8	8
1582	219	334	1	8	8
1583	219	95	1	8	8
1584	219	75	1	12	12
1585	219	145	1	8	8
1586	219	24	1	8	8
1587	219	303	1	13	13
1588	220	1	1	2	2
1589	220	5	5	3	15
1590	220	4	15	3	45
1591	220	46	1	6	6
1702	232	334	1	8	8
1703	232	114	1	10	10
1704	232	116	1	8	8
1595	221	1	1	2	2
1596	221	6	2	3	6
1597	221	3	2	3	6
1705	232	151	1	17	17
1706	232	63	2	9	18
1707	232	62	1	9	9
1708	232	106	3	14	42
1709	232	52	3	8	24
1603	222	8	2	6	12
1604	222	1	1	2	2
1605	222	63	5	9	45
1606	222	46	1	6	6
1607	222	172	2	13	26
1710	232	24	1	8	8
1811	240	1	1	2	2
1812	240	6	11	3	33
1813	242	57	1	9	9
1814	242	30	2	8	16
1833	217	303	2	13	26
1883	249	1	1	2	2
1884	249	5	3	3	9
1885	249	3	4	3	12
1959	255	5	2	3	6
1960	255	51	1	8	8
1961	255	62	1	9	9
1973	258	3	3	3	9
1974	258	52	1	8	8
1975	258	57	2	9	18
1976	258	32	1	8	8
1985	259	1	1	2	2
1986	259	3	6	3	18
1987	259	5	4	3	12
1988	259	149	2	13	26
1989	259	165	1	8	8
1990	259	27	1	8	8
1991	259	40	1	19	19
1992	260	303	2	13	26
2734	329	135	2	99	198
2142	274	135	1	99	99
2149	261	1	2	2	4
2150	261	8	6	6	36
2151	261	7	5	6	30
2152	261	52	2	8	16
2153	261	322	1	25	25
2154	261	40	1	19	19
3485	389	297	1	3	3
3486	389	1	1	2	2
3487	389	7	4	6	24
3488	389	35	1	17	17
3489	389	129	2	9	18
2101	271	1	1	2	2
2102	271	3	4	3	12
2103	271	6	4	3	12
2104	271	165	2	8	16
2105	271	114	2	10	20
2106	271	58	2	13	26
2107	271	62	3	9	27
2108	271	46	4	6	24
3490	389	20	1	8	8
3491	389	52	1	8	8
3492	389	46	2	6	12
3493	389	151	1	17	17
2744	330	1	1	2	2
2745	330	5	2	3	6
2746	330	3	3	3	9
2747	330	163	1	8	8
2748	330	105	1	13	13
6730	697	150	1	11	11
8350	863	5	4	3	12
12427	1212	311	2	30	60
2161	276	1	1	2	2
2162	276	3	3	3	9
2163	276	20	1	8	8
2164	276	24	1	8	8
2165	276	322	1	25	25
2166	276	100	1	17	17
12428	1212	307	4	24	96
24026	1778	149	1	13	13
28387	2119	113	1	25	25
28388	2119	76	1	36	36
28389	2119	132	2	17	34
5716	583	51	1	8	8
5717	583	52	1	8	8
5718	583	31	1	9	9
2189	277	1	1	2	2
2190	277	8	2	6	12
2191	277	4	2	3	6
2192	277	335	2	5	10
2193	277	43	1	12	12
2194	277	114	1	10	10
2195	277	116	1	8	8
2196	277	27	1	8	8
2197	277	58	1	13	13
2198	277	172	1	13	13
2199	277	52	1	8	8
2200	277	311	1	30	30
5719	583	32	1	8	8
2221	279	3	2	3	6
2222	279	57	2	9	18
2223	279	46	1	6	6
2224	279	96	1	8	8
2225	279	39	2	8	16
2327	299	1	1	2	2
2328	299	6	2	3	6
2329	299	3	6	3	18
2330	299	57	4	9	36
2331	299	51	1	8	8
2332	299	52	1	8	8
2333	299	116	2	8	16
2334	299	123	1	18	18
2335	299	33	1	11	11
2360	301	1	1	2	2
2361	301	3	4	3	12
2362	301	5	3	3	9
2363	301	32	1	8	8
2364	301	96	1	8	8
2365	301	114	2	10	20
2366	301	57	3	9	27
2367	301	46	1	6	6
2368	301	34	1	8	8
2369	301	52	1	8	8
2395	304	1	1	2	2
2396	304	32	1	8	8
2397	304	58	2	13	26
2398	304	114	2	10	20
2399	304	62	1	9	9
2400	304	96	2	8	16
2401	304	150	2	11	22
2402	304	69	2	9	18
2403	304	335	2	5	10
2460	310	2	1	2	2
2461	310	3	8	3	24
2462	310	57	2	9	18
2465	311	2	1	2	2
2466	311	5	15	3	45
2490	314	5	5	3	15
2491	314	4	2	3	6
2492	314	113	1	25	25
2495	292	1	1	2	2
2496	292	5	5	3	15
2508	295	3	2	3	6
2509	295	5	4	3	12
2510	295	51	2	8	16
2511	295	104	4	13	52
2512	295	105	2	13	26
2518	285	1	1	2	2
2519	285	5	9	3	27
2520	287	1	1	2	2
2521	287	5	5	3	15
2522	287	4	1	3	3
2523	287	335	3	5	15
2529	303	3	6	3	18
2530	303	58	3	13	39
2531	303	51	1	8	8
2532	286	1	1	2	2
2569	319	1	1	2	2
2570	319	8	4	6	24
2571	319	7	4	6	24
2572	319	9	1	12	12
2573	319	59	1	9	9
2574	319	143	1	9	9
2575	288	4	6	3	18
2595	284	38	1	8	8
2596	284	41	1	15	15
2597	284	339	2	9	18
2598	284	37	1	8	8
2063	268	2	1	2	2
2064	268	3	2	3	6
2065	268	165	1	8	8
2066	268	27	1	8	8
2067	268	58	1	13	13
2068	268	114	1	10	10
2069	268	63	1	9	9
2070	268	35	1	17	17
20384	1850	3	7	3	21
20385	1850	1	1	2	2
2085	270	1	1	2	2
2086	270	6	6	3	18
2087	270	149	1	13	13
2088	270	32	1	8	8
2089	270	57	2	9	18
2090	270	27	1	8	8
2091	270	99	1	12	12
2092	270	63	1	9	9
2749	330	30	1	8	8
2750	330	95	1	8	8
2751	330	26	1	14	14
2752	330	63	1	9	9
8351	863	3	1	3	3
8352	863	58	2	13	26
8353	863	149	2	13	26
4407	459	1	1	2	2
4408	459	57	2	9	18
4409	459	114	1	10	10
4410	459	52	1	8	8
2228	280	1	1	2	2
2229	280	6	9	3	27
2248	282	1	1	2	2
2249	282	4	18	3	54
4411	459	335	2	5	10
2833	66	1	1	2	2
2834	66	6	11	3	33
2835	66	311	1	30	30
4412	459	32	1	8	8
4413	459	27	1	8	8
4414	459	62	1	9	9
4415	459	96	1	8	8
4416	459	56	1	12	12
2856	338	1	1	2	2
2857	338	6	6	3	18
2858	338	335	6	5	30
2865	340	131	1	22	22
2866	340	25	1	14	14
2867	340	149	1	13	13
28414	2455	2	1	2	2
28415	2455	5	3	3	9
28416	2455	57	1	9	9
28417	2455	334	1	8	8
28418	2455	63	1	9	9
28419	2455	20	1	8	8
28420	2455	318	1	12	12
2343	300	1	1	2	2
2344	300	4	2	3	6
2345	300	35	1	17	17
2346	300	9	1	12	12
2347	300	148	1	17	17
2348	300	58	1	13	13
2349	300	145	1	8	8
2404	305	6	1	3	3
2405	305	5	15	3	45
2426	307	1	1	2	2
2427	307	3	3	3	9
2428	307	5	2	3	6
2429	307	6	2	3	6
2430	307	118	1	8	8
2431	307	149	2	13	26
2432	307	32	3	8	24
2433	307	335	1	5	5
2434	307	116	1	8	8
2443	308	1	1	2	2
2444	308	40	1	19	19
2445	308	6	2	3	6
2446	308	27	1	8	8
2447	308	56	2	12	24
2448	308	99	1	12	12
2452	309	1	1	2	2
2453	309	5	2	3	6
2454	309	110	1	9	9
2455	309	63	1	9	9
2456	309	322	1	25	25
2457	309	148	1	17	17
2458	309	131	1	22	22
2459	309	159	1	17	17
2493	290	2	1	2	2
2494	290	5	12	3	36
2497	294	2	1	2	2
2498	294	5	5	3	15
2499	294	138	1	8	8
2500	294	51	1	8	8
2501	294	120	1	18	18
2502	294	266	1	36	36
2505	297	5	3	3	9
2506	297	172	1	13	13
2507	297	33	1	11	11
2533	286	5	6	3	18
2534	286	32	1	8	8
2535	286	58	2	13	26
2536	286	341	1	9	9
2537	286	96	1	8	8
2538	286	339	1	9	9
2539	286	334	1	8	8
2540	286	259	6	3	18
2541	286	274	1	15	15
2546	317	1	1	2	2
2547	317	3	2	3	6
2548	317	58	2	13	26
2549	317	46	3	6	18
2550	316	3	2	3	6
2551	316	7	5	6	30
2552	316	58	1	13	13
2553	316	157	1	17	17
2554	316	151	1	17	17
4417	459	145	1	8	8
5495	562	5	2	3	6
17439	1364	1	1	2	2
17440	1364	33	1	11	11
2580	256	25	1	14	14
2581	256	149	1	13	13
2582	293	2	1	2	2
2583	293	5	8	3	24
2584	293	62	1	9	9
2585	293	63	1	9	9
2586	293	145	1	8	8
17441	1364	114	1	10	10
17442	1364	149	1	13	13
20382	1848	165	1	8	8
20383	1848	1	1	2	2
5517	566	1	1	2	2
5518	566	213	1	8	8
28383	2453	20	1	8	8
2609	312	1	1	2	2
2610	312	5	1	3	3
2611	312	3	20	3	60
2612	312	282	1	34	34
28384	2453	150	2	11	22
28385	2453	63	2	9	18
4442	461	1	1	2	2
4443	461	6	5	3	15
4444	461	57	2	9	18
4445	461	41	2	15	30
4446	461	114	1	10	10
4447	461	31	3	9	27
4448	461	129	1	9	9
4449	461	149	1	13	13
4467	463	4	2	3	6
4468	463	32	1	8	8
4469	463	58	1	13	13
4470	463	114	1	10	10
4471	463	52	1	8	8
28386	2453	266	1	36	36
2859	339	1	1	2	2
2860	339	5	3	3	9
2861	339	32	1	8	8
2862	339	96	2	8	16
2863	339	116	1	8	8
2864	339	106	1	14	14
2898	342	40	1	19	19
2899	342	30	1	8	8
2900	342	157	1	17	17
2901	342	129	1	9	9
2902	342	104	1	13	13
2938	347	95	1	8	8
2939	347	110	1	9	9
2940	347	57	1	9	9
2941	347	104	1	13	13
2942	347	116	1	8	8
2943	347	51	1	8	8
2944	347	43	1	12	12
2945	348	1	1	2	2
2946	348	6	7	3	21
2958	350	1	1	2	2
2959	350	3	18	3	54
2960	350	96	1	8	8
2961	350	30	1	8	8
2962	350	105	1	13	13
2963	350	148	1	17	17
2964	350	159	1	17	17
2991	351	1	1	2	2
2992	351	131	1	22	22
2993	351	56	2	12	24
2994	351	100	1	17	17
2995	351	64	1	13	13
2996	351	5	8	3	24
2997	351	7	6	6	36
2998	351	51	1	8	8
2999	351	52	1	8	8
3000	351	116	1	8	8
3001	351	63	1	9	9
3002	351	150	1	11	11
3003	351	303	1	13	13
3008	352	1	1	2	2
3009	352	3	3	3	9
3010	352	32	1	8	8
3011	352	57	1	9	9
3012	352	51	1	8	8
3013	352	56	1	12	12
3014	353	1	1	2	2
3015	353	5	7	3	21
3016	353	32	1	8	8
3017	353	323	1	20	20
3018	353	25	2	14	28
3019	353	26	2	14	28
3020	353	36	1	8	8
3021	355	1	1	2	2
3022	355	3	12	3	36
3028	356	1	1	2	2
3029	356	149	4	13	52
3030	356	295	1	85	85
3040	357	1	1	2	2
3041	357	52	1	8	8
3042	357	57	1	9	9
3043	357	213	1	8	8
3044	357	20	2	8	16
3045	357	56	1	12	12
3046	357	63	1	9	9
3047	357	109	1	14	14
3048	357	340	1	15	15
3143	363	1	1	2	2
3144	363	5	5	3	15
3145	363	114	1	10	10
28390	2119	315	1	65	65
28391	2119	1	1	2	2
2772	331	1	1	2	2
2773	331	5	3	3	9
2774	331	6	1	3	3
2775	331	32	2	8	16
2576	289	5	2	3	6
2577	289	335	3	5	15
2578	289	342	1	9	9
2579	289	261	1	8	8
2590	298	1	1	2	2
2591	298	40	1	19	19
2592	298	63	1	9	9
2593	298	5	1	3	3
2594	298	110	1	9	9
2622	320	1	1	2	2
2623	320	26	12	14	168
2624	320	58	7	13	91
2776	331	36	2	8	16
2777	331	165	2	8	16
2778	331	322	3	25	75
2779	331	46	2	6	12
2780	331	105	1	13	13
2781	331	56	1	12	12
2782	331	58	1	13	13
2783	331	104	1	13	13
2633	321	1	1	2	2
2634	321	57	2	9	18
2635	321	63	1	9	9
2636	321	62	1	9	9
2637	321	334	1	8	8
2638	321	335	1	5	5
2639	321	150	1	11	11
2640	321	116	1	8	8
2641	321	320	1	14	14
2784	331	130	1	12	12
2643	322	1	1	2	2
2644	322	62	1	9	9
2645	322	96	2	8	16
2646	322	27	1	8	8
2647	322	20	1	8	8
2648	322	52	1	8	8
2649	322	334	1	8	8
2650	322	100	1	17	17
2651	323	132	1	17	17
2652	323	347	1	13	13
2785	331	52	1	8	8
2786	331	213	1	8	8
2787	331	19	1	15	15
2788	331	328	1	15	15
12429	1212	303	1	13	13
17443	1364	51	1	8	8
17444	1364	56	1	12	12
17445	1364	191	1	30	30
17446	1364	326	1	13	13
12430	1212	1	1	2	2
12431	1212	51	6	8	48
4456	462	1	1	2	2
3551	393	1	1	2	2
3552	393	5	6	3	18
2822	336	1	1	2	2
2823	336	6	4	3	12
2824	336	3	12	3	36
2673	325	1	1	2	2
2674	325	5	9	3	27
2675	325	335	3	5	15
2676	325	57	2	9	18
2677	325	52	1	8	8
2678	325	150	1	11	11
2679	325	46	2	6	12
2680	325	27	1	8	8
2825	336	57	1	9	9
2826	336	32	1	8	8
2827	336	114	1	10	10
2828	336	319	1	14	14
2829	336	315	1	65	65
2839	337	56	1	12	12
2840	337	96	2	8	16
2841	337	116	3	8	24
2842	337	43	1	12	12
2843	337	282	1	34	34
2844	337	285	1	15	15
3553	393	43	1	12	12
2693	326	1	1	2	2
2694	326	5	10	3	30
2695	326	56	2	12	24
4457	462	5	5	3	15
4458	462	6	5	3	15
12432	1212	52	6	8	48
4459	462	20	1	8	8
4460	462	56	1	12	12
4461	462	149	1	13	13
24107	2151	1	1	2	2
24108	2151	3	6	3	18
24109	2151	91	1	8	8
24110	2151	172	1	13	13
24111	2151	114	1	10	10
24112	2151	130	1	12	12
24113	2151	113	1	25	25
2880	341	1	1	2	2
2881	341	3	8	3	24
2890	343	1	1	2	2
2891	343	6	4	3	12
2892	343	104	1	13	13
2893	343	157	2	17	34
2894	343	110	1	9	9
2895	343	52	1	8	8
2896	343	56	1	12	12
2897	343	277	1	140	140
24114	2151	314	1	30	30
2918	345	1	1	2	2
2919	345	3	9	3	27
2932	347	1	1	2	2
2933	347	5	4	3	12
2934	347	44	1	8	8
2935	347	6	6	3	18
2936	347	8	5	6	30
2937	347	120	1	18	18
28421	2455	311	3	30	90
3098	360	1	1	2	2
3099	360	6	3	3	9
3100	360	57	2	9	18
3101	360	30	1	8	8
3102	360	105	1	13	13
3103	360	51	1	8	8
3104	360	116	1	8	8
3105	360	149	2	13	26
3106	360	64	1	13	13
3115	361	1	1	2	2
3116	361	3	6	3	18
3117	361	165	1	8	8
3118	361	129	1	9	9
3119	361	32	1	8	8
3120	361	31	1	9	9
3121	361	157	1	17	17
3122	361	130	1	12	12
3129	362	1	1	2	2
3130	362	6	3	3	9
3131	362	96	1	8	8
3132	362	31	1	9	9
3133	362	145	2	8	16
3134	362	63	1	9	9
3526	392	44	2	8	16
3527	392	165	5	8	40
3528	392	51	4	8	32
3529	392	52	2	8	16
3530	392	110	2	9	18
3531	392	62	2	9	18
3532	392	63	3	9	27
3533	392	334	2	8	16
3534	392	57	3	9	27
3535	392	114	1	10	10
3536	392	31	1	9	9
3537	392	342	1	9	9
3538	392	339	2	9	18
3539	392	30	1	8	8
3540	392	143	2	9	18
3541	392	36	2	8	16
3542	392	307	1	24	24
3543	392	303	1	13	13
3544	392	311	1	30	30
28431	2457	1	1	2	2
28432	2457	5	6	3	18
28433	2457	64	3	13	39
28434	2457	63	1	9	9
28435	2457	106	1	14	14
28436	2457	114	1	10	10
3559	394	2	1	2	2
3560	394	5	5	3	15
3561	395	43	1	12	12
3562	395	149	1	13	13
3563	395	74	1	8	8
3564	395	2	1	2	2
28437	2457	20	1	8	8
28438	2457	99	1	12	12
28439	2457	28	1	12	12
5731	585	5	5	3	15
3621	399	1	1	2	2
3622	399	5	2	3	6
3623	399	26	1	14	14
3624	399	342	2	9	18
3625	399	149	1	13	13
3626	399	52	2	8	16
3627	399	100	1	17	17
3628	400	1	1	2	2
3629	400	6	12	3	36
3630	400	274	1	15	15
3728	408	32	2	8	16
3729	408	44	1	8	8
3730	408	57	3	9	27
3731	408	43	1	12	12
3732	408	20	2	8	16
3733	408	114	3	10	30
3734	408	322	1	25	25
3735	408	110	1	9	9
3736	408	323	1	20	20
3737	408	34	1	8	8
3738	408	63	2	9	18
3739	408	51	2	8	16
3740	408	52	2	8	16
3741	408	41	1	15	15
3742	408	40	2	19	38
3743	408	1	2	2	4
3744	408	5	2	3	6
3745	408	62	1	9	9
3746	409	1	1	2	2
3747	409	57	1	9	9
3748	409	62	1	9	9
3749	409	64	1	13	13
3750	409	51	1	8	8
3751	409	52	1	8	8
3752	409	104	1	13	13
3753	409	105	1	13	13
3754	409	157	1	17	17
3776	411	1	1	2	2
3777	411	7	2	6	12
3778	411	8	1	6	6
3779	411	63	1	9	9
3780	411	43	1	12	12
3781	411	51	1	8	8
3782	411	57	1	9	9
3783	411	110	1	9	9
3784	411	31	1	9	9
3793	412	1	1	2	2
3794	412	3	3	3	9
3795	412	114	2	10	20
3796	412	322	1	25	25
3797	412	73	1	8	8
3798	412	51	1	8	8
3799	412	339	2	9	18
3800	412	150	1	11	11
3816	413	1	1	2	2
3817	413	62	2	9	18
3818	413	51	1	8	8
3819	413	20	1	8	8
3820	413	151	1	17	17
3821	413	76	1	36	36
3822	413	271	1	24	24
3823	413	190	1	30	30
3848	415	1	1	2	2
3849	415	43	1	12	12
3850	415	57	1	9	9
3851	415	108	2	8	16
3852	415	74	1	8	8
3146	363	96	1	8	8
3147	363	51	1	8	8
3148	363	63	1	9	9
3149	363	32	1	8	8
3150	363	132	1	17	17
3554	393	59	1	9	9
3555	393	20	1	8	8
3556	393	64	2	13	26
3557	393	56	1	12	12
3558	393	151	2	17	34
5519	566	52	2	8	16
24051	1290	1	1	2	2
24052	1290	3	2	3	6
24053	1290	8	4	6	24
24054	1290	172	1	13	13
24055	1290	96	1	8	8
24056	1290	58	1	13	13
24057	1290	319	1	14	14
24058	1290	153	1	17	17
24059	1290	26	1	14	14
24060	1290	145	1	8	8
5520	566	5	6	3	18
5521	566	334	1	8	8
5522	566	335	1	5	5
8354	863	63	1	9	9
8355	863	46	3	6	18
8356	863	339	2	9	18
8357	863	57	1	9	9
3573	396	2	1	2	2
3574	396	58	1	13	13
3575	396	149	2	13	26
3576	396	33	1	11	11
3577	396	52	1	8	8
3578	396	56	1	12	12
3579	396	63	1	9	9
3580	396	100	2	17	34
8358	863	151	1	17	17
10277	1019	142	1	9	9
10278	1019	57	1	9	9
10279	1019	110	1	9	9
12436	775	4	1	3	3
12437	775	106	1	14	14
12438	775	56	1	12	12
12439	775	159	1	17	17
14897	1418	1	1	2	2
14898	1418	5	3	3	9
14899	1418	44	1	8	8
28442	2456	1	1	2	2
28443	2456	3	4	3	12
28444	2456	57	1	9	9
28445	2456	32	1	8	8
28446	2456	96	1	8	8
28447	2456	31	2	9	18
28448	2456	52	1	8	8
28449	2456	342	2	9	18
28450	2456	20	1	8	8
28460	838	1	1	2	2
28461	838	6	3	3	9
17517	1608	1	1	2	2
17518	1608	63	2	9	18
17519	1608	62	1	9	9
17520	1608	56	1	12	12
17521	1608	129	1	9	9
17522	1608	192	1	30	30
17523	1609	2	1	2	2
17524	1609	44	1	8	8
3770	410	1	1	2	2
3771	410	35	1	17	17
3772	410	138	1	8	8
3773	410	27	2	8	16
3774	410	339	1	9	9
3775	410	52	1	8	8
17525	1609	30	1	8	8
17526	1609	36	1	8	8
28462	838	32	1	8	8
3824	358	1	1	2	2
3825	358	5	2	3	6
3826	358	6	3	3	9
3827	358	27	5	8	40
3828	358	36	1	8	8
3829	358	96	1	8	8
3830	358	150	1	11	11
3906	420	1	1	2	2
3907	420	335	2	5	10
3908	420	116	2	8	16
3909	420	110	1	9	9
3910	420	334	1	8	8
3911	420	52	1	8	8
3912	420	57	1	9	9
3913	420	58	1	13	13
3914	420	96	1	8	8
3915	420	62	1	9	9
3916	420	46	4	6	24
3937	423	1	1	2	2
3938	423	6	7	3	21
3939	423	151	1	17	17
3940	423	113	1	25	25
3964	426	1	1	2	2
3965	426	5	2	3	6
3966	426	3	3	3	9
3969	283	2	1	2	2
3970	283	46	10	6	60
4041	429	1	1	2	2
4042	429	46	1	6	6
4043	429	96	2	8	16
4044	429	31	1	9	9
4045	429	41	1	15	15
4046	429	52	1	8	8
4047	429	20	1	8	8
4048	429	150	1	11	11
4070	226	20	1	8	8
4074	430	1	1	2	2
4075	430	31	2	9	18
4076	430	96	1	8	8
4077	430	63	1	9	9
4078	430	334	1	8	8
4079	430	116	1	8	8
4080	430	100	1	17	17
4081	430	34	1	8	8
4082	431	1	1	2	2
4083	431	40	2	19	38
4084	431	149	2	13	26
3598	398	1	1	2	2
3599	398	6	3	3	9
3600	398	33	2	11	22
12440	734	1	1	2	2
12441	734	129	2	9	18
12442	734	43	1	12	12
12443	734	172	2	13	26
12444	734	341	2	9	18
12445	734	105	2	13	26
4555	471	1	1	2	2
4556	471	6	2	3	6
4557	471	3	1	3	3
4558	471	51	1	8	8
4559	471	57	1	9	9
4560	471	64	1	13	13
4561	471	114	1	10	10
24070	2149	52	2	8	16
24071	2149	61	1	8	8
24072	2150	1	1	2	2
24073	2150	6	5	3	15
24074	2150	35	2	17	34
24075	2150	149	1	13	13
24076	2150	51	1	8	8
24077	2150	59	1	9	9
24078	2150	132	1	17	17
28532	2464	1	1	2	2
3223	370	1	1	2	2
3224	370	5	2	3	6
3225	370	30	2	8	16
3226	370	46	1	6	6
3227	370	56	2	12	24
28533	2464	6	4	3	12
24097	843	1	1	2	2
24098	843	3	5	3	15
24099	843	43	1	12	12
24100	843	106	1	14	14
24101	843	333	1	8	8
24102	843	118	1	8	8
24103	843	114	1	10	10
24104	843	25	1	14	14
28534	2464	57	2	9	18
3240	371	1	1	2	2
3241	371	36	1	8	8
3242	371	51	1	8	8
3243	371	52	1	8	8
3244	371	63	1	9	9
3245	371	143	1	9	9
3246	372	282	1	34	34
3247	373	1	1	2	2
3248	373	3	9	3	27
3249	373	335	5	5	25
3255	374	1	1	2	2
3256	374	3	3	3	9
3257	374	5	1	3	3
3258	374	6	4	3	12
3259	374	190	1	30	30
3269	334	37	1	8	8
3270	334	38	1	8	8
3271	334	39	1	8	8
3285	375	1	1	2	2
3286	375	120	1	18	18
3287	375	104	1	13	13
3288	375	58	1	13	13
3289	375	63	1	9	9
3290	375	130	1	12	12
3291	375	59	1	9	9
3292	375	56	1	12	12
3293	375	46	4	6	24
3294	375	116	2	8	16
3295	375	74	1	8	8
3296	375	151	1	17	17
3297	375	339	1	9	9
3298	367	1	1	2	2
3299	367	6	15	3	45
3300	367	149	1	13	13
3326	378	1	1	2	2
3327	378	148	3	17	51
3328	378	151	1	17	17
3329	378	63	4	9	36
3343	379	1	1	2	2
3344	379	2	1	2	2
3345	379	104	1	13	13
3346	379	25	1	14	14
3347	379	96	6	8	48
3348	379	114	1	10	10
3349	379	110	1	9	9
3350	379	34	1	8	8
3351	379	62	1	9	9
3352	379	63	1	9	9
3353	379	51	1	8	8
3354	379	20	1	8	8
3355	379	278	1	18	18
3368	380	1	1	2	2
3369	380	40	1	19	19
3370	380	36	1	8	8
3371	380	25	1	14	14
3372	380	33	1	11	11
3373	380	149	1	13	13
3374	380	324	1	11	11
3375	380	339	1	9	9
3376	380	56	2	12	24
3377	381	52	1	8	8
3378	381	109	1	14	14
3387	382	1	1	2	2
3388	382	99	1	12	12
3389	382	114	1	10	10
3390	382	27	1	8	8
3391	382	96	1	8	8
3392	382	46	1	6	6
3416	385	5	6	3	18
3417	385	9	1	12	12
3418	385	129	4	9	36
3419	385	138	1	8	8
3420	385	58	1	13	13
12446	734	344	1	11	11
12447	734	130	1	12	12
10296	1020	1	1	2	2
10297	1020	6	9	3	27
12448	734	20	1	8	8
3601	398	41	2	15	30
3602	398	120	2	18	36
3603	398	58	1	13	13
3604	398	149	1	13	13
3605	398	148	1	17	17
3423	386	113	1	25	25
3424	386	132	1	17	17
3606	398	151	1	17	17
3607	398	157	1	17	17
3608	398	63	2	9	18
3609	398	99	1	12	12
3610	398	130	1	12	12
3611	398	75	1	12	12
3643	401	1	1	2	2
3644	401	157	1	17	17
3645	401	96	1	8	8
3646	401	52	1	8	8
3647	401	20	1	8	8
3654	402	1	1	2	2
3655	402	5	2	3	6
12451	1210	1	1	2	2
12452	1210	5	2	3	6
3656	402	335	1	5	5
3657	402	74	1	8	8
3658	402	43	1	12	12
3659	402	318	1	12	12
3660	402	150	1	11	11
12453	1210	7	2	6	12
12454	1210	4	2	3	6
12455	1210	96	1	8	8
12456	1210	58	1	13	13
14900	1418	27	1	8	8
14901	1418	57	2	9	18
14902	1418	52	2	8	16
6805	709	278	1	18	18
5741	587	1	1	2	2
5742	587	5	7	3	21
6806	709	311	3	30	90
14903	1418	64	2	13	26
14918	1419	32	2	8	16
14919	1419	96	2	8	16
14920	1419	57	2	9	18
28463	838	151	2	17	34
3661	403	1	1	2	2
3662	403	3	4	3	12
3663	403	6	2	3	6
3664	403	8	1	6	6
3665	403	7	1	6	6
3666	403	58	1	13	13
28464	838	342	1	9	9
28465	838	109	1	14	14
28466	838	106	1	14	14
28467	838	99	1	12	12
28468	838	100	1	17	17
28487	2323	5	5	3	15
3693	404	131	2	22	44
3954	424	1	1	2	2
3955	424	64	1	13	13
3956	424	145	1	8	8
3957	424	6	3	3	9
3958	424	116	1	8	8
3989	427	337	1	9	9
3990	427	63	1	9	9
3991	427	145	1	8	8
3992	427	36	1	8	8
3993	427	334	1	8	8
3994	427	62	1	9	9
3995	427	30	1	8	8
3996	427	1	1	2	2
3997	427	7	1	6	6
3998	427	96	1	8	8
3999	427	114	1	10	10
4000	427	118	1	8	8
4001	427	31	1	9	9
4002	427	57	1	9	9
4003	427	71	1	8	8
4004	427	51	1	8	8
4005	427	52	1	8	8
4006	427	20	1	8	8
4057	226	1	1	2	2
4058	226	43	4	12	48
4059	226	172	2	13	26
4060	226	57	1	9	9
4061	226	7	2	6	12
4062	226	8	2	6	12
4063	226	56	2	12	24
4064	226	130	1	12	12
4065	226	114	2	10	20
4066	226	34	2	8	16
4067	226	24	1	8	8
4068	226	342	1	9	9
4069	226	116	1	8	8
4099	432	1	1	2	2
4100	432	32	2	8	16
4101	432	118	1	8	8
4102	432	114	1	10	10
4103	432	57	1	9	9
4104	432	105	1	13	13
4105	432	51	1	8	8
4106	432	95	1	8	8
4107	432	56	2	12	24
4108	432	62	1	9	9
4109	432	63	1	9	9
4110	432	46	3	6	18
4111	432	149	1	13	13
4112	432	19	1	15	15
4118	433	1	1	2	2
4119	433	57	3	9	27
4120	433	51	1	8	8
4121	433	27	1	8	8
4122	433	56	1	12	12
20418	1854	1	1	2	2
20419	1854	6	11	3	33
20420	1854	33	3	11	33
20421	1854	136	1	8	8
20422	1854	58	1	13	13
20423	1854	8	4	6	24
4579	472	1	1	2	2
4580	472	30	1	8	8
4581	472	110	1	9	9
4582	472	57	1	9	9
4583	472	32	1	8	8
4584	472	104	1	13	13
6796	707	34	2	8	16
4125	434	1	1	2	2
4126	434	5	17	3	51
5546	568	1	1	2	2
28480	2459	1	1	2	2
28481	2459	6	9	3	27
28482	2459	52	1	8	8
28483	2459	20	1	8	8
10298	1015	1	1	2	2
20424	1854	150	1	11	11
20425	1854	151	1	17	17
20426	1854	56	1	12	12
20427	1854	46	1	6	6
28484	2459	63	1	9	9
28485	2459	64	1	13	13
28486	2459	34	1	8	8
24152	2156	6	8	3	24
24153	2156	3	2	3	6
24154	2156	46	2	6	12
24155	2156	1	2	2	4
18116	1662	1	1	2	2
14944	123	1	1	2	2
14945	123	5	4	3	12
4153	435	1	1	2	2
4154	435	51	1	8	8
4155	435	52	1	8	8
4156	435	57	1	9	9
4157	435	64	1	13	13
4158	435	30	1	8	8
4159	435	114	1	10	10
4160	435	116	2	8	16
4161	435	96	2	8	16
4162	435	145	1	8	8
4163	435	70	1	8	8
14946	123	6	16	3	48
14947	123	8	2	6	12
18117	1662	120	1	18	18
18118	1662	31	1	9	9
18119	1662	27	1	8	8
18120	1662	318	1	12	12
18121	1662	112	1	41	41
4187	438	1	1	2	2
4188	438	149	6	13	78
4189	438	165	1	8	8
4190	438	110	1	9	9
4191	438	51	1	8	8
4192	438	62	1	9	9
4193	438	46	2	6	12
4194	440	5	1	3	3
4195	440	3	1	3	3
4196	440	32	1	8	8
4197	440	172	1	13	13
4198	440	27	2	8	16
4199	440	116	1	8	8
4200	440	52	1	8	8
4201	440	101	2	3	6
4202	440	110	1	9	9
4203	440	64	1	13	13
4204	440	31	1	9	9
4213	442	1	1	2	2
4214	442	5	10	3	30
4215	442	185	1	50	50
4248	369	1	1	2	2
4249	369	138	1	8	8
4250	369	116	1	8	8
4251	369	52	1	8	8
4252	369	131	1	22	22
4260	446	6	10	3	30
4261	446	1	1	2	2
4262	446	57	2	9	18
4263	446	52	1	8	8
4264	446	138	2	8	16
4265	446	110	1	9	9
4266	446	62	1	9	9
4276	449	303	3	13	39
4277	449	286	1	50	50
4278	449	278	1	18	18
4279	449	40	1	19	19
4280	449	323	1	20	20
4281	449	314	2	30	60
4293	451	1	1	2	2
4294	451	51	2	8	16
4295	451	52	1	8	8
4296	451	116	1	8	8
4297	451	151	1	17	17
4298	451	104	1	13	13
4318	453	1	1	2	2
4319	453	3	2	3	6
4320	453	58	2	13	26
4321	453	114	1	10	10
4322	453	56	2	12	24
4323	453	116	1	8	8
4324	453	150	1	11	11
4325	453	151	1	17	17
4326	453	34	1	8	8
4327	453	29	1	12	12
4328	453	132	1	17	17
4387	457	1	1	2	2
4388	457	51	1	8	8
4389	457	52	1	8	8
4390	457	340	1	15	15
4391	457	150	1	11	11
4392	457	56	2	12	24
4481	464	1	1	2	2
24105	843	172	1	13	13
24106	843	62	1	9	9
28488	2323	3	5	3	15
28489	2323	149	1	13	13
28490	2323	343	2	11	22
28499	2460	6	12	3	36
4482	464	6	5	3	15
4483	464	4	5	3	15
4484	464	150	1	11	11
4485	464	145	2	8	16
4486	464	26	1	14	14
4487	464	20	1	8	8
4393	458	1	1	2	2
4394	458	40	1	19	19
4395	458	51	1	8	8
4488	464	185	1	50	50
4489	464	192	1	30	30
4497	465	96	1	8	8
4498	465	148	1	17	17
4531	468	1	1	2	2
4532	468	64	1	13	13
4533	468	51	1	8	8
4534	468	96	1	8	8
4535	468	59	1	9	9
4536	468	46	4	6	24
10299	1015	6	3	3	9
10300	1015	27	1	8	8
10301	1015	57	1	9	9
10302	1015	64	1	13	13
5547	568	4	25	3	75
5548	568	145	1	8	8
5549	568	6	1	3	3
5550	568	191	1	30	30
5585	572	3	6	3	18
5586	572	1	1	2	2
5587	572	185	1	50	50
4585	472	20	1	8	8
6797	707	335	1	5	5
6798	707	71	1	8	8
6799	707	51	1	8	8
6800	707	116	1	8	8
14921	1419	63	2	9	18
6801	707	132	1	17	17
20414	1852	120	2	18	36
20415	1852	40	1	19	19
28500	2461	1	1	2	2
4603	474	1	1	2	2
4604	474	6	6	3	18
4605	474	4	9	3	27
4606	473	1	1	2	2
4607	473	4	2	3	6
4608	473	57	1	9	9
4609	473	33	1	11	11
4610	473	56	2	12	24
4611	473	52	1	8	8
4612	473	149	1	13	13
4613	473	145	1	8	8
4614	473	62	1	9	9
4622	476	131	2	22	44
4648	478	172	1	13	13
4649	478	118	2	8	16
4650	478	1	1	2	2
4678	480	1	1	2	2
4679	480	4	6	3	18
4680	480	71	1	8	8
4681	480	56	1	12	12
4682	480	339	1	9	9
4683	480	104	1	13	13
4684	480	149	1	13	13
4822	493	63	2	9	18
4823	493	57	2	9	18
4824	493	96	2	8	16
4825	493	149	2	13	26
4826	493	145	2	8	16
4829	494	5	5	3	15
4830	494	4	4	3	12
4833	86	1	1	2	2
4834	86	6	1	3	3
4835	86	7	1	6	6
4840	447	56	1	12	12
4841	447	64	1	13	13
4842	492	1	1	2	2
4843	492	6	1	3	3
4844	492	5	1	3	3
4845	492	7	1	6	6
4846	492	8	1	6	6
4847	492	317	1	30	30
4848	492	16	1	20	20
4849	492	316	1	20	20
4850	467	1	1	2	2
4851	467	6	3	3	9
4852	467	4	3	3	9
4853	467	51	1	8	8
4854	467	57	1	9	9
4855	467	116	1	8	8
4856	467	131	1	22	22
4857	332	135	1	99	99
4865	495	1	1	2	2
4866	495	57	1	9	9
4867	495	52	1	8	8
4868	495	145	1	8	8
4869	495	151	1	17	17
4870	495	172	1	13	13
4871	495	32	1	8	8
4878	496	1	2	2	4
4879	496	4	10	3	30
4880	496	116	2	8	16
4881	496	57	1	9	9
4882	496	62	1	9	9
4883	496	114	1	10	10
4889	497	1	1	2	2
4890	497	4	2	3	6
4891	497	5	1	3	3
4892	497	63	1	9	9
4893	497	129	1	9	9
4906	498	1	1	2	2
4907	498	4	2	3	6
4908	498	5	1	3	3
4909	498	32	1	8	8
4910	498	62	1	9	9
4911	498	64	1	13	13
4347	454	1	1	2	2
4348	454	120	2	18	36
4349	454	114	1	10	10
4350	454	51	2	8	16
4351	454	52	2	8	16
4352	454	39	1	8	8
4353	455	1	1	2	2
4354	455	4	2	3	6
4355	455	57	1	9	9
4356	455	105	1	13	13
4357	455	334	1	8	8
4358	455	104	1	13	13
4359	455	35	1	17	17
4360	455	51	1	8	8
4361	455	150	1	11	11
4362	455	56	2	12	24
4363	455	28	1	12	12
4364	455	101	7	3	21
4365	455	190	1	30	30
10303	1015	52	1	8	8
10304	1015	130	1	12	12
10305	1015	157	1	17	17
14922	1419	51	3	8	24
20416	1852	116	1	8	8
20417	1852	24	1	8	8
21772	1946	1	1	2	2
14923	1419	116	2	8	16
14924	1419	74	1	8	8
14925	1419	1	1	2	2
14926	1419	192	1	30	30
28501	2461	32	1	8	8
28502	2461	58	1	13	13
28503	2461	114	1	10	10
28504	2461	51	1	8	8
21773	1946	6	2	3	6
12457	1213	4	2	3	6
12458	1213	242	3	8	24
21774	1946	116	1	8	8
24126	2153	1	1	2	2
24127	2153	5	1	3	3
24128	2153	3	3	3	9
17512	1607	1	1	2	2
12478	1216	1	1	2	2
12479	1216	3	11	3	33
12480	1216	57	1	9	9
12481	1216	51	1	8	8
12482	1216	334	1	8	8
12483	1216	63	1	9	9
17513	1607	27	2	8	16
17514	1607	51	1	8	8
12496	1219	40	2	19	38
12497	1219	1	1	2	2
17515	1607	39	3	8	24
17516	1607	185	1	50	50
17530	1610	2	1	2	2
17531	1610	44	1	8	8
17532	1610	163	1	8	8
17533	1610	116	1	8	8
18079	1658	1	1	2	2
18080	1658	5	5	3	15
18081	1658	4	10	3	30
18082	1658	260	1	16	16
24129	2153	163	1	8	8
24130	2153	25	2	14	28
28505	2461	318	1	12	12
28506	2461	62	1	9	9
4598	328	1	1	2	2
4599	328	319	2	14	28
4600	328	36	1	8	8
4601	328	339	1	9	9
4602	328	324	1	11	11
14967	1423	2	1	2	2
14968	1423	3	5	3	15
14969	1423	5	3	3	9
14970	1423	57	1	9	9
14971	1423	120	1	18	18
14972	1423	116	1	8	8
14973	1423	56	1	12	12
4637	477	1	1	2	2
4638	477	5	2	3	6
4639	477	3	2	3	6
4640	477	116	1	8	8
4641	477	149	2	13	26
4642	477	56	3	12	36
4643	477	51	1	8	8
4644	477	151	4	17	68
4661	479	1	1	2	2
4662	479	6	3	3	9
4663	479	114	1	10	10
4664	479	335	2	5	10
4665	479	172	1	13	13
4666	479	96	1	8	8
4667	479	145	1	8	8
4668	479	62	1	9	9
4669	479	64	1	13	13
4670	479	130	1	12	12
4723	482	1	1	2	2
4724	482	40	5	19	95
4725	482	319	2	14	28
4726	482	56	4	12	48
4732	483	1	1	2	2
4733	483	3	4	3	12
4747	484	5	4	3	12
4748	484	3	3	3	9
4749	484	334	1	8	8
4750	484	110	1	9	9
4751	484	51	1	8	8
4752	484	167	1	8	8
4753	484	20	1	8	8
4754	484	62	1	9	9
4755	484	191	1	30	30
4756	484	271	1	24	24
4761	486	4	6	3	18
4762	486	1	1	2	2
4763	397	5	2	3	6
4764	397	57	1	9	9
4765	397	51	1	8	8
4779	487	1	2	2	4
4780	487	4	2	3	6
4781	487	57	1	9	9
4782	487	32	1	8	8
4783	488	3	3	3	9
4784	488	5	3	3	9
4785	488	52	1	8	8
4786	488	190	1	30	30
4798	491	4	40	3	120
4817	493	1	1	2	2
4818	493	4	9	3	27
4819	493	52	1	8	8
4820	493	51	1	8	8
4821	493	116	2	8	16
4912	498	145	1	8	8
6819	711	278	1	18	18
6820	711	282	2	34	68
6821	711	315	1	65	65
6822	711	132	3	17	51
17527	1609	163	1	8	8
17528	1609	96	1	8	8
4919	499	1	1	2	2
4920	499	5	5	3	15
4921	499	58	1	13	13
4922	499	63	1	9	9
4923	499	27	1	8	8
4924	499	185	1	50	50
17529	1609	116	1	8	8
4926	500	5	3	3	9
20428	1854	19	2	15	30
21775	1946	31	1	9	9
21776	1946	96	1	8	8
21777	1946	36	1	8	8
24131	2153	28	1	12	12
24132	2153	63	1	9	9
24133	2153	342	1	9	9
4934	501	1	1	2	2
4935	501	109	1	14	14
4936	501	149	1	13	13
4937	501	148	1	17	17
4938	501	56	1	12	12
4939	501	61	1	8	8
4940	501	40	1	19	19
24138	2154	1	1	2	2
18170	1667	1	1	2	2
18171	1667	5	4	3	12
18172	1667	51	1	8	8
18173	1667	52	2	8	16
4946	502	1	1	2	2
4947	502	4	10	3	30
4948	502	6	5	3	15
4949	502	120	1	18	18
4950	502	142	1	9	9
18174	1667	30	1	8	8
24139	2154	5	1	3	3
4953	503	1	1	2	2
4954	503	4	16	3	48
24140	2154	3	6	3	18
24141	2154	63	1	9	9
28566	1428	2	1	2	2
28567	1428	58	2	13	26
28568	1428	114	1	10	10
28569	1428	110	1	9	9
28570	1428	74	1	8	8
28571	1428	51	2	8	16
28572	1428	76	2	36	72
28573	1428	149	8	13	104
4968	504	4	18	3	54
4973	505	3	4	3	12
4974	505	335	2	5	10
4975	505	44	1	8	8
4976	505	114	1	10	10
4977	505	62	2	9	18
4978	505	63	3	9	27
4979	505	110	1	9	9
4980	505	142	1	9	9
4981	505	245	1	9	9
4982	505	51	2	8	16
4983	505	52	2	8	16
4984	505	165	1	8	8
4988	506	5	4	3	12
4989	506	52	1	8	8
4990	506	51	1	8	8
4991	506	1	1	2	2
5001	508	1	1	2	2
5002	508	5	5	3	15
5003	508	52	1	8	8
5004	508	96	2	8	16
5005	508	56	1	12	12
5006	508	20	2	8	16
5010	509	1	1	2	2
5011	509	5	6	3	18
5012	509	56	2	12	24
5018	511	2	1	2	2
5019	511	4	4	3	12
5020	511	57	1	9	9
5021	511	114	1	10	10
5032	513	1	1	2	2
5033	513	5	4	3	12
5034	513	4	3	3	9
5035	513	149	1	13	13
5036	513	165	1	8	8
5037	513	20	1	8	8
5038	513	91	2	8	16
5039	513	96	1	8	8
5040	512	1	1	2	2
5041	512	6	12	3	36
5073	516	5	8	3	24
5074	516	32	1	8	8
5075	516	57	1	9	9
5076	516	165	1	8	8
5077	516	105	2	13	26
5078	516	52	1	8	8
5079	516	62	1	9	9
5080	516	63	1	9	9
5081	516	64	1	13	13
5082	516	56	2	12	24
5083	516	114	1	10	10
5086	517	1	1	2	2
5087	517	4	11	3	33
5093	518	1	1	2	2
5094	518	5	2	3	6
5095	518	4	1	3	3
5096	518	58	2	13	26
5097	518	148	1	17	17
5134	521	6	3	3	9
5135	521	4	3	3	9
5148	522	3	6	3	18
5149	522	5	4	3	12
5150	522	32	2	8	16
5155	523	1	1	2	2
5156	523	4	3	3	9
5157	523	63	2	9	18
5162	525	1	1	2	2
5163	525	5	17	3	51
5171	527	1	1	2	2
5172	527	6	3	3	9
5173	527	4	7	3	21
5151	522	44	1	8	8
5152	522	51	2	8	16
5153	522	52	1	8	8
5154	522	91	3	8	24
5158	524	1	1	2	2
5159	524	5	6	3	18
5169	526	6	2	3	6
5170	526	1	1	2	2
5192	528	40	1	19	19
5193	528	5	6	3	18
5194	528	148	1	17	17
5195	528	64	1	13	13
5196	528	96	1	8	8
5197	528	2	1	2	2
14948	123	52	1	8	8
8395	865	63	2	9	18
5206	531	1	10	2	20
5207	531	4	1	3	3
8396	865	62	1	9	9
8397	865	149	2	13	26
8398	865	51	3	8	24
8399	865	56	2	12	24
8400	865	1	1	2	2
8421	869	1	1	2	2
8422	869	96	1	8	8
8423	869	153	1	17	17
8424	869	51	1	8	8
6872	724	132	4	17	68
6873	724	131	2	22	44
6880	726	58	5	13	65
5247	536	1	1	2	2
5248	536	3	13	3	39
6881	726	1	1	2	2
5262	538	1	1	2	2
5263	538	5	5	3	15
5264	538	31	2	9	18
5265	538	342	1	9	9
5266	538	191	1	30	30
5270	313	5	6	3	18
5271	313	4	1	3	3
5272	313	113	1	25	25
6882	726	311	3	30	90
6883	726	307	1	24	24
8425	869	149	1	13	13
14949	123	130	1	12	12
28535	2464	51	1	8	8
5642	577	5	20	3	60
5643	577	3	20	3	60
5644	577	1	2	2	4
5645	577	335	8	5	40
5646	577	172	2	13	26
5647	577	30	2	8	16
5648	577	32	2	8	16
5649	577	114	2	10	20
5650	577	130	2	12	24
5651	577	109	3	14	42
5678	580	5	4	3	12
5679	580	149	1	13	13
5680	580	64	1	13	13
5681	580	130	1	12	12
24142	2152	6	4	3	12
24143	2152	1	1	2	2
24144	2152	46	2	6	12
24164	1433	91	1	8	8
6900	729	314	1	30	30
6901	729	311	1	30	30
7149	758	278	1	18	18
24165	1433	6	8	3	24
24166	1433	57	2	9	18
24167	1433	32	1	8	8
24168	1433	96	1	8	8
7154	760	132	2	17	34
24169	1433	52	1	8	8
24170	1433	46	1	6	6
28536	2464	26	1	14	14
5724	584	5	4	3	12
5725	584	137	1	8	8
5726	584	2	2	2	4
5727	584	29	1	12	12
5743	587	3	1	3	3
5744	587	96	1	8	8
5745	587	145	1	8	8
5746	587	30	1	8	8
5747	587	62	1	9	9
5748	587	24	1	8	8
5749	587	257	2	3	6
5767	589	1	1	2	2
5768	589	5	8	3	24
5769	589	130	1	12	12
5834	597	1	1	2	2
5835	597	5	5	3	15
5836	597	34	3	8	24
5837	597	145	2	8	16
5867	601	5	7	3	21
5904	604	3	6	3	18
5905	604	96	1	8	8
5906	604	116	1	8	8
5907	604	32	1	8	8
5908	604	62	1	9	9
5909	604	1	1	2	2
5924	606	5	11	3	33
5925	608	1	1	2	2
5926	608	5	6	3	18
5927	608	3	6	3	18
5958	610	43	1	12	12
5959	610	1	1	2	2
5969	613	1	1	2	2
5970	613	5	15	3	45
5971	613	185	1	50	50
5990	614	32	1	8	8
5991	614	324	1	11	11
5992	614	52	1	8	8
5993	614	165	1	8	8
5994	614	20	1	8	8
5995	614	91	1	8	8
5998	616	4	12	3	36
5999	616	1	1	2	2
6002	617	5	10	3	30
6003	617	73	2	8	16
6019	620	5	5	3	15
6020	620	1	1	2	2
6021	620	51	1	8	8
6022	620	32	1	8	8
6023	620	70	1	8	8
6024	620	72	1	8	8
6025	620	129	1	9	9
6026	620	116	1	8	8
6027	620	30	1	8	8
6030	621	5	13	3	39
6031	621	1	1	2	2
28537	2464	114	1	10	10
28538	2464	41	1	15	15
17544	1611	1	1	2	2
17545	1611	3	5	3	15
5222	384	30	1	8	8
5223	384	96	1	8	8
17546	1611	6	5	3	15
17547	1611	76	1	36	36
10323	72	1	1	2	2
10324	72	5	10	3	30
10325	72	4	2	3	6
10326	72	30	2	8	16
5590	573	3	4	3	12
5591	573	335	5	5	25
10327	72	129	3	9	27
10328	72	75	1	12	12
10329	72	35	1	17	17
8411	868	1	1	2	2
8412	868	57	1	9	9
8413	868	62	3	9	27
5298	541	2	1	2	2
5299	541	5	3	3	9
5300	541	6	3	3	9
5301	541	335	1	5	5
5302	541	142	1	9	9
8414	868	96	1	8	8
8415	868	334	1	8	8
8416	868	56	2	12	24
8417	868	110	1	9	9
5312	543	1	1	2	2
5313	543	4	3	3	9
5314	543	5	1	3	3
5315	543	149	1	13	13
5316	543	57	1	9	9
8418	868	51	2	8	16
10330	72	52	1	8	8
10331	72	43	1	12	12
10332	72	109	1	14	14
10333	72	148	1	17	17
10334	72	185	1	50	50
10344	1025	5	3	3	9
10345	1025	27	1	8	8
5668	579	2	1	2	2
5669	579	5	11	3	33
5670	579	33	2	11	22
5671	579	71	1	8	8
5672	579	165	2	8	16
5673	579	318	1	12	12
5711	582	5	6	3	18
5750	586	1	1	2	2
5751	586	4	10	3	30
10346	1025	172	1	13	13
10347	1025	32	1	8	8
10348	1025	96	1	8	8
20464	852	62	2	9	18
20465	852	46	5	6	30
5758	588	1	1	2	2
5759	588	5	5	3	15
5760	588	96	1	8	8
5761	588	31	1	9	9
5762	588	52	2	8	16
5763	588	51	1	8	8
5790	593	5	7	3	21
5791	593	120	1	18	18
5792	593	145	1	8	8
5793	593	130	2	12	24
5794	593	1	1	2	2
5808	595	262	1	28	28
5809	595	1	1	2	2
5810	595	20	2	8	16
5811	595	32	1	8	8
5812	595	24	1	8	8
5817	596	1	1	2	2
5818	596	52	1	8	8
5819	596	114	1	10	10
5820	596	71	1	8	8
5821	596	190	1	30	30
5838	598	3	10	3	30
5839	598	27	1	8	8
5840	598	333	3	8	24
5841	598	334	1	8	8
5842	598	34	1	8	8
5843	598	95	1	8	8
5844	598	130	2	12	24
5845	598	145	1	8	8
5846	598	62	1	9	9
5847	598	52	3	8	24
5848	598	114	1	10	10
5849	598	1	2	2	4
5899	603	1	1	2	2
5900	603	5	7	3	21
5901	603	323	1	20	20
5902	603	120	1	18	18
5919	245	1	1	2	2
5920	245	5	6	3	18
5921	245	32	1	8	8
5922	245	339	1	9	9
5923	245	51	1	8	8
5945	609	4	6	3	18
5946	609	32	2	8	16
5947	609	114	1	10	10
5948	609	27	1	8	8
5949	609	96	1	8	8
5950	609	264	1	10	10
5955	610	27	1	8	8
5956	610	163	1	8	8
5957	610	20	1	8	8
28540	2462	1	1	2	2
28541	2462	5	3	3	9
28542	2462	20	1	8	8
28543	2462	31	1	9	9
15003	1425	2	1	2	2
15004	1425	5	6	3	18
15063	1432	1	1	2	2
5198	530	1	1	2	2
5199	530	57	3	9	27
5200	530	63	2	9	18
5201	530	52	4	8	32
5202	530	56	4	12	48
5203	530	192	2	30	60
15064	1432	3	5	3	15
5622	575	1	1	2	2
5623	575	5	4	3	12
5624	575	52	1	8	8
5625	575	63	1	9	9
5626	575	347	1	13	13
5216	532	1	1	2	2
5217	532	5	5	3	15
5218	532	4	5	3	15
5219	532	52	2	8	16
5220	532	51	1	8	8
5221	532	185	1	50	50
15065	1432	340	1	15	15
15066	1432	339	1	9	9
12494	1218	4	20	3	60
5240	535	5	4	3	12
5241	535	4	1	3	3
5242	535	74	1	8	8
5243	535	52	1	8	8
5244	535	66	1	8	8
10351	1024	1	1	2	2
10352	1024	5	8	3	24
10357	1026	5	5	3	15
12495	1218	1	1	2	2
5257	537	1	1	2	2
5258	537	91	1	8	8
5259	537	5	3	3	9
5260	537	335	1	5	5
15067	1432	109	1	14	14
15068	1432	56	1	12	12
5291	542	1	2	2	4
5292	542	31	1	9	9
5293	542	57	1	9	9
5294	542	51	1	8	8
5295	542	149	1	13	13
5296	542	145	1	8	8
5297	542	70	1	8	8
5323	192	1	1	2	2
5324	192	5	3	3	9
5325	192	3	5	3	15
5326	192	192	1	30	30
12509	1220	26	1	14	14
12510	1220	114	2	10	20
12511	1220	57	1	9	9
5331	544	1	1	2	2
5332	544	57	1	9	9
5333	544	5	1	3	3
5334	544	149	1	13	13
5335	544	33	1	11	11
5692	581	335	1	5	5
5693	581	5	6	3	18
5694	581	57	2	9	18
5342	545	2	1	2	2
5343	545	5	1	3	3
5344	545	120	1	18	18
5345	545	149	2	13	26
5346	547	113	1	25	25
5347	547	319	1	14	14
5695	581	32	1	8	8
5696	581	213	2	8	16
5697	581	110	1	9	9
5698	581	104	1	13	13
5356	548	2	1	2	2
5357	548	6	16	3	48
5358	548	58	1	13	13
5359	548	148	1	17	17
5699	581	145	1	8	8
5700	581	31	1	9	9
5701	581	1	1	2	2
5712	583	1	1	2	2
5365	549	5	4	3	12
5366	549	149	1	13	13
5367	549	32	1	8	8
5368	549	52	1	8	8
5369	549	57	1	9	9
5370	549	258	1	3	3
5713	583	62	1	9	9
5714	583	63	1	9	9
5715	583	64	1	13	13
5379	551	5	10	3	30
5380	551	27	1	8	8
5389	552	1	2	2	4
5390	552	5	5	3	15
5391	552	149	1	13	13
5392	552	32	1	8	8
5393	552	145	1	8	8
5394	552	24	1	8	8
5395	552	116	1	8	8
5396	552	114	1	10	10
5413	553	1	1	2	2
5414	553	3	6	3	18
5415	553	6	1	3	3
5416	553	57	1	9	9
5417	553	32	1	8	8
5418	553	33	1	11	11
5419	553	63	2	9	18
5420	553	20	1	8	8
5421	553	52	1	8	8
5424	554	1	1	2	2
5425	554	5	2	3	6
5426	554	71	1	8	8
5427	554	130	1	12	12
5428	554	56	1	12	12
5429	554	151	1	17	17
5430	554	40	1	19	19
5434	555	4	10	3	30
5435	555	67	1	31	31
5436	556	3	3	3	9
5437	556	5	3	3	9
5438	556	260	1	16	16
5448	557	1	1	2	2
5449	557	5	3	3	9
5450	557	6	12	3	36
5451	557	32	1	8	8
5452	557	30	1	8	8
5453	557	114	1	10	10
5454	557	64	1	13	13
5455	557	51	1	8	8
5456	557	165	1	8	8
8419	868	91	1	8	8
8420	868	313	1	16	16
10349	1025	163	1	8	8
10350	1025	264	1	10	10
14974	1423	51	1	8	8
17537	706	1	1	2	2
17538	706	6	4	3	12
28544	2462	96	1	8	8
6073	623	3	3	3	9
6074	623	5	5	3	15
6075	623	32	1	8	8
6076	623	52	1	8	8
6077	623	129	1	9	9
6078	623	137	1	8	8
6079	623	44	1	8	8
6080	623	1	1	2	2
10359	1027	1	2	2	4
10360	1027	120	10	18	180
28545	2462	52	1	8	8
28546	2462	73	1	8	8
24171	1433	20	1	8	8
28547	2462	145	1	8	8
6889	727	311	1	30	30
6890	727	40	1	19	19
6891	727	26	2	14	28
6892	727	112	1	41	41
6893	727	307	1	24	24
6905	730	1	1	2	2
6906	730	3	15	3	45
6907	730	311	1	30	30
6908	731	314	1	30	30
6156	533	1	1	2	2
6157	533	5	10	3	30
6158	533	62	2	9	18
6159	533	150	1	11	11
6909	731	291	1	30	30
6910	731	282	2	34	68
6198	636	114	1	10	10
6199	636	51	1	8	8
6200	636	64	1	13	13
6201	636	104	1	13	13
6202	636	5	5	3	15
28577	1413	116	2	8	16
28578	1413	57	1	9	9
28579	1413	110	1	9	9
7241	769	30	1	8	8
7242	769	62	1	9	9
7243	769	96	1	8	8
7244	769	105	1	13	13
7245	769	57	4	9	36
7260	126	315	1	65	65
7261	126	278	1	18	18
7266	674	1	1	2	2
7267	674	5	7	3	21
7268	674	172	1	13	13
7269	674	105	1	13	13
15029	1430	1	1	2	2
15030	1430	149	4	13	52
28587	2467	1	2	2	4
28588	2467	6	12	3	36
28589	2467	3	3	3	9
28590	2467	24	1	8	8
28591	2467	46	2	6	12
28592	2467	167	1	8	8
28593	2467	51	1	8	8
28610	2436	3	3	3	9
28611	2436	5	2	3	6
28612	2436	114	1	10	10
28613	2436	57	1	9	9
15091	1427	3	5	3	15
15092	1427	5	12	3	36
7296	773	1	1	2	2
7297	773	56	2	12	24
7298	773	51	1	8	8
7299	773	339	1	9	9
7300	773	105	1	13	13
15093	1427	1	1	2	2
28614	2436	32	1	8	8
28615	2436	20	1	8	8
15102	1429	1	1	2	2
28616	2436	116	1	8	8
28617	2436	63	1	9	9
28618	2436	52	1	8	8
28625	2468	1	1	2	2
28626	2468	148	1	17	17
7314	776	1	1	2	2
7315	776	3	8	3	24
7316	776	114	1	10	10
7317	776	27	1	8	8
7318	776	105	1	13	13
7319	776	151	1	17	17
7320	776	334	1	8	8
7325	777	311	3	30	90
7326	777	307	1	24	24
7327	777	303	2	13	26
7328	777	315	1	65	65
7329	778	315	1	65	65
7330	778	282	1	34	34
28627	2468	151	1	17	17
28628	2468	51	1	8	8
7352	781	1	1	2	2
7353	781	5	8	3	24
7354	781	46	1	6	6
7355	782	1	1	2	2
7356	782	57	4	9	36
7357	782	43	2	12	24
7358	782	31	2	9	18
7359	782	96	3	8	24
7360	782	3	3	3	9
28629	2468	120	2	18	36
7383	785	1	1	2	2
7384	785	5	3	3	9
7385	785	3	4	3	12
7386	785	46	2	6	12
7387	785	51	1	8	8
7388	785	150	1	11	11
7493	793	1	1	2	2
7494	793	5	2	3	6
7495	793	8	4	6	24
7496	793	113	1	25	25
7497	793	185	1	50	50
7563	799	282	1	34	34
7564	799	296	1	170	170
7565	799	297	6	3	18
7582	801	278	2	18	36
7638	809	1	1	2	2
6041	622	1	1	2	2
6042	622	6	3	3	9
6043	622	62	1	9	9
6044	622	110	1	9	9
6045	622	145	1	8	8
6046	622	165	1	8	8
6047	622	116	1	8	8
6048	622	96	1	8	8
6049	622	321	2	3	6
6091	624	3	10	3	30
6092	624	5	6	3	18
6093	624	113	1	25	25
17539	706	3	3	3	9
28594	2458	3	3	3	9
28595	2458	1	1	2	2
28596	2463	1	1	2	2
6125	627	5	1	3	3
6126	627	4	2	3	6
6127	627	71	1	8	8
6128	627	339	1	9	9
6129	627	137	1	8	8
10358	1026	3	5	3	15
12498	1219	100	2	17	34
8447	871	5	16	3	48
12499	1219	296	1	170	170
28597	2463	9	1	12	12
6874	725	282	1	34	34
6875	725	313	1	16	16
6150	629	1	1	2	2
6151	629	5	10	3	30
6152	629	20	1	8	8
6153	629	34	1	8	8
6160	630	1	1	2	2
6161	630	5	7	3	21
8448	871	3	8	3	24
8449	871	26	1	14	14
8450	871	43	1	12	12
8451	871	58	1	13	13
6898	728	1	1	2	2
6899	728	5	16	3	48
8452	871	51	1	8	8
8453	871	52	1	8	8
8454	871	130	1	12	12
6911	732	311	1	30	30
6912	732	307	1	24	24
6913	732	132	1	17	17
7161	761	2	1	2	2
7162	761	106	2	14	28
7163	761	6	2	3	6
7164	761	46	3	6	18
7165	761	51	2	8	16
7166	761	185	1	50	50
8455	871	344	2	11	22
7168	762	303	5	13	65
7181	763	1	1	2	2
7182	763	41	2	15	30
7183	763	3	3	3	9
7184	763	46	3	6	18
7185	763	5	2	3	6
7186	763	6	2	3	6
7187	763	8	1	6	6
7188	763	31	1	9	9
7189	763	62	1	9	9
7190	763	58	1	13	13
7191	763	315	2	65	130
7192	763	278	1	18	18
7199	764	1	1	2	2
7200	764	5	6	3	18
7201	764	4	4	3	12
7202	764	95	1	8	8
7203	764	27	1	8	8
7204	764	311	1	30	30
8456	871	75	1	12	12
8457	871	145	1	8	8
12526	1215	1	1	2	2
12527	1215	5	5	3	15
20590	1863	8	2	6	12
20591	1863	5	1	3	3
20592	1863	96	1	8	8
7333	779	1	1	2	2
7334	779	5	25	3	75
7399	786	1	1	2	2
7400	786	5	5	3	15
7401	786	27	1	8	8
7402	786	165	2	8	16
7403	786	145	1	8	8
7404	786	114	1	10	10
7405	786	51	1	8	8
7406	786	30	1	8	8
7407	786	96	1	8	8
7408	786	342	1	9	9
7639	809	5	3	3	9
7640	809	96	1	8	8
7641	809	105	1	13	13
7642	809	149	1	13	13
7643	809	43	1	12	12
7644	809	339	1	9	9
7645	809	57	1	9	9
7646	809	64	2	13	26
7647	809	25	1	14	14
7801	821	1	1	2	2
7802	821	5	2	3	6
7803	821	8	3	6	18
7804	821	106	1	14	14
7805	821	113	1	25	25
7806	821	335	1	5	5
7807	821	192	1	30	30
7817	824	1	1	2	2
7818	824	3	5	3	15
7819	824	5	4	3	12
7859	826	2	1	2	2
7860	826	7	5	6	30
7861	826	5	2	3	6
7862	826	8	1	6	6
7863	826	149	2	13	26
7864	826	150	1	11	11
7865	826	335	1	5	5
7866	826	31	1	9	9
7867	826	39	1	8	8
7868	826	51	1	8	8
7869	826	56	1	12	12
7870	826	46	2	6	12
7871	826	334	1	8	8
7872	826	116	1	8	8
7873	828	339	1	9	9
7874	828	56	1	12	12
7875	828	1	1	2	2
7876	828	138	1	8	8
7877	828	149	4	13	52
7878	828	8	1	6	6
7879	828	52	1	8	8
6914	733	311	6	30	180
6920	736	282	3	34	102
6921	717	1	1	2	2
6922	717	8	6	6	36
6923	717	7	2	6	12
28598	2463	40	1	19	19
24181	2105	3	6	3	18
24182	2105	31	1	9	9
24183	2105	96	1	8	8
6924	717	6	50	3	150
20442	1612	1	1	2	2
20443	1612	339	2	9	18
20444	1612	63	1	9	9
20445	1612	31	1	9	9
20446	1612	51	1	8	8
20447	1612	52	1	8	8
20448	1612	342	2	9	18
24184	2105	334	1	8	8
24185	2105	20	1	8	8
24186	2105	165	1	8	8
24187	2105	63	1	9	9
24188	2105	57	1	9	9
24189	2105	52	2	8	16
24196	2157	1	1	2	2
24197	2157	114	2	10	20
24198	2157	51	2	8	16
6123	625	4	6	3	18
6124	625	5	6	3	18
6130	626	40	1	19	19
6131	626	5	2	3	6
6132	626	149	1	13	13
6133	626	64	1	13	13
6134	626	56	1	12	12
6135	626	120	1	18	18
6136	626	39	1	8	8
6137	626	145	1	8	8
6138	626	51	1	8	8
6139	626	1	1	2	2
24199	2157	62	4	9	36
28599	2463	7	4	6	24
28600	2463	5	2	3	6
28601	2463	56	2	12	24
28602	2463	334	1	8	8
28603	2463	25	1	14	14
28604	2463	143	1	9	9
28605	2463	28	1	12	12
28606	2445	48	1	10	10
6206	638	1	1	2	2
6207	638	3	4	3	12
6208	638	5	5	3	15
6209	638	61	1	8	8
6210	638	163	1	8	8
6211	638	213	1	8	8
6212	639	4	4	3	12
6213	639	5	2	3	6
6214	639	1	1	2	2
28607	2445	1	1	2	2
6216	641	1	1	2	2
6217	641	6	11	3	33
6218	641	113	1	25	25
28608	2445	3	2	3	6
6225	642	1	1	2	2
6226	642	120	2	18	36
6227	642	5	2	3	6
6228	642	114	1	10	10
6229	642	303	1	13	13
6234	643	1	1	2	2
6235	643	5	7	3	21
6236	643	112	1	41	41
6237	643	119	1	31	31
6239	644	5	6	3	18
6260	646	1	1	2	2
6261	646	5	9	3	27
6264	647	1	1	2	2
6265	647	5	19	3	57
6275	648	1	1	2	2
6276	648	5	5	3	15
6277	648	62	2	9	18
6278	648	64	1	13	13
6279	648	104	1	13	13
6280	648	130	2	12	24
6281	648	145	2	8	16
6282	648	51	2	8	16
6283	648	61	1	8	8
6287	649	1	1	2	2
6288	649	5	5	3	15
6289	649	3	5	3	15
6310	651	2	1	2	2
6311	651	4	6	3	18
6312	651	5	3	3	9
6313	651	56	1	12	12
6314	651	149	1	13	13
6315	651	20	1	8	8
6318	652	1	1	2	2
6319	652	4	13	3	39
6324	653	1	1	2	2
6325	653	5	3	3	9
6326	653	165	3	8	24
6338	657	4	9	3	27
6345	235	3	8	3	24
6346	235	1	1	2	2
6352	659	1	1	2	2
6353	659	130	1	12	12
6354	659	157	1	17	17
6355	659	150	2	11	22
6356	659	337	2	9	18
6359	116	1	1	2	2
6360	116	4	6	3	18
6368	660	5	10	3	30
6369	660	149	2	13	26
6370	660	116	1	8	8
6371	660	52	2	8	16
6372	660	151	1	17	17
6373	660	70	1	8	8
6374	660	1	1	2	2
6379	661	1	1	2	2
6380	661	5	2	3	6
6381	661	3	2	3	6
6382	661	113	1	25	25
6415	663	4	4	3	12
6416	663	5	2	3	6
6417	663	105	1	13	13
6418	663	131	3	22	66
6419	663	150	2	11	22
6389	602	150	1	11	11
6390	602	70	1	8	8
6391	602	52	1	8	8
6392	602	213	1	8	8
6393	602	318	1	12	12
6394	602	1	1	2	2
6397	619	1	1	2	2
6398	619	5	1	3	3
6403	662	1	1	2	2
6404	662	91	3	8	24
6405	662	4	7	3	21
6406	662	5	6	3	18
20461	1856	2	1	2	2
14997	1426	145	1	8	8
14998	1426	64	1	13	13
14999	1426	26	1	14	14
20462	1856	76	1	36	36
20463	1856	3	5	3	15
28609	127	6	4	3	12
6944	716	1	1	2	2
6945	716	6	1	3	3
6946	716	317	1	30	30
6947	716	16	1	20	20
6948	716	316	1	20	20
6949	718	315	2	65	130
17596	1616	1	1	2	2
15000	1426	114	1	10	10
15001	1426	151	1	17	17
15002	1426	41	1	15	15
17597	1616	5	4	3	12
10393	1030	5	1	3	3
10394	1030	64	1	13	13
10395	1030	52	1	8	8
10396	1030	20	2	8	16
10403	1031	1	1	2	2
10404	1031	4	8	3	24
17598	1616	4	4	3	12
17599	1616	149	1	13	13
17612	1618	4	4	3	12
7029	743	278	1	18	18
7030	743	282	1	34	34
7035	469	278	1	18	18
7036	744	282	1	34	34
7037	744	284	1	11	11
7038	744	303	1	13	13
7045	746	1	1	2	2
7046	746	4	11	3	33
7047	746	110	1	9	9
7048	746	333	2	8	16
7049	746	100	1	17	17
7054	747	40	17	19	323
7055	747	24	1	8	8
7056	747	30	1	8	8
7057	747	46	8	6	48
7058	747	317	1	30	30
7059	748	315	1	65	65
7129	749	339	1	9	9
7130	749	1	1	2	2
7131	749	342	1	9	9
7132	749	27	1	8	8
7133	749	62	1	9	9
7138	756	311	3	30	90
7207	765	315	1	65	65
7208	765	286	1	50	50
7251	770	1	1	2	2
7252	770	40	1	19	19
7253	770	25	1	14	14
7254	770	157	1	17	17
7255	770	101	1	3	3
7257	771	3	20	3	60
7280	772	1	1	2	2
7281	772	5	1	3	3
7282	772	30	1	8	8
7283	772	57	1	9	9
7284	772	96	1	8	8
7285	772	51	1	8	8
7286	772	52	1	8	8
7287	772	46	1	6	6
7288	772	145	1	8	8
7289	772	120	1	18	18
7290	772	347	1	13	13
7339	780	1	1	2	2
7340	780	30	2	8	16
7341	780	3	12	3	36
7342	780	56	6	12	72
7361	783	311	3	30	90
7362	783	314	1	30	30
7370	784	1	1	2	2
7371	784	5	2	3	6
7372	784	6	2	3	6
7373	784	172	2	13	26
7374	784	57	1	9	9
7375	784	34	1	8	8
7376	784	63	1	9	9
7699	815	3	5	3	15
7700	815	5	1	3	3
7701	815	27	1	8	8
7702	815	51	1	8	8
7703	815	116	1	8	8
7704	815	137	1	8	8
7705	815	114	1	10	10
7706	815	96	1	8	8
7707	815	57	1	9	9
7760	818	1	1	2	2
7761	818	100	1	17	17
7762	818	157	1	17	17
7763	818	106	1	14	14
7764	818	120	1	18	18
7765	818	74	1	8	8
7766	818	56	1	12	12
7767	818	130	1	12	12
6420	663	1	1	2	2
6421	663	315	2	65	130
6422	663	290	2	55	110
6918	735	307	4	24	96
6926	713	1	1	2	2
6927	713	319	1	14	14
6426	664	105	1	13	13
6427	664	3	1	3	3
6428	664	120	4	18	72
6928	713	109	1	14	14
6929	713	44	1	8	8
6934	701	39	1	8	8
6935	701	51	1	8	8
6936	701	172	1	13	13
6941	715	37	1	8	8
6435	665	1	1	2	2
6436	665	73	1	8	8
6437	665	165	1	8	8
6438	665	167	2	8	16
6439	665	5	5	3	15
6440	665	303	1	13	13
6942	715	36	1	8	8
6943	715	5	100	3	300
28630	2468	149	2	13	26
28683	2451	3	5	3	15
8442	870	30	1	8	8
8443	870	151	1	17	17
8444	870	5	1	3	3
8445	870	55	1	8	8
8446	870	51	1	8	8
6450	667	1	1	2	2
6451	667	4	3	3	9
6452	667	5	1	3	3
6453	667	30	1	8	8
6454	667	104	1	13	13
20466	852	130	1	12	12
20467	852	1	2	2	4
6457	668	1	1	2	2
6458	668	4	10	3	30
8477	874	1	1	2	2
8478	874	3	5	3	15
28684	2451	52	1	8	8
28685	2451	63	1	9	9
8479	874	5	10	3	30
28686	2451	57	1	9	9
28687	2451	163	1	8	8
28688	2451	1	1	2	2
6478	671	1	1	2	2
6479	671	5	4	3	12
6480	671	145	2	8	16
6486	673	1	1	2	2
6487	673	5	20	3	60
6507	675	5	6	3	18
6508	675	4	4	3	12
6509	675	2	1	2	2
6526	676	333	1	8	8
6527	676	137	1	8	8
6528	676	95	1	8	8
6529	676	145	1	8	8
6530	676	52	1	8	8
6531	676	324	1	11	11
6532	676	30	1	8	8
6533	676	1	1	2	2
6537	678	1	1	2	2
6538	678	333	1	8	8
6539	678	137	1	8	8
6540	678	31	1	9	9
6541	678	52	1	8	8
6542	678	48	1	10	10
6545	680	4	15	3	45
6546	680	1	1	2	2
6555	682	1	1	2	2
6556	682	5	8	3	24
6557	682	64	2	13	26
6560	683	4	23	3	69
6561	683	1	1	2	2
6563	684	5	12	3	36
6567	685	5	8	3	24
6568	685	4	5	3	15
6569	685	1	1	2	2
6575	686	1	1	2	2
6576	686	130	1	12	12
6577	686	31	1	9	9
6578	686	99	1	12	12
6579	686	163	1	8	8
6583	687	4	10	3	30
6584	687	129	1	9	9
6585	687	1	1	2	2
6590	688	2	1	2	2
6591	688	91	5	8	40
6592	688	99	1	12	12
6593	688	149	6	13	78
6603	689	4	6	3	18
6604	689	1	2	2	4
6605	689	324	2	11	22
6606	689	163	2	8	16
6607	689	51	1	8	8
6608	689	52	1	8	8
6609	689	130	2	12	24
6610	689	318	2	12	24
6611	689	147	1	8	8
6621	631	1	1	2	2
6622	631	62	1	9	9
6623	631	64	1	13	13
6624	631	58	1	13	13
6625	631	56	2	12	24
6626	247	6	4	3	12
6627	247	4	5	3	15
6628	247	1	1	2	2
6629	677	1	1	2	2
6630	677	5	8	3	24
6631	633	1	1	2	2
6632	633	52	1	8	8
6633	633	149	1	13	13
6634	634	1	1	2	2
6635	634	5	15	3	45
6636	672	1	1	2	2
6637	672	5	6	3	18
6638	672	271	1	24	24
6639	605	5	5	3	15
6640	605	3	3	3	9
6641	635	1	1	2	2
6642	635	5	10	3	30
6643	635	32	1	8	8
6644	635	333	2	8	16
6645	635	335	1	5	5
6646	635	163	1	8	8
6647	635	167	1	8	8
6648	635	51	1	8	8
6649	635	145	1	8	8
6650	635	321	1	3	3
6651	635	116	1	8	8
6925	717	9	2	12	24
6937	722	105	1	13	13
6938	722	104	1	13	13
6939	722	319	1	14	14
6940	722	107	1	14	14
6959	177	282	2	34	68
6960	177	307	1	24	24
7010	168	311	2	30	60
7011	168	120	1	18	18
7012	168	282	1	34	34
8460	872	1	1	2	2
8461	872	5	9	3	27
10373	1028	1	1	2	2
10374	1028	5	6	3	18
10375	1028	3	2	3	6
17550	291	3	4	3	12
17551	291	120	2	18	36
20468	852	63	1	9	9
20469	852	52	1	8	8
20470	852	104	1	13	13
24210	971	1	1	2	2
24211	971	40	1	19	19
17562	1613	1	1	2	2
17563	1613	3	4	3	12
17564	1613	5	3	3	9
20471	852	56	1	12	12
20472	852	143	1	9	9
20473	1855	1	1	2	2
20474	1855	120	1	18	18
20475	1855	149	1	13	13
20476	1855	62	1	9	9
20477	1855	282	1	34	34
7125	754	132	1	17	17
7126	754	100	1	17	17
7127	753	311	3	30	90
7128	753	296	1	170	170
7134	745	5	10	3	30
7135	755	282	4	34	136
7136	755	303	1	13	13
7145	428	1	1	2	2
7146	428	3	4	3	12
7147	428	282	2	34	68
7148	428	283	1	7	7
28638	2469	2	1	2	2
7421	788	1	1	2	2
7422	788	112	1	41	41
7423	788	3	4	3	12
7424	788	55	1	8	8
7425	788	25	1	14	14
7426	788	35	1	17	17
7427	788	114	1	10	10
7428	788	150	1	11	11
20478	1855	284	1	11	11
24212	971	5	1	3	3
24213	971	32	1	8	8
24214	971	31	1	9	9
24215	971	57	1	9	9
7440	789	1	1	2	2
7441	789	168	1	15	15
7442	789	57	1	9	9
7443	789	28	1	12	12
7444	789	63	1	9	9
7445	789	56	1	12	12
7446	789	62	1	9	9
7447	789	51	1	8	8
7448	789	20	1	8	8
7449	789	33	1	11	11
7450	789	149	1	13	13
7550	798	1	2	2	4
7551	798	27	3	8	24
7552	798	120	3	18	54
7553	798	32	1	8	8
7554	798	149	2	13	26
7555	798	114	1	10	10
7556	798	106	2	14	28
7557	798	52	2	8	16
7558	798	2	1	2	2
7559	798	6	10	3	30
7598	805	116	2	8	16
7599	805	57	1	9	9
7653	810	1	1	2	2
7654	810	63	1	9	9
7655	810	145	1	8	8
7656	810	151	1	17	17
7657	810	28	2	12	24
7662	534	120	2	18	36
7663	534	56	1	12	12
7664	534	2	1	2	2
7665	812	307	2	24	48
7725	816	1	1	2	2
7726	816	114	1	10	10
7727	816	46	2	6	12
7728	816	5	10	3	30
7729	816	105	1	13	13
7730	816	104	1	13	13
7731	816	96	1	8	8
7732	816	120	1	18	18
7733	816	56	2	12	24
7734	816	35	1	17	17
7755	819	1	1	2	2
7756	819	3	5	3	15
7757	819	6	2	3	6
7758	819	5	2	3	6
7759	819	8	4	6	24
7775	820	1	1	2	2
7776	820	5	1	3	3
7777	820	3	1	3	3
7778	820	6	12	3	36
7779	820	46	1	6	6
7780	820	106	1	14	14
7781	820	319	1	14	14
7826	825	1	1	2	2
7827	825	149	3	13	39
7828	825	172	1	13	13
7829	825	114	1	10	10
7830	825	105	2	13	26
7831	825	46	1	6	6
7849	827	1	1	2	2
7850	827	9	5	12	60
7851	827	151	5	17	85
6652	632	1	2	2	4
6653	632	4	16	3	48
6654	656	1	1	2	2
6655	656	5	2	3	6
6656	656	4	19	3	57
6657	679	6	9	3	27
6658	679	130	1	12	12
6659	679	104	1	13	13
6660	681	4	5	3	15
6661	681	130	2	12	24
6662	681	30	1	8	8
6663	681	116	1	8	8
6664	681	2	1	2	2
6950	714	41	1	15	15
6951	714	339	1	9	9
6952	714	36	1	8	8
6668	691	2	1	2	2
6669	691	5	7	3	21
6670	691	147	1	8	8
6671	637	2	1	2	2
6672	637	5	7	3	21
28639	2469	6	1	3	3
6674	539	112	1	41	41
6953	719	1	1	2	2
6954	719	8	11	6	66
6955	719	7	3	6	18
6678	690	1	1	2	2
6679	690	4	5	3	15
6680	690	5	5	3	15
6956	719	9	1	12	12
6957	719	5	50	3	150
6958	719	16	30	20	600
28640	2469	3	1	3	3
8466	873	1	1	2	2
8467	873	5	10	3	30
6687	510	1	1	2	2
6688	510	5	3	3	9
6689	510	303	1	13	13
6690	510	278	1	18	18
6691	510	307	2	24	48
6692	510	311	1	30	30
6964	737	311	3	30	90
6965	737	307	1	24	24
6966	737	286	2	50	100
8468	873	104	1	13	13
8469	873	105	1	13	13
28641	2469	43	1	12	12
28642	2469	57	1	9	9
28643	2469	27	1	8	8
28644	2469	342	1	9	9
17572	1615	145	1	8	8
17573	1615	51	1	8	8
17574	1615	172	1	13	13
17575	1615	6	1	3	3
17605	1617	2	1	2	2
17606	1617	5	4	3	12
17607	1617	3	2	3	6
17608	1617	120	1	18	18
17609	1617	104	2	13	26
17637	1457	1	2	2	4
17638	1457	3	10	3	30
17639	1457	27	1	8	8
17640	1457	30	1	8	8
17641	1457	32	1	8	8
7114	750	1	1	2	2
7115	750	3	6	3	18
7116	750	151	2	17	34
7117	750	6	1	3	3
7118	750	110	1	9	9
7119	750	334	1	8	8
7120	750	31	1	9	9
7121	750	57	1	9	9
7122	750	96	1	8	8
7123	750	27	1	8	8
7124	750	341	1	9	9
17642	1457	334	1	8	8
17643	1457	130	2	12	24
17644	1457	161	1	8	8
7476	791	1	1	2	2
7477	791	5	9	3	27
7478	791	8	10	6	60
7498	794	5	15	3	45
7511	796	46	3	6	18
7520	795	2	1	2	2
7521	795	5	8	3	24
7522	795	8	3	6	18
7523	795	7	3	6	18
7524	795	335	3	5	15
7525	795	106	1	14	14
7526	795	58	1	13	13
7527	795	165	1	8	8
7528	795	52	1	8	8
7529	795	46	2	6	12
7530	795	116	1	8	8
7531	795	150	1	11	11
7587	803	2	1	2	2
7588	803	46	8	6	48
7589	803	335	3	5	15
7608	806	132	2	17	34
7609	806	1	1	2	2
7610	806	40	1	19	19
7611	806	52	1	8	8
7612	806	31	1	9	9
7613	806	151	1	17	17
7614	806	313	1	16	16
7615	806	278	1	18	18
7618	807	282	1	34	34
7619	807	292	2	50	100
7624	808	2	1	2	2
7625	808	335	4	5	20
7626	808	56	2	12	24
7627	808	129	1	9	9
7658	811	278	2	18	36
7735	817	1	1	2	2
7736	817	151	8	17	136
7737	817	150	2	11	22
7738	817	101	7	3	21
7739	817	63	1	9	9
7740	817	132	1	17	17
7741	817	186	1	30	30
10376	1028	30	1	8	8
10377	1028	114	1	10	10
10378	1028	96	1	8	8
10379	1028	165	1	8	8
10380	1028	24	1	8	8
10381	1028	145	1	8	8
17565	1613	120	1	18	18
20489	1857	1	1	2	2
20490	1857	24	1	8	8
20491	1857	3	2	3	6
7925	835	1	1	2	2
7926	835	58	2	13	26
7927	835	51	2	8	16
10382	213	1	1	2	2
10383	213	5	7	3	21
10384	213	3	3	3	9
10387	1029	1	1	2	2
10388	1029	5	30	3	90
20492	1857	44	2	8	16
20493	1857	57	2	9	18
17576	1614	74	3	8	24
15033	972	40	2	19	38
15034	972	1	1	2	2
17577	1614	172	1	13	13
17618	1619	4	2	3	6
17619	1619	5	1	3	3
8520	877	1	1	2	2
8521	877	3	5	3	15
8522	877	51	1	8	8
8523	877	57	1	9	9
8524	877	129	1	9	9
8541	881	3	5	3	15
8542	881	263	1	10	10
8543	880	113	1	25	25
8544	880	303	2	13	26
17620	1619	27	1	8	8
17621	1619	32	1	8	8
20494	1857	58	2	13	26
20495	1857	40	1	19	19
15043	1431	1	1	2	2
15044	1431	3	12	3	36
15045	1431	114	1	10	10
15046	1431	41	2	15	30
15047	1431	62	2	9	18
8625	888	1	1	2	2
8626	888	3	1	3	3
8627	888	335	1	5	5
8628	888	96	1	8	8
8629	888	116	1	8	8
8630	888	26	1	14	14
8631	888	58	1	13	13
8632	888	32	1	8	8
17719	1624	114	2	10	20
17720	1624	30	2	8	16
17721	1624	129	1	9	9
17722	1624	32	1	8	8
17723	1624	51	1	8	8
17724	1624	52	2	8	16
17725	1624	63	2	9	18
17726	1624	96	2	8	16
17727	1624	5	1	3	3
17728	1624	185	1	50	50
8796	897	2	1	2	2
8797	897	35	1	17	17
8798	897	148	2	17	34
8799	897	319	1	14	14
8800	897	120	1	18	18
8801	897	51	1	8	8
8802	897	52	1	8	8
8803	897	1	1	2	2
8804	897	335	4	5	20
8805	897	3	2	3	6
9145	921	1	1	2	2
9146	921	5	5	3	15
9147	921	32	1	8	8
9148	921	20	1	8	8
9149	921	57	1	9	9
9166	922	91	2	8	16
9167	922	341	1	9	9
9168	922	149	1	13	13
9169	922	129	1	9	9
9170	922	57	1	9	9
9171	922	114	1	10	10
9172	922	110	1	9	9
9173	922	51	1	8	8
9174	922	52	1	8	8
9175	922	245	1	9	9
9218	927	1	1	2	2
9219	927	91	1	8	8
9220	927	5	3	3	9
9221	927	3	4	3	12
9222	927	51	1	8	8
9223	927	52	1	8	8
9224	927	27	1	8	8
9225	927	103	1	31	31
9230	929	4	15	3	45
9231	929	113	1	25	25
9308	936	1	1	2	2
9309	936	5	7	3	21
9310	936	32	1	8	8
9311	936	51	1	8	8
9354	940	1	1	2	2
9355	940	4	3	3	9
9356	940	149	3	13	39
9357	940	58	2	13	26
9358	940	43	1	12	12
9359	940	109	1	14	14
9360	940	64	1	13	13
9361	940	119	1	31	31
9362	940	190	1	30	30
9377	941	32	1	8	8
9378	941	27	1	8	8
9379	941	57	1	9	9
9380	941	1	1	2	2
9381	941	63	1	9	9
9382	941	337	1	9	9
9422	946	5	11	3	33
9527	958	1	1	2	2
9528	958	5	4	3	12
7898	831	91	1	8	8
7899	831	242	1	8	8
7900	831	335	5	5	25
7901	831	5	3	3	9
7902	831	8	2	6	12
7903	831	27	1	8	8
7904	831	107	1	14	14
7905	831	25	1	14	14
7906	831	100	1	17	17
7907	831	30	1	8	8
7908	831	1	1	2	2
7928	834	2	1	2	2
7929	834	106	1	14	14
7930	834	7	1	6	6
7931	834	344	1	11	11
7932	834	116	2	8	16
7933	834	51	1	8	8
8480	874	57	1	9	9
8481	874	114	1	10	10
15048	1431	51	1	8	8
15049	1431	52	1	8	8
15050	1431	100	1	17	17
15057	1424	40	1	19	19
15058	1424	303	2	13	26
15059	1424	326	1	13	13
17613	1618	113	1	25	25
20496	1857	56	1	12	12
8482	874	150	1	11	11
8483	874	100	1	17	17
20497	1857	96	1	8	8
20498	1857	52	1	8	8
10425	1034	1	1	2	2
10426	1034	5	12	3	36
24216	971	63	1	9	9
8532	878	1	1	2	2
8533	878	5	11	3	33
10450	1035	1	1	2	2
10451	1035	5	2	3	6
10452	1035	4	2	3	6
10453	1035	57	1	9	9
10454	1035	116	1	8	8
10455	1035	157	1	17	17
10456	1035	52	1	8	8
8908	905	1	1	2	2
8909	905	335	4	5	20
10457	1035	193	1	22	22
10458	489	1	1	2	2
10459	489	3	11	3	33
10460	489	30	1	8	8
10461	489	110	1	9	9
10462	489	57	1	9	9
8951	909	1	1	2	2
8952	909	120	1	18	18
8953	909	114	1	10	10
8954	909	61	1	8	8
8955	909	30	1	8	8
8956	909	324	1	11	11
8957	909	57	1	9	9
8958	909	51	2	8	16
8969	875	3	3	3	9
8970	875	5	1	3	3
8971	875	91	2	8	16
8972	790	1	1	2	2
8973	790	3	10	3	30
8986	910	1	1	2	2
8987	910	149	1	13	13
8988	910	58	1	13	13
8989	910	62	1	9	9
8990	910	63	1	9	9
8991	910	52	1	8	8
8992	910	27	1	8	8
8993	910	137	1	8	8
8994	910	242	1	8	8
8995	910	116	1	8	8
9026	913	129	1	9	9
9027	913	31	1	9	9
9028	913	20	2	8	16
9029	913	51	1	8	8
9030	913	43	1	12	12
9031	913	30	1	8	8
9107	919	95	1	8	8
9108	919	24	1	8	8
9109	919	1	1	2	2
9118	569	2	1	2	2
9119	569	335	2	5	10
9120	569	52	1	8	8
9121	569	51	1	8	8
9122	569	62	1	9	9
9123	569	157	1	17	17
9124	569	150	1	11	11
9125	569	342	1	9	9
9198	923	110	1	9	9
9199	923	96	1	8	8
9200	925	5	4	3	12
9201	925	43	1	12	12
9202	925	58	1	13	13
9203	925	41	1	15	15
9204	925	114	1	10	10
9205	925	56	1	12	12
9206	925	151	1	17	17
9207	925	318	1	12	12
9227	928	113	2	25	50
9234	930	5	4	3	12
9235	930	1	1	2	2
9302	935	1	1	2	2
9303	935	5	7	3	21
9322	937	1	1	2	2
9323	937	5	2	3	6
9324	937	63	2	9	18
9325	937	75	1	12	12
9326	937	319	1	14	14
9327	937	149	1	13	13
9328	937	114	1	10	10
9329	937	58	1	13	13
9330	937	36	1	8	8
9331	937	26	1	14	14
9342	939	149	2	13	26
9343	939	20	1	8	8
9344	939	116	1	8	8
9345	939	213	1	8	8
9375	941	5	3	3	9
9376	941	3	2	3	6
24217	971	51	1	8	8
7934	833	1	1	2	2
7935	833	5	6	3	18
7939	836	109	1	14	14
7940	836	151	1	17	17
7941	836	282	1	34	34
24231	2159	3	15	3	45
24232	2159	1	1	2	2
20508	1858	1	1	2	2
20509	1858	44	1	8	8
7948	837	1	1	2	2
7949	837	153	1	17	17
7950	837	148	1	17	17
7951	837	95	1	8	8
7952	837	71	1	8	8
7953	837	266	1	36	36
20510	1858	27	2	8	16
20511	1858	149	3	13	39
20512	1858	20	2	8	16
20513	1858	62	1	9	9
20514	1858	63	1	9	9
20515	1858	39	1	8	8
20516	1858	143	1	9	9
20536	281	1	1	2	2
20537	281	40	2	19	38
20538	281	30	1	8	8
20539	281	32	1	8	8
7992	839	1	1	2	2
7993	839	3	8	3	24
7994	839	25	1	14	14
7995	839	151	1	17	17
7996	839	43	1	12	12
7997	839	130	1	12	12
7998	839	120	1	18	18
7999	840	1	1	2	2
8000	840	40	2	19	38
8001	840	5	8	3	24
8002	840	27	2	8	16
8003	840	163	1	8	8
8004	840	129	1	9	9
8005	840	319	1	14	14
8006	840	109	1	14	14
8007	840	91	1	8	8
8008	840	263	1	10	10
8009	840	303	1	13	13
20540	281	5	4	3	12
8011	841	149	2	13	26
20541	281	57	1	9	9
20542	281	58	1	13	13
24265	107	344	1	11	11
24266	107	132	1	17	17
8016	842	1	1	2	2
8017	842	5	5	3	15
8018	842	32	2	8	16
8019	842	30	1	8	8
24269	2162	1	1	2	2
24270	2162	149	4	13	52
24273	2163	1	1	2	2
24274	2163	3	5	3	15
28674	2470	1	1	2	2
28675	2470	5	2	3	6
28676	2470	75	2	12	24
28677	2470	31	1	9	9
28678	2470	149	1	13	13
28679	2470	100	1	17	17
28680	2470	342	1	9	9
28681	2471	1	1	2	2
8033	844	51	1	8	8
8034	844	62	1	9	9
8035	844	27	1	8	8
8036	844	105	1	13	13
8037	844	1	1	2	2
8048	845	1	1	2	2
8049	845	5	10	3	30
8050	845	138	2	8	16
8051	845	32	2	8	16
8052	845	116	1	8	8
8053	845	57	1	9	9
8054	845	33	1	11	11
8055	845	165	2	8	16
8056	845	51	1	8	8
8057	845	52	1	8	8
8077	847	39	1	8	8
8078	847	57	1	9	9
8079	847	138	1	8	8
8089	848	1	1	2	2
8090	848	185	1	50	50
8091	848	5	5	3	15
8092	848	335	2	5	10
8093	848	58	1	13	13
8094	848	52	2	8	16
8095	848	278	1	18	18
8096	848	189	2	30	60
8097	848	117	1	24	24
8120	850	5	8	3	24
8121	850	32	1	8	8
8122	850	33	2	11	22
8123	850	120	1	18	18
8124	850	27	1	8	8
8125	850	56	2	12	24
8126	850	143	1	9	9
8127	850	311	3	30	90
8128	698	1	1	2	2
8129	698	5	15	3	45
8139	851	120	1	18	18
8140	851	3	3	3	9
8141	851	5	6	3	18
8142	851	46	4	6	24
8143	851	129	1	9	9
8144	851	41	1	15	15
8145	851	62	1	9	9
8146	851	64	1	13	13
8147	851	116	1	8	8
8151	599	5	4	3	12
8152	599	1	1	2	2
8153	599	335	2	5	10
8193	853	5	16	3	48
8194	853	3	19	3	57
8195	853	46	5	6	30
8196	853	149	1	13	13
8197	853	314	1	30	30
8198	832	1	1	2	2
8199	832	107	1	14	14
8200	832	335	1	5	5
28664	318	1	3	2	6
28665	318	3	16	3	48
28666	318	57	3	9	27
28667	318	51	4	8	32
28668	318	26	1	14	14
28669	318	58	2	13	26
28670	318	9	1	12	12
28671	318	96	1	8	8
28672	318	25	1	14	14
12528	1215	3	2	3	6
12529	1215	58	2	13	26
12530	1215	46	1	6	6
28673	318	307	2	24	48
8216	855	1	1	2	2
8217	855	41	1	15	15
8218	855	3	2	3	6
8219	855	20	1	8	8
8220	855	129	1	9	9
8221	855	63	1	9	9
8222	855	56	1	12	12
8223	855	28	1	12	12
8224	855	159	1	17	17
8225	855	64	1	13	13
8226	855	51	1	8	8
8227	855	242	1	8	8
8228	855	110	1	9	9
8237	856	1	1	2	2
8238	856	3	11	3	33
8239	856	149	2	13	26
8240	856	109	2	14	28
8241	856	58	1	13	13
8242	856	56	2	12	24
8243	856	28	1	12	12
8244	856	151	2	17	34
8961	866	303	6	13	78
8962	866	307	2	24	48
8968	802	337	1	9	9
9013	912	118	2	8	16
9014	912	1	1	2	2
9015	912	151	1	17	17
9016	912	334	1	8	8
9017	912	65	1	8	8
9018	912	116	1	8	8
9019	912	157	2	17	34
9061	916	1	1	2	2
9062	916	51	1	8	8
9063	916	52	1	8	8
9064	916	32	1	8	8
9065	916	58	1	13	13
9066	916	142	2	9	18
9067	916	143	2	9	18
9068	916	165	1	8	8
9069	916	20	1	8	8
9097	918	1	1	2	2
9098	918	46	3	6	18
9099	918	112	1	41	41
9100	918	3	1	3	3
9101	918	100	1	17	17
9102	918	335	1	5	5
9103	918	74	1	8	8
9259	932	2	1	2	2
9260	932	5	3	3	9
9261	932	4	2	3	6
9262	932	149	1	13	13
9263	932	337	1	9	9
9264	932	101	2	3	6
9265	932	319	1	14	14
9266	932	112	1	41	41
9267	932	67	1	31	31
9276	933	1	1	2	2
9277	933	3	14	3	42
9278	933	5	3	3	9
9279	933	57	2	9	18
9280	933	32	1	8	8
9281	933	96	1	8	8
9282	933	52	1	8	8
9283	933	63	1	9	9
9292	934	1	1	2	2
9293	934	5	5	3	15
9294	934	52	1	8	8
9295	934	20	1	8	8
9296	934	116	1	8	8
9297	934	96	1	8	8
9298	934	63	1	9	9
9299	934	31	1	9	9
9335	938	1	1	2	2
9336	938	5	9	3	27
9337	938	264	1	10	10
9387	917	1	1	2	2
9388	917	5	4	3	12
9389	917	165	2	8	16
9390	917	63	1	9	9
9402	944	1	1	2	2
9403	944	5	1	3	3
9404	944	100	2	17	34
9426	947	4	4	3	12
9427	947	5	12	3	36
9428	947	1	1	2	2
9433	948	1	1	2	2
9434	948	5	5	3	15
9435	948	3	4	3	12
9436	948	149	3	13	39
9460	951	5	6	3	18
9461	951	20	1	8	8
9462	951	51	1	8	8
9463	951	110	1	9	9
9464	951	96	1	8	8
9465	951	341	1	9	9
9466	951	57	1	9	9
9470	952	1	1	2	2
9471	952	5	13	3	39
9472	952	6	10	3	30
9485	955	6	5	3	15
9486	955	101	1	3	3
9487	955	116	1	8	8
9488	955	149	1	13	13
9489	955	100	1	17	17
28682	2471	6	10	3	30
12553	1224	57	2	9	18
12554	1224	116	2	8	16
24252	2161	1	1	2	2
8250	857	3	3	3	9
8251	857	5	3	3	9
8252	857	96	1	8	8
8253	857	58	1	13	13
8254	857	110	1	9	9
24253	2161	32	1	8	8
10411	1032	4	6	3	18
10412	1032	101	4	3	12
15098	1436	1	1	2	2
15099	1436	5	11	3	33
15112	1438	3	4	3	12
15113	1438	5	4	3	12
8589	885	1	1	2	2
8590	885	3	3	3	9
8591	886	5	2	3	6
8592	886	3	1	3	3
8593	886	334	2	8	16
8594	886	20	1	8	8
15114	1438	57	3	9	27
15115	1438	52	1	8	8
15116	1438	116	1	8	8
15117	1438	145	1	8	8
15118	1438	46	1	6	6
24254	2161	57	1	9	9
8603	887	1	2	2	4
8604	887	145	1	8	8
8605	887	110	1	9	9
8606	887	150	1	11	11
8607	887	101	2	3	6
8608	887	335	2	5	10
8609	887	3	8	3	24
8610	887	5	2	3	6
8705	893	1	1	2	2
8706	893	5	1	3	3
8707	893	57	4	9	36
8708	893	114	1	10	10
8709	893	339	1	9	9
8710	893	41	1	15	15
8711	893	20	1	8	8
8712	893	74	2	8	16
8713	893	65	1	8	8
8714	893	63	1	9	9
8715	893	56	1	12	12
8716	893	313	1	16	16
10868	1075	278	3	18	54
8734	894	1	1	2	2
8735	894	9	2	12	24
8736	894	5	2	3	6
8737	894	96	2	8	16
8738	894	129	1	9	9
8739	894	150	1	11	11
8740	894	159	1	17	17
8741	894	99	1	12	12
8742	894	342	1	9	9
8743	894	33	1	11	11
8744	894	101	4	3	12
8806	898	1	1	2	2
8807	898	3	3	3	9
8808	898	335	1	5	5
8809	898	163	2	8	16
8810	898	57	2	9	18
8811	898	58	1	13	13
8812	898	149	1	13	13
8835	900	1	1	2	2
8836	900	120	2	18	36
8837	900	36	2	8	16
8838	900	63	2	9	18
8839	900	148	1	17	17
8840	900	58	3	13	39
8841	900	57	1	9	9
8842	900	64	1	13	13
8853	902	315	2	65	130
8861	565	1	1	2	2
8862	565	103	1	31	31
8863	565	116	1	8	8
8864	565	51	1	8	8
8865	565	31	1	9	9
8866	565	30	1	8	8
8867	565	56	1	12	12
8868	901	2	1	2	2
8869	901	100	1	17	17
8870	901	58	1	13	13
8871	901	57	1	9	9
8872	901	64	1	13	13
8873	901	52	2	8	16
8874	901	51	1	8	8
8875	901	27	1	8	8
8876	901	20	1	8	8
8877	901	116	1	8	8
8938	908	1	1	2	2
8939	908	51	1	8	8
8940	908	57	2	9	18
8941	908	63	1	9	9
8942	908	319	1	14	14
8974	757	1	1	2	2
8975	757	6	9	3	27
9036	914	1	1	2	2
9037	914	114	1	10	10
9038	914	32	1	8	8
9039	914	36	2	8	16
9046	915	1	1	2	2
9047	915	335	4	5	20
9048	915	56	2	12	24
9049	915	116	1	8	8
9050	915	101	6	3	18
9051	915	314	1	30	30
9133	920	5	2	3	6
9134	920	3	2	3	6
9135	920	57	1	9	9
9136	920	27	1	8	8
9137	920	52	1	8	8
9138	920	36	1	8	8
9139	920	114	1	10	10
9178	607	4	8	3	24
9179	607	6	4	3	12
9243	931	2	1	2	2
9244	931	30	1	8	8
9245	931	57	1	9	9
9246	931	32	1	8	8
9247	931	104	1	13	13
9248	931	56	1	12	12
9249	931	51	1	8	8
10405	1031	31	1	9	9
10406	1031	343	1	11	11
8257	858	104	2	13	26
8258	858	1	1	2	2
10407	1031	150	1	11	11
10408	1031	245	1	9	9
20600	1862	2	1	2	2
20601	1862	43	1	12	12
20602	1862	63	1	9	9
20603	1862	34	1	8	8
20604	1862	7	3	6	18
15075	1434	2	1	2	2
15076	1434	3	7	3	21
12544	1223	2	1	2	2
12545	1223	40	2	19	38
12546	1223	9	1	12	12
12547	1223	130	1	12	12
15077	1434	149	2	13	26
15078	1434	191	1	30	30
8586	884	1	1	2	2
8587	884	3	10	3	30
8588	884	185	1	50	50
17645	1457	163	1	8	8
17646	1457	96	1	8	8
17647	1457	63	1	9	9
17648	1457	75	1	12	12
17649	1457	51	1	8	8
17650	1457	52	1	8	8
8619	889	1	1	2	2
8620	889	149	2	13	26
8621	889	142	1	9	9
8622	889	57	1	9	9
8623	889	278	2	18	36
8624	889	303	4	13	52
8644	890	1	1	2	2
8645	890	5	5	3	15
8646	890	33	4	11	44
8647	890	32	1	8	8
8648	890	57	1	9	9
8649	890	43	1	12	12
8650	890	150	1	11	11
8301	570	1	2	2	4
8302	570	43	1	12	12
8303	570	57	1	9	9
8304	570	20	1	8	8
8305	570	96	1	8	8
8306	570	32	1	8	8
8307	570	31	1	9	9
8308	570	52	1	8	8
8309	570	63	1	9	9
8310	570	71	2	8	16
8311	570	265	1	70	70
8651	890	109	1	14	14
8652	890	36	1	8	8
8653	890	52	1	8	8
8654	890	165	1	8	8
17651	1457	114	1	10	10
28711	2472	1	1	2	2
28712	2472	5	6	3	18
24331	1271	1	1	2	2
24332	1271	114	1	10	10
24333	1271	118	1	8	8
24334	1271	334	1	8	8
24335	1271	145	1	8	8
24336	1271	165	1	8	8
8682	892	3	8	3	24
8683	892	32	1	8	8
8684	892	96	1	8	8
8685	892	52	1	8	8
8686	892	57	1	9	9
8687	892	110	1	9	9
8688	892	25	1	14	14
8689	892	58	1	13	13
8690	892	114	1	10	10
8691	892	129	1	9	9
8692	892	1	1	2	2
24422	2168	1	1	2	2
24423	2168	3	10	3	30
8745	895	1	1	2	2
8746	895	43	1	12	12
8747	895	96	1	8	8
8748	895	335	1	5	5
8749	895	343	1	11	11
8750	895	56	1	12	12
24441	2173	1	1	2	2
24442	2173	5	2	3	6
24443	2173	96	2	8	16
24444	2173	57	3	9	27
8774	560	1	1	2	2
8775	560	3	2	3	6
8776	560	149	2	13	26
8777	560	75	1	12	12
8778	560	339	1	9	9
20927	1883	1	1	2	2
20928	1883	335	6	5	30
20929	1883	5	1	3	3
9183	924	1	1	2	2
9184	924	5	10	3	30
9185	924	27	1	8	8
9194	923	113	1	25	25
9195	923	3	3	3	9
9196	923	5	2	3	6
9197	923	163	1	8	8
24255	2161	114	1	10	10
24256	2161	172	1	13	13
24257	2161	52	1	8	8
15079	1434	113	1	25	25
24258	2161	116	1	8	8
9539	956	1	1	2	2
9540	956	5	4	3	12
9541	956	213	3	8	24
9542	956	32	1	8	8
9543	956	27	1	8	8
9544	956	30	1	8	8
9545	956	129	1	9	9
9546	956	43	1	12	12
9547	956	62	1	9	9
9548	956	114	1	10	10
10875	1079	296	1	170	170
10876	1079	297	3	3	9
10877	1079	307	1	24	24
10889	618	1	1	2	2
10890	618	32	1	8	8
10891	618	57	3	9	27
9591	962	1	1	2	2
9592	962	3	6	3	18
9593	962	5	4	3	12
9594	962	96	2	8	16
9595	962	51	1	8	8
9596	962	43	1	12	12
9597	962	57	1	9	9
9610	965	1	1	2	2
9611	965	6	6	3	18
9612	965	149	1	13	13
9613	965	105	1	13	13
9614	965	64	1	13	13
9615	965	257	1	3	3
9639	969	6	2	3	6
9640	969	1	1	2	2
9641	969	24	1	8	8
9642	969	32	1	8	8
9643	969	56	3	12	36
9644	969	52	2	8	16
9645	969	62	2	9	18
10892	618	36	1	8	8
10893	618	52	1	8	8
10894	618	56	1	12	12
10895	618	334	1	8	8
10896	618	145	1	8	8
10897	618	172	1	13	13
10898	618	165	1	8	8
10940	1084	282	3	34	102
10941	1084	314	2	30	60
10942	1084	276	2	120	240
10951	1087	2	1	2	2
10952	1087	4	8	3	24
10953	1087	311	3	30	90
10972	1091	6	8	3	24
10973	1091	294	1	55	55
10974	1091	1	1	2	2
10981	1093	148	2	17	34
10982	1093	149	3	13	39
10983	1093	101	1	3	3
10984	1093	116	1	8	8
10985	1093	74	1	8	8
10986	1093	2	1	2	2
10987	1093	303	1	13	13
10988	1093	311	1	30	30
10989	1093	278	3	18	54
10993	416	307	2	24	48
10994	416	303	1	13	13
10995	416	278	2	18	36
11019	388	1	1	2	2
11020	388	3	6	3	18
11021	388	5	4	3	12
11022	388	44	1	8	8
11023	388	213	2	8	16
11024	388	25	1	14	14
11025	388	62	1	9	9
11026	388	131	2	22	44
11062	1101	295	1	85	85
11063	1101	297	2	3	6
11064	1101	131	1	22	22
11065	1101	315	1	65	65
11081	695	307	4	24	96
11082	695	311	1	30	30
11083	695	303	1	13	13
11086	1096	278	2	18	36
11087	1096	311	1	30	30
11163	1108	311	2	30	60
11164	1108	307	2	24	48
11165	1108	303	2	13	26
11166	1108	282	1	34	34
11167	1108	56	3	12	36
11168	1108	46	2	6	12
11169	1108	2	1	2	2
11173	1109	1	1	2	2
11174	1109	46	3	6	18
11175	1109	6	6	3	18
11183	1110	1	1	2	2
11184	1110	32	2	8	16
11185	1110	57	2	9	18
11186	1110	96	3	8	24
11187	1110	74	3	8	24
11188	1110	51	2	8	16
11189	1110	63	2	9	18
11196	1111	2	1	2	2
11197	1111	58	1	13	13
11198	1111	56	2	12	24
11199	1111	46	4	6	24
11200	1111	25	1	14	14
11201	1111	311	2	30	60
11352	1127	51	1	8	8
11353	1127	52	1	8	8
11354	1127	116	1	8	8
11444	172	1	1	2	2
11445	172	6	15	3	45
11446	172	27	2	8	16
11447	172	30	1	8	8
11448	172	57	1	9	9
11449	172	36	1	8	8
11450	172	51	1	8	8
11451	172	96	1	8	8
11452	172	335	2	5	10
11502	1138	91	3	8	24
11503	1138	24	1	8	8
9517	957	1	1	2	2
9518	957	5	5	3	15
9519	957	43	1	12	12
9520	957	72	1	8	8
10469	1036	1	1	2	2
10470	1036	5	8	3	24
10471	1036	110	1	9	9
10472	1036	51	1	8	8
10473	1036	96	1	8	8
10474	1036	339	1	9	9
24259	2161	150	1	11	11
15082	96	1	1	2	2
15083	96	3	5	3	15
15084	96	63	1	9	9
12558	418	1	1	2	2
9568	669	4	5	3	15
9569	669	5	5	3	15
9570	669	149	1	13	13
12559	418	3	5	3	15
10888	1080	282	4	34	136
15085	1256	5	5	3	15
15086	1256	344	1	11	11
15087	1256	2	1	2	2
9583	963	1	1	2	2
9584	963	5	8	3	24
9585	963	107	1	14	14
9586	963	52	3	8	24
9587	963	114	1	10	10
9598	964	5	13	3	39
9599	964	1	1	2	2
9600	964	4	20	3	60
24260	2155	1	1	2	2
24261	2155	7	2	6	12
24262	2155	35	1	17	17
9616	966	1	1	2	2
9617	966	5	16	3	48
9618	966	24	1	8	8
9649	968	1	1	2	2
9650	968	4	6	3	18
9651	968	105	1	13	13
9652	968	104	1	13	13
9653	968	120	2	18	36
9654	968	62	1	9	9
9655	968	64	1	13	13
10914	1082	1	1	2	2
10915	1082	4	5	3	15
10916	1082	114	2	10	20
10917	1082	118	1	8	8
10918	1082	32	1	8	8
10919	1082	31	1	9	9
10920	1082	36	1	8	8
10921	1082	61	1	8	8
10922	1082	73	2	8	16
10923	1082	65	1	8	8
10924	1082	96	1	8	8
10925	1082	76	1	36	36
10947	1086	282	1	34	34
10948	1086	313	2	16	32
10949	1086	311	2	30	60
10950	1086	307	2	24	48
10954	1088	303	9	13	117
28720	2021	1	1	2	2
28721	2021	6	10	3	30
28722	2021	27	2	8	16
28723	2021	32	2	8	16
11009	1097	282	5	34	170
11010	1097	303	1	13	13
11085	1094	303	3	13	39
11098	1103	135	2	99	198
11099	1103	131	5	22	110
11100	1103	132	1	17	17
11101	1104	291	2	30	60
11102	1104	313	1	16	16
11103	1104	135	1	99	99
11113	1105	1	1	2	2
11114	1105	4	12	3	36
11115	1105	136	1	8	8
11116	1105	172	1	13	13
11117	1105	46	6	6	36
11118	1105	56	1	12	12
11119	1105	101	2	3	6
11120	1105	40	3	19	57
11121	1105	190	1	30	30
11139	1106	1	1	2	2
11140	1106	4	2	3	6
11141	1106	333	1	8	8
11142	1106	163	1	8	8
11143	1106	31	1	9	9
11144	1106	334	1	8	8
11145	1106	109	1	14	14
11482	1137	1	1	2	2
11483	1137	5	6	3	18
11484	1137	6	5	3	15
11485	1137	7	1	6	6
11486	1137	151	1	17	17
11487	1137	131	1	22	22
11488	1137	132	1	17	17
11489	1137	113	1	25	25
11497	1139	1	1	2	2
11498	1139	6	12	3	36
11499	1139	51	1	8	8
11500	1139	52	2	8	16
11501	1139	172	2	13	26
11546	1145	1	1	2	2
11547	1145	5	8	3	24
11548	1145	6	2	3	6
11549	1145	335	4	5	20
11550	1145	119	1	31	31
11569	1148	1	1	2	2
11570	1148	6	9	3	27
11571	1148	57	2	9	18
11572	1148	341	1	9	9
11573	1148	96	1	8	8
11574	1148	24	1	8	8
9529	958	172	2	13	26
9530	958	334	1	8	8
9531	958	34	2	8	16
9532	958	145	1	8	8
9533	958	56	2	12	24
28713	2472	8	5	6	30
28714	2472	43	1	12	12
28715	2472	58	1	13	13
15094	1435	5	1	3	3
15095	1435	105	1	13	13
28716	2472	57	1	9	9
9563	960	1	1	2	2
9564	960	4	15	3	45
9565	960	213	1	8	8
9566	960	32	1	8	8
9567	960	190	1	30	30
28717	2472	63	1	9	9
28718	2472	52	1	8	8
12573	1226	1	1	2	2
12574	1226	4	12	3	36
12575	1226	61	1	8	8
17664	1056	1	1	2	2
10481	1037	1	1	2	2
10482	1037	114	1	10	10
10483	1037	118	1	8	8
10484	1037	35	1	17	17
10485	1037	62	1	9	9
10486	1037	145	1	8	8
17665	1056	3	3	3	9
17666	1056	335	1	5	5
17667	1056	339	1	9	9
17668	1056	96	1	8	8
17669	1056	143	1	9	9
17670	1056	260	1	16	16
17671	1620	5	4	3	12
10494	1038	1	1	2	2
10495	1038	4	7	3	21
10496	1038	24	1	8	8
10497	1038	52	2	8	16
10498	1038	5	2	3	6
10499	1038	57	1	9	9
10500	1038	36	1	8	8
10504	1039	2	1	2	2
10505	1039	5	10	3	30
10506	1039	117	1	24	24
17672	1620	1	1	2	2
17673	1620	114	2	10	20
17674	1620	96	1	8	8
28719	2472	28	1	12	12
10511	1040	58	1	13	13
10512	1040	56	1	12	12
10513	1040	52	1	8	8
10514	1040	172	1	13	13
28808	655	1	1	2	2
28809	655	3	3	3	9
10528	1043	1	1	2	2
10529	1043	32	1	8	8
10530	1043	57	1	9	9
10531	1043	341	1	9	9
10532	1043	136	1	8	8
10533	1043	110	1	9	9
10534	1043	333	1	8	8
28810	655	56	1	12	12
28811	655	51	1	8	8
24286	720	1	1	2	2
24287	720	40	1	19	19
24288	720	6	10	3	30
24289	720	8	3	6	18
24290	720	149	1	13	13
24291	720	57	1	9	9
24292	720	51	1	8	8
10589	1049	1	1	2	2
10590	1049	5	6	3	18
10591	1049	114	1	10	10
10592	1049	31	1	9	9
10593	1049	96	1	8	8
10594	1049	146	1	9	9
10595	1050	1	1	2	2
10596	1050	6	2	3	6
10657	1055	1	1	2	2
10658	1055	5	10	3	30
10662	1057	1	1	2	2
10663	1057	5	6	3	18
10664	1057	3	2	3	6
10665	1058	1	1	2	2
10666	1058	5	3	3	9
10667	1058	44	2	8	16
10668	1058	165	1	8	8
10669	1058	172	1	13	13
10670	1058	56	1	12	12
10671	1058	62	1	9	9
9838	982	1	2	2	4
9839	982	5	10	3	30
9840	982	91	1	8	8
9841	982	63	1	9	9
9842	982	64	1	13	13
9843	982	129	1	9	9
9844	982	157	1	17	17
9845	982	52	1	8	8
9857	540	1	1	2	2
9858	540	5	8	3	24
9859	540	3	2	3	6
9860	967	1	1	2	2
9861	967	5	9	3	27
9862	967	341	1	9	9
9863	967	62	1	9	9
9864	967	64	1	13	13
9865	967	96	2	8	16
9870	974	1	1	2	2
9871	974	5	5	3	15
9872	974	32	1	8	8
9873	974	52	1	8	8
9874	974	31	2	9	18
9875	974	43	1	12	12
9876	974	36	1	8	8
9877	974	114	1	10	10
9878	974	334	1	8	8
9879	974	130	1	12	12
9880	974	56	2	12	24
9881	979	1	1	2	2
9882	979	5	8	3	24
9883	979	52	1	8	8
9884	979	51	1	8	8
9885	979	148	1	17	17
9886	979	75	1	12	12
9887	979	31	1	9	9
10702	1060	1	1	2	2
10703	1060	6	10	3	30
10704	1060	114	3	10	30
10705	1060	36	1	8	8
9888	979	57	1	9	9
9900	989	1	1	2	2
9901	989	4	7	3	21
9902	989	5	4	3	12
9903	989	32	1	8	8
9904	989	35	1	17	17
9905	989	36	1	8	8
9906	989	114	1	10	10
9907	991	1	1	2	2
9908	991	5	11	3	33
9909	992	1	2	2	4
9910	992	5	10	3	30
9911	994	4	7	3	21
9912	994	1	1	2	2
9913	994	52	1	8	8
9914	994	51	1	8	8
9915	994	32	1	8	8
24293	720	26	1	14	14
24294	720	120	1	18	18
9922	996	1	1	2	2
9923	996	52	1	8	8
9924	996	57	2	9	18
9925	996	116	2	8	16
9926	996	145	1	8	8
9927	983	2	1	2	2
9928	983	3	10	3	30
9929	983	148	1	17	17
9930	983	260	1	16	16
9931	485	2	1	2	2
9932	485	5	2	3	6
9933	485	3	1	3	3
9934	485	52	3	8	24
9935	976	1	1	2	2
9936	976	4	10	3	30
9959	997	1	1	2	2
9960	997	5	6	3	18
9961	997	4	2	3	6
9962	997	57	2	9	18
9963	997	51	2	8	16
9964	997	52	1	8	8
9965	953	9	1	12	12
9966	993	1	1	2	2
9967	993	4	6	3	18
9968	993	27	1	8	8
9969	993	32	1	8	8
9970	993	57	1	9	9
9971	993	51	1	8	8
9972	993	62	1	9	9
9982	998	1	1	2	2
9983	998	5	2	3	6
9984	998	157	1	17	17
24295	720	56	1	12	12
24296	720	278	1	18	18
24350	723	1	1	2	2
24351	723	114	1	10	10
24352	723	5	5	3	15
10031	987	1	1	2	2
10032	987	5	2	3	6
10033	987	3	6	3	18
10034	987	32	1	8	8
10035	987	27	1	8	8
10036	987	114	1	10	10
10037	987	51	1	8	8
10038	987	63	1	9	9
10039	987	64	1	13	13
10040	987	57	1	9	9
10042	975	1	1	2	2
10043	975	5	13	3	39
10044	975	4	2	3	6
10045	975	63	3	9	27
10046	975	114	1	10	10
10047	975	172	1	13	13
24353	723	3	10	3	30
24354	723	129	1	9	9
24355	723	70	1	8	8
24356	723	52	1	8	8
24357	723	51	1	8	8
10526	1042	1	2	2	4
10527	1042	4	6	3	18
24358	723	46	2	6	12
10578	1048	1	1	2	2
10579	1048	3	3	3	9
10580	1048	20	2	8	16
10581	1048	32	1	8	8
10582	1048	159	1	17	17
10617	1051	1	1	2	2
10618	1051	5	7	3	21
10711	1061	1	1	2	2
10712	1061	5	7	3	21
10713	1061	56	2	12	24
10725	1062	307	1	24	24
10726	1062	311	1	30	30
10727	1062	315	3	65	195
10737	1064	1	1	2	2
10738	1064	5	2	3	6
10739	1064	62	1	9	9
10740	1064	149	2	13	26
10785	1045	2	1	2	2
10786	1045	57	1	9	9
10787	1045	116	1	8	8
10788	1045	20	1	8	8
10789	1045	70	1	8	8
10790	1045	30	1	8	8
10791	1045	36	2	8	16
10792	1045	114	1	10	10
10793	1045	32	1	8	8
10794	1045	65	1	8	8
10828	1073	2	1	2	2
10829	1073	6	3	3	9
10830	1073	109	1	14	14
11243	1114	1	1	2	2
11244	1114	5	4	3	12
11245	1114	3	2	3	6
11246	1114	46	1	6	6
11247	1114	96	1	8	8
11248	1114	95	1	8	8
11249	1114	56	1	12	12
11268	1117	295	1	85	85
11269	1117	307	3	24	72
11270	1117	311	4	30	120
11278	1119	1	1	2	2
10516	1041	5	10	3	30
10545	1044	1	1	2	2
10546	1044	6	7	3	21
9896	1000	1	1	2	2
9897	1000	5	6	3	18
9898	1000	3	6	3	18
10547	1044	32	1	8	8
10548	1044	58	1	13	13
10549	1044	56	1	12	12
10550	1044	116	1	8	8
10551	1044	109	1	14	14
10552	1044	99	1	12	12
10553	1044	101	2	3	6
9944	973	1	1	2	2
9945	973	333	2	8	16
9946	973	91	1	8	8
9947	973	43	1	12	12
9948	973	145	1	8	8
9949	973	100	1	17	17
9950	973	51	1	8	8
9951	973	52	1	8	8
15103	1429	3	6	3	18
15104	1429	6	6	3	18
17675	1620	163	1	8	8
12576	1227	3	4	3	12
12577	1227	5	3	3	9
10020	961	1	1	2	2
10021	961	5	3	3	9
10022	961	6	10	3	30
10023	961	7	11	6	66
10024	961	9	14	12	168
10027	990	5	7	3	21
10028	990	62	1	9	9
10029	990	63	1	9	9
10030	990	129	1	9	9
10041	985	3	3	3	9
10554	1044	190	1	30	30
17689	903	1	1	2	2
17690	903	63	1	9	9
17691	903	75	1	12	12
28724	2021	51	1	8	8
28725	2021	52	1	8	8
28726	2021	57	2	9	18
10570	1047	1	1	2	2
10571	1047	5	5	3	15
10572	1047	36	1	8	8
28727	2021	107	2	14	28
10607	860	1	1	2	2
10608	860	4	4	3	12
10609	860	35	3	17	51
10610	860	32	2	8	16
10611	860	58	2	13	26
10612	860	99	2	12	24
10613	860	51	1	8	8
10614	860	149	1	13	13
10625	1052	1	1	2	2
10626	1052	70	1	8	8
10627	1052	334	1	8	8
10628	1052	114	2	10	20
10629	1052	51	1	8	8
10630	1052	5	1	3	3
10634	1053	1	1	2	2
10635	1053	3	12	3	36
10636	1053	5	2	3	6
10639	1054	5	6	3	18
10640	1054	48	1	10	10
10688	1059	2	1	2	2
10689	1059	6	2	3	6
10690	1059	4	2	3	6
10691	1059	91	2	8	16
10692	1059	26	1	14	14
10693	1059	145	1	8	8
10694	1059	52	1	8	8
10695	1059	64	1	13	13
10717	115	1	1	2	2
10718	115	4	10	3	30
10719	115	149	1	13	13
10720	115	114	1	10	10
10721	115	339	1	9	9
10722	115	53	2	9	18
10723	115	32	1	8	8
10724	115	165	1	8	8
10748	1065	2	1	2	2
10749	1065	4	13	3	39
10750	1065	57	1	9	9
10751	1065	149	3	13	39
10752	1065	118	1	8	8
10753	1065	172	1	13	13
10754	1065	159	1	17	17
10802	1070	1	1	2	2
10803	1070	6	6	3	18
10804	1070	342	1	9	9
10805	1070	105	1	13	13
10806	1070	56	1	12	12
10807	1070	62	1	9	9
10808	1070	64	1	13	13
10831	1072	1	1	2	2
10832	1072	149	3	13	39
10833	1072	74	3	8	24
10834	1072	105	1	13	13
10835	1072	172	1	13	13
10836	1072	116	1	8	8
10837	1072	52	1	8	8
10838	1072	48	1	10	10
10839	1072	313	2	16	32
11253	640	282	1	34	34
11254	640	284	1	11	11
11255	640	293	1	65	65
11292	1122	1	1	2	2
11293	1122	46	2	6	12
11294	1122	5	12	3	36
11295	1122	311	1	30	30
11309	1123	307	2	24	48
11310	1123	311	2	30	60
11311	926	1	2	2	4
11312	926	27	3	8	24
11313	926	57	2	9	18
11314	926	58	4	13	52
11315	926	36	1	8	8
11316	926	51	2	8	16
11317	926	46	2	6	12
11318	926	114	2	10	20
11319	926	96	1	8	8
11320	926	145	1	8	8
11321	926	4	15	3	45
11331	1126	315	1	65	65
11332	1126	282	1	34	34
11348	1127	1	1	2	2
11349	1127	7	7	6	42
11350	1127	5	3	3	9
11351	1127	91	1	8	8
28728	2021	63	1	9	9
28729	2021	46	2	6	12
28730	2021	116	1	8	8
24304	767	1	1	2	2
24305	767	5	3	3	9
24306	767	96	2	8	16
24307	767	57	1	9	9
10706	1060	62	1	9	9
10707	1060	145	1	8	8
9980	1002	1	1	2	2
9981	1002	6	12	3	36
9985	988	1	1	2	2
9986	988	151	1	17	17
9987	988	149	1	13	13
9988	988	130	1	12	12
9989	988	59	1	9	9
9990	550	1	1	2	2
9991	550	5	10	3	30
9992	986	1	1	2	2
9993	986	41	2	15	30
9994	986	6	15	3	45
9995	986	51	2	8	16
9996	986	58	2	13	26
9997	986	105	1	13	13
9998	986	109	1	14	14
9999	986	56	1	12	12
10000	986	95	1	8	8
10001	986	101	5	3	15
10002	980	1	1	2	2
10003	980	6	4	3	12
10004	980	146	1	9	9
10005	980	167	1	8	8
10006	980	108	1	8	8
10007	980	51	1	8	8
10008	980	56	1	12	12
10009	977	1	1	2	2
10010	977	6	4	3	12
10011	977	114	1	10	10
10012	977	32	1	8	8
10013	977	130	1	12	12
10014	977	143	1	9	9
10025	445	1	1	2	2
10026	445	5	11	3	33
28784	2476	6	3	3	9
28785	2476	3	10	3	30
24308	767	114	1	10	10
24309	767	20	1	8	8
24310	767	63	1	9	9
10755	1066	292	1	50	50
10756	1066	282	1	34	34
10757	1066	315	1	65	65
10758	1066	303	1	13	13
10768	1068	4	11	3	33
10769	1068	27	3	8	24
24318	2164	1	1	2	2
24319	2164	106	4	14	56
10095	1005	5	3	3	9
10096	1005	101	3	3	9
10097	1005	339	2	9	18
24320	2164	8	2	6	12
24321	2164	5	1	3	3
24322	2164	150	1	11	11
24323	2164	114	1	10	10
24324	2164	63	1	9	9
10126	405	1	1	2	2
10127	405	5	6	3	18
10128	405	31	1	9	9
10129	405	57	1	9	9
10130	405	64	1	13	13
10131	405	20	1	8	8
10132	405	41	1	15	15
28852	1067	2	1	2	2
10141	1008	1	1	2	2
10142	1008	6	4	3	12
10143	1008	63	1	9	9
28853	1067	5	2	3	6
28854	1067	52	1	8	8
28855	1067	63	1	9	9
28856	1067	114	1	10	10
28857	1067	105	1	13	13
28858	1067	106	1	14	14
10151	1010	1	1	2	2
10152	1010	4	13	3	39
10153	1009	1	2	2	4
10154	1009	5	8	3	24
10155	1009	342	1	9	9
10156	1009	75	1	12	12
10157	1009	101	5	3	15
28886	2483	2	1	2	2
28887	2483	40	2	19	38
24381	2165	1	1	2	2
28911	592	1	1	2	2
28912	592	5	3	3	9
28913	592	57	3	9	27
28914	592	335	3	5	15
10178	1011	5	1	3	3
10179	1011	4	2	3	6
10180	1011	31	2	9	18
10181	1011	32	1	8	8
10182	1011	62	1	9	9
10183	1011	43	1	12	12
10192	1012	1	1	2	2
10193	1012	4	6	3	18
10194	1012	36	1	8	8
10195	1012	57	1	9	9
10196	1012	163	1	8	8
10197	1012	116	1	8	8
10198	1012	74	1	8	8
10199	1012	64	1	13	13
10204	102	6	6	3	18
10205	102	32	1	8	8
10206	102	114	1	10	10
10207	102	149	1	13	13
10208	1014	1	1	2	2
10209	1014	5	10	3	30
12578	1227	1	1	2	2
12579	1228	339	1	9	9
12580	1228	57	1	9	9
12581	1228	59	1	9	9
10770	1068	110	1	9	9
10771	1068	114	1	10	10
10772	1068	1	1	2	2
12582	1228	340	1	15	15
10809	1071	307	1	24	24
10810	1071	278	1	18	18
10811	1071	282	2	34	68
10812	1071	315	3	65	195
10813	1071	311	1	30	30
10814	1071	284	1	11	11
17692	903	27	1	8	8
17693	903	52	1	8	8
17694	1621	1	1	2	2
17695	1621	5	3	3	9
11260	1115	1	1	2	2
11261	1115	4	5	3	15
11262	1115	6	2	3	6
11263	1115	185	1	50	50
11271	1116	282	2	34	68
11283	1120	100	1	17	17
11284	1120	25	1	14	14
11285	1120	40	1	19	19
11287	1121	278	3	18	54
17696	1621	6	3	3	9
24359	723	63	2	9	18
24360	723	62	1	9	9
24361	723	150	1	11	11
24362	723	34	1	8	8
15131	1439	1	1	2	2
15132	1439	7	4	6	24
15133	1439	339	1	9	9
24393	2166	32	1	8	8
24394	2166	57	1	9	9
24395	2166	342	1	9	9
11357	1128	282	1	34	34
11358	1128	311	2	30	60
11364	1129	1	1	2	2
11365	1129	4	2	3	6
11366	1129	335	1	5	5
11367	1129	46	3	6	18
11368	1129	40	1	19	19
11386	1131	1	1	2	2
11387	1131	43	1	12	12
11388	1131	46	1	6	6
11389	1131	58	1	13	13
11390	1131	57	1	9	9
11391	1131	52	1	8	8
11392	1131	335	1	5	5
11393	1131	96	1	8	8
11394	1131	5	1	3	3
11537	1141	1	1	2	2
11538	1141	4	4	3	12
11539	1144	1	1	2	2
11540	1144	5	10	3	30
11554	1146	1	1	2	2
11555	1146	4	11	3	33
11556	1146	5	10	3	30
11579	1149	5	5	3	15
11580	1149	278	1	18	18
11581	1149	311	2	30	60
11582	1149	307	2	24	48
11586	1150	132	3	17	51
11587	1150	31	1	9	9
11588	1150	190	1	30	30
11620	1153	1	1	2	2
11621	1153	5	5	3	15
11622	1153	36	1	8	8
11623	1153	96	2	8	16
11624	1153	114	1	10	10
11625	1153	108	1	8	8
11626	1153	165	1	8	8
11627	1153	145	1	8	8
11628	1153	52	1	8	8
11629	1153	62	1	9	9
11641	1154	1	1	2	2
11642	1154	5	5	3	15
11643	1154	7	1	6	6
11644	1154	30	1	8	8
11645	1154	58	1	13	13
11646	1154	159	1	17	17
11647	1154	100	1	17	17
11648	1154	151	5	17	85
11649	1154	20	1	8	8
11650	1154	46	1	6	6
11651	1154	186	1	30	30
11658	1155	3	3	3	9
11659	1155	5	1	3	3
11660	1155	52	1	8	8
11661	1155	56	1	12	12
11662	1156	1	1	2	2
11663	1156	4	15	3	45
11670	234	1	1	2	2
11671	234	40	2	19	38
11672	234	186	2	30	60
11673	234	56	3	12	36
11674	234	25	1	14	14
11675	234	159	1	17	17
11682	1157	1	1	2	2
11683	1157	137	1	8	8
11684	1157	120	1	18	18
11685	1157	58	1	13	13
11686	1157	149	1	13	13
11687	1157	40	3	19	57
11697	1158	1	1	2	2
11698	1158	4	10	3	30
11699	1159	1	1	2	2
11700	1159	57	3	9	27
11701	1159	51	1	8	8
11702	1159	20	1	8	8
11703	1159	25	1	14	14
11704	1159	110	1	9	9
11705	1159	3	2	3	6
11719	1161	3	15	3	45
11744	1163	282	6	34	204
11745	1163	285	1	15	15
10227	481	1	1	2	2
10228	481	4	3	3	9
10229	481	30	1	8	8
10230	481	114	1	10	10
10231	481	65	1	8	8
10232	481	96	1	8	8
10233	481	155	1	17	17
10234	481	20	1	8	8
10235	481	64	1	13	13
10840	1063	3	6	3	18
10841	1063	114	1	10	10
10842	1063	32	1	8	8
10843	1063	65	1	8	8
10844	1063	57	1	9	9
10845	1074	315	1	65	65
10846	1074	313	1	16	16
10847	1074	314	1	30	30
10848	1074	307	1	24	24
10851	1076	315	2	65	130
10860	1078	282	2	34	68
10861	1078	292	1	50	50
10862	1078	311	1	30	30
24382	2165	5	7	3	21
24383	2165	8	4	6	24
24384	2165	51	2	8	16
24385	2165	120	1	18	18
24386	2165	339	1	9	9
17697	1621	36	1	8	8
17698	1621	32	1	8	8
17699	1621	62	1	9	9
10899	1081	292	3	50	150
10900	1081	105	1	13	13
10901	1081	149	2	13	26
15142	561	5	5	3	15
17700	1621	51	1	8	8
17701	1621	52	1	8	8
17704	1622	5	6	3	18
17705	1622	145	1	8	8
24387	2165	114	1	10	10
20577	1861	1	1	2	2
20578	1861	6	2	3	6
20579	1861	58	1	13	13
20580	1861	51	1	8	8
20581	1861	120	1	18	18
20582	1861	151	1	17	17
10956	1090	278	2	18	36
10957	1090	280	2	9	18
24388	2165	57	1	9	9
24389	2165	31	3	9	27
24390	2165	101	2	3	6
10998	1095	307	2	24	48
11042	1099	1	1	2	2
11043	1099	39	2	8	16
11044	1099	52	1	8	8
11045	1099	51	1	8	8
11046	1099	163	1	8	8
11047	1099	318	1	12	12
11048	1099	70	1	8	8
11049	1099	96	2	8	16
11050	1099	6	4	3	12
11056	1100	131	2	22	44
11057	1100	132	1	17	17
11058	1100	282	1	34	34
11068	1102	307	3	24	72
11069	1102	311	3	30	90
11084	1089	9	1	12	12
11088	999	2	1	2	2
11089	999	303	1	13	13
11090	999	311	1	30	30
11091	999	4	3	3	9
11092	999	36	2	8	16
11093	999	101	2	3	6
11094	999	191	2	30	60
11146	1107	1	1	2	2
11147	1107	43	1	12	12
11148	1107	32	1	8	8
11149	1107	120	1	18	18
11150	1107	165	1	8	8
11151	1107	100	2	17	34
11152	1107	114	1	10	10
11153	1107	40	1	19	19
11154	1107	282	1	34	34
11155	1107	307	2	24	48
11213	1112	334	1	8	8
11214	1112	43	1	12	12
11215	1112	130	4	12	48
11216	1112	27	1	8	8
11217	1112	57	2	9	18
11218	1112	52	2	8	16
11219	1112	51	1	8	8
11220	1112	36	1	8	8
11221	1112	39	2	8	16
11222	1112	145	1	8	8
11223	1112	1	1	2	2
11279	1119	4	10	3	30
11325	1124	1	1	2	2
11326	1124	3	1	3	3
11327	1124	213	3	8	24
11373	1130	2	1	2	2
11374	1130	6	5	3	15
11375	1130	58	3	13	39
11376	1130	185	1	50	50
11398	1132	6	5	3	15
11399	1132	7	3	6	18
11400	1132	335	1	5	5
11416	1134	1	1	2	2
11417	1134	6	4	3	12
11418	1134	172	2	13	26
11419	1134	57	1	9	9
11420	1134	56	1	12	12
11421	1134	34	2	8	16
11422	1133	1	1	2	2
11423	1133	4	3	3	9
11424	1133	8	2	6	12
11425	1133	44	1	8	8
11426	1133	43	1	12	12
11427	1133	57	1	9	9
11428	1133	120	1	18	18
11429	1133	108	1	8	8
11430	1133	343	1	11	11
11431	1125	311	2	30	60
11465	1136	1	1	2	2
11466	1136	6	5	3	15
11467	1136	163	1	8	8
11468	1136	129	1	9	9
11469	1136	96	1	8	8
11470	1136	51	2	8	16
11471	1136	74	1	8	8
11472	1136	143	1	9	9
11473	1136	142	1	9	9
11720	1161	120	2	18	36
11721	1161	57	1	9	9
11722	1161	44	1	8	8
11723	1161	32	1	8	8
11724	1161	46	2	6	12
11725	1161	62	1	9	9
11726	1161	24	2	8	16
11733	1162	1	1	2	2
11734	1162	5	3	3	9
11735	1162	63	1	9	9
11736	1162	149	1	13	13
11737	1162	100	1	17	17
11738	1162	132	2	17	34
12583	1228	6	8	3	24
15134	1439	130	2	12	24
15135	1439	75	1	12	12
20583	1861	153	1	17	17
20584	1861	114	1	10	10
24391	2165	106	2	14	28
17739	1623	1	1	2	2
17740	1623	3	2	3	6
17741	1623	31	1	9	9
15164	1441	1	1	2	2
15165	1441	6	6	3	18
15166	1441	120	1	18	18
15167	1441	129	1	9	9
15168	1441	157	1	17	17
24392	2165	131	2	22	44
17756	1629	3	6	3	18
15169	1441	35	1	17	17
15170	1441	151	1	17	17
15171	1441	191	1	30	30
28737	2473	1	1	2	2
11802	1168	1	1	2	2
11803	1168	6	5	3	15
11804	1168	138	1	8	8
11805	1168	28	1	12	12
11806	1168	120	1	18	18
11807	1168	149	1	13	13
11808	1168	91	1	8	8
11809	1168	58	1	13	13
11810	1168	63	1	9	9
11822	1169	9	3	12	36
11823	1169	1	1	2	2
17757	1629	5	3	3	9
17758	1629	116	1	8	8
11859	1172	3	10	3	30
11860	1172	57	1	9	9
11861	1172	120	1	18	18
11862	1172	25	1	14	14
11863	1172	29	1	12	12
11864	1172	56	6	12	72
11865	1172	52	1	8	8
11866	1172	143	1	9	9
17759	1629	56	1	12	12
28738	2473	5	3	3	9
28739	2473	242	2	8	16
12704	911	3	6	3	18
12705	911	165	1	8	8
12706	911	63	1	9	9
12707	911	96	1	8	8
12708	911	342	1	9	9
12709	911	20	1	8	8
12723	1239	1	1	2	2
12724	1239	63	1	9	9
12725	1239	114	1	10	10
12726	1239	51	1	8	8
12727	1239	31	2	9	18
12728	1239	96	1	8	8
11959	1177	1	1	2	2
11960	1177	27	1	8	8
11961	1177	30	1	8	8
11962	1177	137	1	8	8
11963	1177	43	1	12	12
11964	1177	114	1	10	10
11965	1177	172	1	13	13
11966	1177	136	1	8	8
11967	1177	96	1	8	8
11968	1177	165	1	8	8
11969	1177	57	1	9	9
11970	1177	58	1	13	13
11971	1177	150	1	11	11
11972	1177	142	1	9	9
11989	574	1	1	2	2
11990	574	5	3	3	9
11991	574	27	2	8	16
11992	574	30	1	8	8
11993	574	106	3	14	42
11994	574	303	3	13	39
12007	591	5	1	3	3
12008	591	4	1	3	3
12009	591	7	1	6	6
12010	591	8	2	6	12
12748	1241	52	1	8	8
12749	1241	1	1	2	2
12750	1241	4	1	3	3
12751	1241	172	1	13	13
12752	1241	43	2	12	24
12753	1241	339	1	9	9
12754	1241	32	1	8	8
12795	443	1	1	2	2
12796	443	5	2	3	6
12797	443	57	1	9	9
12798	443	62	1	9	9
12799	443	344	1	11	11
12803	1245	6	10	3	30
12804	1245	5	10	3	30
12805	1245	2	2	2	4
12812	1246	1	1	2	2
12813	1246	6	4	3	12
12814	1246	51	1	8	8
12815	1246	57	1	9	9
12816	1246	150	1	11	11
12817	1246	129	1	9	9
12818	1246	271	1	24	24
12851	1244	1	1	2	2
12852	1244	5	10	3	30
12853	1244	4	10	3	30
12860	1248	1	1	2	2
12861	1248	4	8	3	24
12862	1248	62	1	9	9
12863	1248	63	1	9	9
12864	1248	64	1	13	13
12865	1248	116	3	8	24
12866	1248	57	1	9	9
12867	1248	129	1	9	9
12868	1248	114	1	10	10
12869	1248	96	1	8	8
12870	1248	30	1	8	8
11746	1163	278	3	18	54
11747	1163	307	2	24	48
11748	1163	303	3	13	39
11756	1164	3	5	3	15
11757	1164	5	1	3	3
11758	1164	32	1	8	8
11759	1164	57	1	9	9
11760	1164	52	1	8	8
11761	1164	24	1	8	8
11762	1164	282	3	34	102
28740	2473	63	2	9	18
28741	2473	96	2	8	16
11785	1167	1	1	2	2
11786	1167	6	4	3	12
11787	1167	56	1	12	12
11788	1167	58	1	13	13
11789	1167	51	1	8	8
11790	1167	118	1	8	8
11791	1167	64	1	13	13
11792	1167	159	1	17	17
12608	1230	1	1	2	2
12609	1230	5	3	3	9
12610	1230	32	1	8	8
12611	1230	58	1	13	13
12612	1230	51	2	8	16
12613	1230	64	1	13	13
12614	1230	25	2	14	28
12615	1230	24	1	8	8
12616	1230	342	1	9	9
12617	1230	343	1	11	11
12618	1230	91	1	8	8
11824	1113	1	1	2	2
11825	1113	6	1	3	3
11826	1113	3	4	3	12
11827	1113	57	1	9	9
11828	1113	27	1	8	8
11829	1113	344	1	11	11
11830	1113	110	1	9	9
11831	1113	25	2	14	28
11832	1113	51	1	8	8
12629	1231	62	2	9	18
12630	1231	57	1	9	9
12631	1231	1	1	2	2
12632	1231	213	3	8	24
12633	1231	5	1	3	3
11873	1173	62	2	9	18
11874	1173	40	1	19	19
11875	1173	52	1	8	8
11876	1173	339	1	9	9
11877	1173	172	1	13	13
11878	1173	131	1	22	22
12634	1231	46	1	6	6
12635	1231	52	1	8	8
12636	1231	121	2	35	70
12670	1233	1	1	2	2
12671	1233	5	5	3	15
12686	1235	151	1	17	17
12687	1235	339	1	9	9
12688	1235	20	1	8	8
11887	879	1	1	2	2
11888	879	5	3	3	9
11889	879	3	3	3	9
11890	879	163	1	8	8
11891	879	44	1	8	8
11892	879	62	1	9	9
11893	879	185	1	50	50
11894	879	264	1	10	10
11903	1174	1	1	2	2
11904	1174	5	9	3	27
11905	1174	96	2	8	16
11906	1174	105	2	13	26
11907	1174	46	2	6	12
11908	1174	51	2	8	16
11909	1174	57	1	9	9
11910	1174	114	1	10	10
11915	1175	1	1	2	2
11916	1175	9	1	12	12
11917	1175	7	5	6	30
11918	1175	8	5	6	30
11973	1178	1	1	2	2
11974	1178	8	2	6	12
11975	1178	5	1	3	3
11976	1178	136	1	8	8
11977	1178	62	1	9	9
11978	1178	63	1	9	9
11979	1178	51	1	8	8
11980	1178	151	1	17	17
11981	1178	116	1	8	8
11982	1178	193	1	22	22
11999	1179	278	1	18	18
12000	1179	282	2	34	68
12001	1179	307	1	24	24
12002	1179	311	1	30	30
12013	1180	1	1	2	2
12014	1180	5	10	3	30
12689	1235	55	1	8	8
15175	1403	4	2	3	6
15176	1403	213	2	8	16
15177	1403	30	1	8	8
15178	1403	1	1	2	2
15183	1443	3	6	3	18
15184	1443	5	3	3	9
15185	1443	113	1	25	25
15186	1443	1	1	2	2
15208	1445	40	1	19	19
15209	1445	3	3	3	9
15210	1445	51	1	8	8
12829	1247	1	1	2	2
12830	1247	165	1	8	8
12831	1247	31	1	9	9
12832	1247	32	1	8	8
12833	1247	35	1	17	17
12834	1247	57	1	9	9
12835	1247	51	1	8	8
12836	1247	52	1	8	8
12837	1247	65	1	8	8
12838	1247	27	2	8	16
15211	1445	43	1	12	12
15212	1445	104	1	13	13
12902	1251	5	10	3	30
12920	1253	2	1	2	2
12921	1253	25	1	14	14
12922	1253	32	1	8	8
12923	1253	57	1	9	9
12924	1253	3	1	3	3
12925	1253	96	1	8	8
12926	1253	56	1	12	12
12940	1217	1	1	2	2
12941	1217	57	5	9	45
12942	1217	62	1	9	9
12943	1217	105	1	13	13
15143	561	3	3	3	9
11772	1166	185	1	50	50
11773	1166	1	1	2	2
11774	1166	6	3	3	9
11775	1166	5	3	3	9
11776	1166	159	2	17	34
11842	1170	4	6	3	18
11843	1170	1	1	2	2
11844	1171	1	1	2	2
11845	1171	5	5	3	15
11846	1171	3	5	3	15
11847	1171	8	3	6	18
11848	1171	7	2	6	12
11849	1171	149	1	13	13
11850	1171	120	1	18	18
15144	561	32	2	8	16
15145	561	114	1	10	10
15146	561	57	2	9	18
15147	561	51	1	8	8
15148	561	64	1	13	13
28742	2473	193	1	22	22
28750	2474	1	1	2	2
28751	2474	3	3	3	9
28752	2474	5	5	3	15
28753	2474	43	1	12	12
28754	2474	63	1	9	9
24410	2167	1	1	2	2
24411	2167	46	2	6	12
24412	2167	157	1	17	17
24413	2167	26	1	14	14
24414	2167	31	1	9	9
24415	2167	342	1	9	9
11927	1176	2	1	2	2
11928	1176	5	2	3	6
11929	1176	9	2	12	24
11930	1176	56	2	12	24
11931	1176	58	1	13	13
11932	1176	129	1	9	9
11933	1176	148	1	17	17
11934	1176	186	3	30	90
12023	1181	1	1	2	2
12024	1181	57	2	9	18
12025	1181	163	1	8	8
12026	1181	106	1	14	14
12027	1181	63	2	9	18
12028	1181	138	1	8	8
12029	1181	334	1	8	8
12030	1181	321	1	3	3
12036	1182	2	1	2	2
12037	1182	7	10	6	60
12038	1182	8	10	6	60
12039	1182	149	2	13	26
12040	1182	132	2	17	34
12046	1183	1	1	2	2
12047	1183	5	10	3	30
12048	1183	32	1	8	8
12049	1183	52	2	8	16
12050	1183	58	1	13	13
12055	1184	1	1	2	2
12056	1184	335	7	5	35
12057	1184	213	1	8	8
12058	1184	113	1	25	25
12063	1185	1	1	2	2
12064	1185	5	4	3	12
12065	1185	25	1	14	14
12066	1185	52	1	8	8
12069	1186	2	1	2	2
12070	1186	4	9	3	27
12073	1187	3	4	3	12
12074	1187	5	4	3	12
12082	1188	7	1	6	6
12083	1188	8	1	6	6
12084	1188	5	12	3	36
12085	1188	96	1	8	8
12086	1188	165	1	8	8
12087	1188	145	1	8	8
12088	1188	339	1	9	9
12118	1190	1	1	2	2
12119	1190	3	2	3	6
12120	1190	6	5	3	15
12121	1190	51	1	8	8
12122	1190	52	1	8	8
12123	1190	63	1	9	9
12124	1190	46	1	6	6
12125	1190	150	1	11	11
12126	1190	311	1	30	30
12127	1190	185	1	50	50
12137	628	1	1	2	2
12138	628	25	1	14	14
12139	628	165	1	8	8
12140	628	57	1	9	9
12141	628	149	2	13	26
12142	628	3	6	3	18
12143	628	101	1	3	3
12144	628	321	1	3	3
12145	628	313	1	16	16
12154	1191	1	1	2	2
12155	1191	3	7	3	21
12156	1191	5	2	3	6
12157	1191	32	1	8	8
12158	1191	52	2	8	16
12159	1191	57	2	9	18
12160	1191	46	1	6	6
12161	1191	63	1	9	9
12171	978	335	4	5	20
12172	978	27	1	8	8
12173	978	32	1	8	8
12174	978	114	1	10	10
12175	978	129	1	9	9
12176	978	36	1	8	8
12177	978	116	1	8	8
12178	978	333	1	8	8
12179	978	63	1	9	9
12221	1194	1	1	2	2
12222	1194	46	2	6	12
12223	1194	5	2	3	6
12224	1194	3	6	3	18
12225	1195	4	7	3	21
12226	1195	1	1	2	2
12202	1193	1	2	2	4
12203	1193	5	5	3	15
12204	1193	151	1	17	17
12205	1193	143	1	9	9
12206	1193	46	3	6	18
12207	1193	190	1	30	30
12208	1193	315	4	65	260
12209	1193	132	1	17	17
12210	1193	131	1	22	22
12211	1193	40	1	19	19
12212	1193	100	1	17	17
12213	1193	130	1	12	12
12214	1193	159	2	17	34
15174	1442	149	1	13	13
20593	1863	32	1	8	8
17734	1625	1	1	2	2
17735	1625	5	5	3	15
17736	1625	4	1	3	3
17737	1625	114	1	10	10
17738	1625	96	1	8	8
15193	1444	1	1	2	2
15194	1444	5	3	3	9
15195	1444	25	1	14	14
15196	1444	74	1	8	8
15197	1444	46	3	6	18
15198	1444	157	1	17	17
20594	1863	51	2	8	16
12285	1200	2	1	2	2
12286	1200	25	1	14	14
12287	1200	35	1	17	17
12288	1200	5	3	3	9
12289	1200	165	1	8	8
12290	1200	51	1	8	8
12291	1200	52	1	8	8
12292	1200	63	2	9	18
20595	1863	52	1	8	8
12657	1232	1	1	2	2
12658	1232	44	2	8	16
12659	1232	27	1	8	8
12660	1232	32	2	8	16
12661	1232	7	2	6	12
12330	1204	5	5	3	15
12331	1204	27	1	8	8
12332	1204	57	1	9	9
20596	1863	62	1	9	9
20597	1863	150	1	11	11
20598	1863	1	1	2	2
20599	1863	188	1	30	30
20618	1865	3	8	3	24
20619	1865	6	4	3	12
24416	2167	339	1	9	9
12662	1232	114	1	10	10
12663	1232	31	1	9	9
12664	1232	51	3	8	24
17785	1630	2	1	2	2
17786	1630	3	10	3	30
17787	1630	114	1	10	10
17788	1630	56	1	12	12
12379	1208	1	1	2	2
12380	1208	114	1	10	10
12381	1208	52	1	8	8
12382	1208	75	1	12	12
12383	1208	142	1	9	9
12384	1208	343	1	11	11
12385	1208	339	1	9	9
12386	1208	342	1	9	9
12387	1208	20	1	8	8
12690	1236	1	1	2	2
12691	1236	5	3	3	9
12692	1236	3	3	3	9
12693	1236	61	1	8	8
12694	1236	39	1	8	8
12755	1242	1	1	2	2
12756	1242	3	6	3	18
12757	1242	43	1	12	12
12758	1242	96	2	8	16
12759	1242	114	1	10	10
12760	1242	57	2	9	18
12761	1242	63	1	9	9
12762	1242	26	1	14	14
12763	1242	110	1	9	9
12764	1242	51	1	8	8
12765	1242	52	1	8	8
12766	1242	145	1	8	8
12777	1243	40	1	19	19
12778	1243	58	1	13	13
12779	1243	57	1	9	9
12780	1243	30	1	8	8
12781	1243	145	1	8	8
12782	1243	342	1	9	9
12783	1243	130	1	12	12
12784	1243	52	1	8	8
12785	1243	251	5	3	15
12786	1243	187	1	30	30
12903	1252	1	1	2	2
12904	1252	96	2	8	16
12905	1252	57	1	9	9
12906	1252	62	1	9	9
12907	1252	29	1	12	12
12908	1252	145	1	8	8
12909	1252	143	1	9	9
12910	1252	51	2	8	16
12911	1252	52	2	8	16
12912	1252	63	2	9	18
12929	111	31	2	9	18
12930	111	34	1	8	8
12931	111	1	1	2	2
12932	111	56	1	12	12
12933	111	43	1	12	12
12934	1222	1	1	2	2
12935	1222	3	5	3	15
12936	1222	30	1	8	8
12937	1222	334	1	8	8
12938	1222	63	1	9	9
12939	1222	343	1	11	11
13013	1261	105	1	13	13
13014	1261	1	1	2	2
13015	1261	6	4	3	12
13016	1261	5	2	3	6
13017	1261	114	1	10	10
13018	1261	120	2	18	36
13019	1261	24	1	8	8
13020	1261	185	1	50	50
13047	145	51	1	8	8
13048	145	52	1	8	8
13049	145	46	3	6	18
13050	145	36	1	8	8
13051	145	32	1	8	8
13052	145	116	1	8	8
13053	145	335	1	5	5
13054	145	4	4	3	12
12871	1248	32	1	8	8
12872	1248	347	1	13	13
17760	1629	65	1	8	8
17761	1629	96	1	8	8
24417	2167	151	1	17	17
12254	1197	2	1	2	2
12255	1197	5	4	3	12
12256	1197	7	2	6	12
12257	1197	63	1	9	9
12258	1197	20	1	8	8
24418	2167	150	1	11	11
24419	2167	148	1	17	17
28755	2474	116	1	8	8
20617	1853	3	3	3	9
12269	1023	1	1	2	2
12270	1023	40	1	19	19
12271	1023	148	2	17	34
12272	1023	130	1	12	12
12275	1199	1	1	2	2
12276	1199	9	4	12	48
28756	2474	34	1	8	8
12968	1257	1	1	2	2
12969	1257	3	12	3	36
12976	1258	113	1	25	25
12977	1258	40	1	19	19
12978	1258	57	1	9	9
12979	1258	1	1	2	2
12300	1201	1	1	2	2
12301	1201	3	6	3	18
12302	1201	57	1	9	9
12303	1201	335	2	5	10
12304	1201	334	1	8	8
12305	1201	110	1	9	9
12306	1201	51	2	8	16
12980	1258	4	3	3	9
12981	1258	106	1	14	14
12991	1259	120	1	18	18
12992	1259	104	1	13	13
12993	1259	56	1	12	12
12994	1259	149	3	13	39
12323	1202	64	1	13	13
12324	1202	5	3	3	9
12325	1202	96	1	8	8
12326	1202	27	1	8	8
12327	1202	44	1	8	8
12995	1259	64	1	13	13
12996	1259	1	1	2	2
16362	1526	64	1	13	13
16363	1526	148	1	17	17
16364	1526	51	1	8	8
16365	1526	149	1	13	13
13131	1269	1	1	2	2
13132	1269	5	3	3	9
13133	1269	6	2	3	6
13134	1269	3	6	3	18
13135	1269	321	2	3	6
13136	1269	30	1	8	8
13137	1269	51	1	8	8
13138	1269	113	1	25	25
13151	1270	1	1	2	2
13152	1270	57	2	9	18
13153	1270	64	1	13	13
13154	1270	63	1	9	9
13155	1270	96	1	8	8
13156	1270	339	1	9	9
13157	1270	25	1	14	14
13158	1270	51	1	8	8
13159	1270	342	1	9	9
13160	1270	20	1	8	8
13161	1270	101	1	3	3
13162	1270	251	1	3	3
16366	1526	1	1	2	2
16382	1529	3	7	3	21
16383	1529	57	2	9	18
16384	1529	27	1	8	8
16385	1529	1	1	2	2
13237	949	2	1	2	2
13238	949	5	10	3	30
13239	949	56	1	12	12
13240	949	106	1	14	14
13249	1279	1	1	2	2
13250	1279	4	10	3	30
13251	1279	251	3	3	9
13252	1279	101	3	3	9
16810	1553	1	1	2	2
16811	1553	3	3	3	9
16812	1553	36	1	8	8
13273	759	149	5	13	65
13274	759	56	1	12	12
13275	759	1	1	2	2
13276	759	6	4	3	12
13277	759	5	4	3	12
13278	759	4	8	3	24
13291	1281	1	1	2	2
13292	1281	113	3	25	75
13293	1281	165	1	8	8
13294	1281	114	1	10	10
13295	1281	36	1	8	8
13296	1281	52	1	8	8
13297	1281	62	1	9	9
13307	1283	1	1	2	2
13308	1283	149	5	13	65
13309	1283	104	1	13	13
13310	1283	63	1	9	9
13313	1284	1	1	2	2
13314	1284	6	15	3	45
13321	1285	5	7	3	21
13322	1285	1	1	2	2
13323	1285	342	3	9	27
13324	1285	142	1	9	9
13325	1285	339	1	9	9
13326	1285	62	1	9	9
13330	1286	303	2	13	26
13331	1286	307	1	24	24
13332	1286	312	1	30	30
13337	1287	1	1	2	2
13338	1287	5	10	3	30
13339	1287	56	4	12	48
13340	1287	47	2	3	6
13345	1288	1	1	2	2
13346	1288	63	6	9	54
13347	1288	150	1	11	11
13348	1288	193	1	22	22
13349	1289	51	1	8	8
13350	1289	52	1	8	8
13351	1289	57	1	9	9
13352	1289	20	2	8	16
13353	1289	129	1	9	9
13354	1289	5	3	3	9
12238	1196	1	1	2	2
12239	1196	5	4	3	12
12240	1196	3	1	3	3
12241	1196	43	3	12	36
12242	1196	335	10	5	50
12243	1196	149	2	13	26
12244	1196	58	1	13	13
12245	1196	63	2	9	18
12246	1196	56	1	12	12
12247	1196	46	1	6	6
12248	1196	20	1	8	8
12873	1249	1	1	2	2
12874	1249	35	1	17	17
12875	1249	159	2	17	34
12876	1249	319	1	14	14
12877	1249	130	2	12	24
12878	1249	40	4	19	76
15213	1445	26	1	14	14
15214	1445	344	1	11	11
12266	1198	5	10	3	30
12267	1198	1	1	2	2
12268	1198	4	5	3	15
15215	1445	116	1	8	8
15216	1445	1	1	2	2
12322	1203	3	10	3	30
12341	1205	1	1	2	2
12342	1205	3	10	3	30
12343	1206	1	1	2	2
12344	1206	31	1	9	9
12345	1206	114	1	10	10
12346	1206	106	1	14	14
12347	1206	56	1	12	12
12348	1206	46	1	6	6
12349	1206	52	1	8	8
12350	1206	103	1	31	31
20625	1077	2	1	2	2
20626	1077	3	10	3	30
20627	1077	315	2	65	130
17791	1632	1	1	2	2
17792	1632	5	4	3	12
20666	1869	3	20	3	60
20667	1869	1	1	2	2
17793	1632	114	1	10	10
17794	1632	64	1	13	13
17795	1632	32	1	8	8
17796	1632	51	1	8	8
17797	1632	253	1	17	17
12988	1240	31	1	9	9
12989	1240	51	1	8	8
12990	1240	101	2	3	6
17807	1635	1	1	2	2
17808	1635	3	3	3	9
17809	1635	5	2	3	6
17810	1635	52	2	8	16
20668	1867	5	4	3	12
20669	1867	57	1	9	9
13040	1263	1	1	2	2
13041	1263	91	1	8	8
13042	1263	25	1	14	14
13043	1263	114	1	10	10
13044	1263	57	1	9	9
13045	1263	63	1	9	9
13046	1263	150	1	11	11
28763	2422	1	1	2	2
28764	2422	3	2	3	6
28765	2422	96	1	8	8
24439	2171	1	1	2	2
13064	1264	1	1	2	2
13065	1264	3	3	3	9
13066	1264	114	1	10	10
13067	1264	137	1	8	8
13068	1264	138	1	8	8
13069	1264	165	2	8	16
13070	1264	130	2	12	24
13071	1264	20	1	8	8
13072	1264	101	3	3	9
13085	1266	1	1	2	2
13086	1266	52	1	8	8
13087	1266	63	2	9	18
13088	1266	116	1	8	8
13089	1266	32	1	8	8
13090	1266	57	1	9	9
13091	1266	62	1	9	9
13092	1266	118	1	8	8
13093	1266	74	1	8	8
13094	1266	68	1	8	8
13095	1266	145	1	8	8
13096	1266	186	1	30	30
13105	1267	1	1	2	2
13106	1267	57	1	9	9
13107	1267	58	1	13	13
13108	1267	43	1	12	12
13109	1267	114	1	10	10
13110	1267	165	2	8	16
13111	1267	56	1	12	12
13112	1267	26	1	14	14
13118	1268	3	10	3	30
13119	1268	29	1	12	12
13120	1268	319	1	14	14
13121	1268	130	1	12	12
13122	1268	151	1	17	17
13177	1272	1	1	2	2
13178	1272	5	2	3	6
13179	1272	114	2	10	20
13180	1272	36	1	8	8
13181	1272	34	1	8	8
13182	1272	258	1	3	3
13193	1273	1	1	2	2
13194	1273	3	14	3	42
13216	1276	3	3	3	9
13217	1276	52	1	8	8
13218	1276	57	1	9	9
13219	1276	344	1	11	11
13220	1276	343	2	11	22
13221	1276	1	1	2	2
13222	1276	191	1	30	30
13228	1277	1	1	2	2
13229	1277	46	2	6	12
13230	1277	58	1	13	13
13231	1277	114	1	10	10
13232	1277	30	1	8	8
13241	1278	315	2	65	130
13242	1278	282	1	34	34
13243	1278	311	1	30	30
13244	1278	5	3	3	9
28766	2422	339	1	9	9
13399	1293	1	1	2	2
13400	1293	5	3	3	9
13401	1293	3	6	3	18
13402	1293	114	1	10	10
13403	1293	108	1	8	8
13404	1293	116	1	8	8
13405	1293	101	1	3	3
13406	1293	143	1	9	9
24440	2171	5	7	3	21
15226	899	3	4	3	12
15227	899	319	2	14	28
15228	899	25	1	14	14
15229	899	58	2	13	26
15230	899	57	1	9	9
15231	899	74	1	8	8
15232	899	64	1	13	13
15233	899	104	1	13	13
15234	899	1	1	2	2
28767	2422	116	1	8	8
28768	2422	130	1	12	12
15256	1448	2	1	2	2
15257	1448	5	10	3	30
15258	1448	165	2	8	16
15259	1448	57	3	9	27
15260	1448	51	1	8	8
13440	150	1	1	2	2
13441	150	5	6	3	18
13442	150	163	2	8	16
13443	150	341	1	9	9
13444	150	95	2	8	16
13445	150	51	2	8	16
13446	150	62	1	9	9
13447	150	334	1	8	8
13448	150	116	2	8	16
13449	150	34	2	8	16
15261	1448	52	1	8	8
15262	1448	96	1	8	8
17783	1627	1	1	2	2
16403	1530	1	1	2	2
16404	1530	3	5	3	15
16405	1530	96	1	8	8
28777	766	1	1	2	2
16406	1530	165	1	8	8
16407	1530	57	2	9	18
16408	1530	129	1	9	9
16409	1530	114	1	10	10
16410	1530	110	1	9	9
16411	1530	51	2	8	16
16412	1530	116	1	8	8
16413	1530	63	1	9	9
16414	1530	164	1	9	9
16415	1530	6	5	3	15
28778	766	3	3	3	9
24464	2174	1	1	2	2
24465	2174	6	8	3	24
24466	2174	151	2	17	34
24467	2174	150	2	11	22
24468	2174	20	2	8	16
24469	2174	145	2	8	16
16435	1532	5	15	3	45
16436	1532	153	1	17	17
16437	1532	1	1	2	2
24470	2174	25	1	14	14
24471	2174	191	1	30	30
24488	2176	1	1	2	2
16478	1535	1	1	2	2
16479	1535	6	4	3	12
16480	1535	165	2	8	16
16481	1535	58	2	13	26
16482	1535	339	1	9	9
16483	1535	109	2	14	28
16484	1535	46	3	6	18
16485	1535	151	2	17	34
16486	1535	40	2	19	38
16487	1535	270	1	30	30
24489	2176	6	10	3	30
16516	1539	1	1	2	2
16517	1539	3	10	3	30
16562	1543	1	1	2	2
16563	1543	3	10	3	30
16564	1543	51	1	8	8
16565	1543	52	1	8	8
16566	1543	57	1	9	9
16567	1543	110	1	9	9
16568	1543	30	1	8	8
16569	1543	36	1	8	8
16570	1543	101	4	3	12
16571	1543	70	1	8	8
16572	1543	303	2	13	26
16593	1544	1	1	2	2
16594	1544	3	4	3	12
16595	1544	149	1	13	13
16596	1544	114	2	10	20
16597	1544	148	1	17	17
16598	1544	64	1	13	13
16599	1544	46	1	6	6
16600	1544	101	2	3	6
16654	1549	2	1	2	2
16655	1549	57	4	9	36
16656	1549	56	1	12	12
16657	1549	150	1	11	11
16658	1549	339	1	9	9
16659	1549	24	1	8	8
16660	1549	39	2	8	16
16661	1549	116	1	8	8
16727	1551	1	1	2	2
16728	1551	40	1	19	19
16729	1551	3	5	3	15
16730	1551	5	2	3	6
16731	1551	114	1	10	10
16732	1551	165	1	8	8
16733	1551	41	1	15	15
16734	1551	52	2	8	16
16735	1551	51	1	8	8
16763	721	110	1	9	9
16764	721	164	2	9	18
16765	721	1	1	2	2
16766	721	114	1	10	10
16767	721	96	1	8	8
16802	739	1	1	2	2
16803	739	3	2	3	6
16804	739	149	2	13	26
16813	1553	32	1	8	8
16814	1553	114	1	10	10
16815	1553	163	1	8	8
16816	1553	51	1	8	8
16817	1553	52	1	8	8
16818	1553	20	2	8	16
24445	2173	32	2	8	16
17784	1627	3	10	3	30
17798	1633	1	1	2	2
17799	1633	5	4	3	12
17800	1633	3	8	3	24
28779	766	63	1	9	9
13375	1292	1	1	2	2
13376	1292	6	4	3	12
13377	1292	114	1	10	10
13378	1292	105	1	13	13
13379	1292	51	1	8	8
13380	1292	20	1	8	8
13381	1292	25	1	14	14
28780	766	52	1	8	8
28781	766	150	1	11	11
24446	2173	116	1	8	8
24447	2173	51	3	8	24
24448	2173	74	4	8	32
24449	2173	63	2	9	18
24479	2175	1	1	2	2
20673	436	1	1	2	2
20674	436	3	8	3	24
20675	436	57	3	9	27
20676	436	51	1	8	8
20677	436	145	1	8	8
24480	2175	8	3	6	18
24481	2175	27	1	8	8
24482	2175	163	1	8	8
13492	1291	1	1	2	2
13493	1291	3	4	3	12
13494	1291	5	2	3	6
13495	1291	114	1	10	10
13496	1291	106	1	14	14
24483	2175	172	2	13	26
24484	2175	51	1	8	8
15289	1254	1	1	2	2
15290	1254	5	4	3	12
15291	1254	165	1	8	8
15292	1254	340	1	15	15
15293	1254	339	1	9	9
15294	1254	31	1	9	9
15295	1254	46	2	6	12
15296	1254	100	1	17	17
15297	1254	103	1	31	31
15298	1254	112	1	41	41
15299	1449	3	5	3	15
15300	1449	7	2	6	12
15301	1449	8	4	6	24
15302	1449	58	1	13	13
15303	1449	57	1	9	9
15304	1449	129	1	9	9
15305	1449	106	1	14	14
15306	1449	100	1	17	17
15307	1449	62	2	9	18
15308	1449	148	1	17	17
15309	1449	145	1	8	8
15310	1449	96	1	8	8
15311	1449	51	1	8	8
15312	1449	52	1	8	8
15313	1449	46	2	6	12
15314	1449	1	1	2	2
15345	1452	5	3	3	9
15346	1452	3	7	3	21
15347	1452	58	1	13	13
15348	1452	30	1	8	8
15349	1453	29	1	12	12
15350	1453	28	1	12	12
15351	1453	110	1	9	9
15352	1453	58	1	13	13
15353	1453	114	1	10	10
15354	1453	31	1	9	9
15355	1453	3	2	3	6
16388	954	5	5	3	15
16389	954	51	1	8	8
16427	1531	1	1	2	2
16428	1531	5	9	3	27
16429	1531	57	1	9	9
16430	1531	27	1	8	8
16431	1531	96	1	8	8
16432	1531	62	1	9	9
16433	1531	63	1	9	9
16434	1531	51	1	8	8
16462	1534	1	1	2	2
16463	1534	3	6	3	18
16464	1534	32	2	8	16
16465	1534	57	2	9	18
16466	1534	51	1	8	8
16467	1534	116	1	8	8
16496	1536	5	5	3	15
16497	1536	43	1	12	12
16498	1536	334	1	8	8
16499	694	1	1	2	2
16500	694	3	2	3	6
16501	694	33	2	11	22
16502	694	58	1	13	13
16503	694	170	1	17	17
16537	1540	3	2	3	6
16549	1542	2	1	2	2
16550	1542	3	8	3	24
16551	1542	96	1	8	8
16552	1542	213	1	8	8
16553	1542	20	1	8	8
16554	1542	52	1	8	8
16573	1420	32	7	8	56
16574	1420	96	3	8	24
16575	1420	57	4	9	36
16576	1420	44	1	8	8
16577	1420	2	1	2	2
16578	1420	39	4	8	32
16579	1420	1	1	2	2
16624	1229	1	1	2	2
16625	1229	5	2	3	6
16626	1229	3	1	3	3
16627	1229	6	8	3	24
16628	1229	51	1	8	8
16629	1229	58	1	13	13
16646	1548	6	3	3	9
16647	1548	109	1	14	14
16648	1548	172	1	13	13
16649	1548	58	1	13	13
16650	1548	56	2	12	24
16651	1548	52	1	8	8
16652	1548	62	1	9	9
16653	1548	1	1	2	2
16678	163	1	1	2	2
16679	163	3	5	3	15
16680	163	57	2	9	18
16681	163	114	1	10	10
20637	1868	1	1	2	2
20638	1868	41	1	15	15
20639	1868	3	6	3	18
20640	1868	25	1	14	14
20641	1868	149	1	13	13
20642	1868	56	2	12	24
20643	1868	63	1	9	9
20644	1868	64	1	13	13
13414	546	1	1	2	2
13415	546	91	1	8	8
13416	546	32	1	8	8
13417	546	43	1	12	12
13418	546	57	1	9	9
13419	546	33	3	11	33
13420	546	149	1	13	13
13421	546	46	2	6	12
13422	546	315	1	65	65
13423	1147	6	5	3	15
13424	1147	68	1	8	8
13425	1147	52	2	8	16
13426	1147	96	1	8	8
13427	1147	51	1	8	8
13428	1147	116	1	8	8
13429	1147	313	1	16	16
20645	1868	51	1	8	8
20650	1870	1	1	2	2
13461	1295	1	1	2	2
13462	1295	3	3	3	9
13463	1295	57	3	9	27
13464	1295	149	1	13	13
13465	1295	65	1	8	8
13473	1296	148	2	17	34
13474	1296	36	1	8	8
13475	1296	145	1	8	8
13476	1296	32	1	8	8
13477	1296	335	1	5	5
13478	1296	1	1	2	2
13479	1296	149	2	13	26
13486	1294	5	3	3	9
13487	1294	1	1	2	2
13488	1294	31	1	9	9
13489	1294	36	1	8	8
13490	1294	151	1	17	17
13491	1294	75	1	12	12
15529	1467	1	1	2	2
15530	1467	3	6	3	18
15531	1467	7	1	6	6
15532	1467	57	1	9	9
15533	1467	58	1	13	13
15534	1467	100	1	17	17
15544	1468	1	1	2	2
13554	1265	149	1	13	13
13555	1302	105	1	13	13
13556	1302	104	2	13	26
13557	1302	145	1	8	8
13558	1302	64	1	13	13
13559	1302	52	1	8	8
13560	1302	56	3	12	36
13561	1302	63	1	9	9
13562	1302	58	1	13	13
13563	1302	1	2	2	4
13564	1302	186	1	30	30
13568	1301	1	1	2	2
13569	1301	5	3	3	9
13570	1301	3	9	3	27
13590	1305	1	1	2	2
13591	1305	5	5	3	15
13592	1305	4	3	3	9
13593	1305	52	1	8	8
13594	1305	57	1	9	9
13595	1305	333	2	8	16
13599	1307	4	2	3	6
13600	1307	5	1	3	3
13601	1307	105	1	13	13
13602	1306	5	10	3	30
13603	1306	62	1	9	9
13604	1303	5	6	3	18
13605	1303	335	2	5	10
13606	1303	32	1	8	8
13607	1303	114	1	10	10
13608	1303	138	2	8	16
13609	1303	118	1	8	8
13610	1304	1	1	2	2
13611	1304	5	2	3	6
13612	1304	4	1	3	3
13613	1304	24	1	8	8
13614	1304	63	1	9	9
13615	1046	5	6	3	18
13616	1046	52	1	8	8
13617	1046	165	1	8	8
13618	1299	335	2	5	10
13619	1299	1	1	2	2
13620	1299	58	1	13	13
13621	1299	5	8	3	24
13622	1299	61	1	8	8
13623	1299	99	1	12	12
13624	1299	63	2	9	18
13625	1299	43	1	12	12
13626	1298	5	10	3	30
13627	1298	105	1	13	13
13628	1298	63	1	9	9
13629	1298	32	1	8	8
13699	1314	1	1	2	2
13706	1323	1	1	2	2
13707	1323	163	1	8	8
13708	1323	5	7	3	21
13747	1316	1	1	2	2
13748	1316	6	4	3	12
13749	1316	116	1	8	8
13750	1316	51	1	8	8
13759	1319	1	2	2	4
13760	1319	75	4	12	48
13761	1319	130	1	12	12
13762	1319	5	5	3	15
13780	1329	1	1	2	2
13781	1329	4	7	3	21
13782	1329	75	1	12	12
13794	1331	1	1	2	2
13795	1331	4	4	3	12
13796	1331	36	1	8	8
13797	1331	138	1	8	8
15382	1455	63	1	9	9
13700	1315	1	1	2	2
13701	1315	3	8	3	24
13702	1315	96	1	8	8
15383	1455	114	2	10	20
15384	1455	153	1	17	17
15385	1455	130	1	12	12
15386	1455	149	1	13	13
15387	1455	51	1	8	8
15388	1455	165	1	8	8
15389	1455	70	1	8	8
15390	1455	56	1	12	12
13755	1328	1	1	2	2
13756	1328	5	9	3	27
13757	1328	24	1	8	8
13758	1328	58	1	13	13
13770	1321	148	1	17	17
13771	1321	342	1	9	9
13772	1321	144	1	9	9
13773	1321	147	1	8	8
13774	1308	1	1	2	2
13775	1308	5	21	3	63
13776	1308	56	1	12	12
15391	1455	1	1	2	2
17811	1635	32	3	8	24
13825	1333	5	8	3	24
13826	1333	58	1	13	13
17812	1635	96	1	8	8
15433	1459	8	6	6	36
15434	1459	2	1	2	2
20651	1870	3	13	3	39
20652	1834	5	2	3	6
13843	1334	3	7	3	21
13850	1335	5	13	3	39
13851	1335	335	2	5	10
13852	1335	108	1	8	8
13853	1335	151	1	17	17
13854	1335	36	1	8	8
13855	1335	26	1	14	14
20653	1834	114	1	10	10
20654	1834	43	1	12	12
25602	2249	2	1	2	2
25603	2249	40	1	19	19
15443	1460	2	1	2	2
15444	1460	5	6	3	18
15445	1460	20	1	8	8
15446	1460	114	1	10	10
15447	1460	151	1	17	17
15448	1460	51	1	8	8
15449	1460	56	1	12	12
15450	1460	64	1	13	13
25604	2249	27	1	8	8
25605	2249	165	1	8	8
13910	1342	1	1	2	2
13911	1342	110	1	9	9
13912	1342	5	2	3	6
13913	1342	6	1	3	3
25606	2249	58	1	13	13
25607	2249	26	1	14	14
25608	2249	151	1	17	17
25609	2249	130	2	12	24
28798	2478	1	1	2	2
28799	2478	3	2	3	6
15512	1465	1	1	2	2
15513	1465	149	3	13	39
15514	1465	33	2	11	22
15557	1469	1	1	2	2
15558	1469	213	3	8	24
15559	1469	96	1	8	8
15560	1469	63	1	9	9
15670	1474	3	3	3	9
15671	1474	163	1	8	8
15672	1474	32	1	8	8
15673	1474	25	1	14	14
15674	1474	1	1	2	2
15699	1477	1	1	2	2
15700	1477	3	4	3	12
15701	1477	27	1	8	8
15702	1477	32	1	8	8
15703	1477	26	1	14	14
15704	1477	56	1	12	12
15763	1481	3	5	3	15
15764	1481	163	2	8	16
15765	1481	5	2	3	6
15766	1481	57	1	9	9
15767	1481	105	1	13	13
15768	1481	114	1	10	10
15769	1481	110	1	9	9
15770	1481	1	1	2	2
15849	742	1	1	2	2
15850	742	6	4	3	12
15851	742	3	1	3	3
15852	742	43	1	12	12
15853	742	52	1	8	8
15854	742	62	1	9	9
15855	742	63	1	9	9
15856	742	157	1	17	17
15857	742	150	2	11	22
15858	742	105	1	13	13
15859	742	20	1	8	8
15860	742	46	2	6	12
16449	1533	1	1	2	2
16450	1533	3	4	3	12
16451	1533	52	1	8	8
16452	1533	116	1	8	8
16453	1533	56	1	12	12
16454	1478	5	10	3	30
16455	1478	2	1	2	2
16512	1538	1	1	2	2
16513	1538	3	8	3	24
16525	1541	1	1	2	2
16526	1541	6	10	3	30
16527	1541	114	1	10	10
16528	1541	32	1	8	8
16529	1541	55	1	8	8
16530	1541	164	1	9	9
16601	1545	1	1	2	2
16602	1545	3	3	3	9
16603	1545	114	2	10	20
16604	1545	165	1	8	8
16605	1545	334	1	8	8
16612	1546	3	10	3	30
16613	1546	1	1	2	2
13676	1309	1	1	2	2
13677	1309	5	3	3	9
13678	1309	3	1	3	3
13679	1309	57	1	9	9
13680	1309	32	1	8	8
15402	1456	2	1	2	2
15403	1456	3	2	3	6
15404	1456	5	3	3	9
15405	1456	151	2	17	34
13685	1311	6	12	3	36
13686	1311	57	1	9	9
13687	1311	64	1	13	13
13688	1311	2	2	2	4
13690	1318	1	1	2	2
13691	1318	3	5	3	15
13692	1318	6	2	3	6
13693	1318	57	2	9	18
13694	1318	52	1	8	8
13695	1318	64	1	13	13
15406	1456	58	1	13	13
13718	1324	1	1	2	2
13719	1324	4	5	3	15
13720	1324	6	10	3	30
13721	1324	129	2	9	18
13722	1324	57	1	9	9
13723	1324	335	3	5	15
13724	1324	51	2	8	16
13725	1324	116	1	8	8
13731	1282	5	6	3	18
13732	1282	151	2	17	34
13733	1282	63	1	9	9
15407	1456	57	1	9	9
15408	1456	56	1	12	12
15409	1456	149	2	13	26
15410	1456	132	1	17	17
15411	1456	40	1	19	19
13739	1325	165	1	8	8
13742	1327	1	1	2	2
13743	1327	335	1	5	5
13744	1327	110	1	9	9
13745	1327	36	1	8	8
13746	1327	27	1	8	8
15412	1450	1	1	2	2
15413	1450	3	5	3	15
15414	1450	5	5	3	15
28800	2478	28	1	12	12
28801	2478	64	1	13	13
28802	2478	96	1	8	8
15420	1454	1	1	2	2
13791	1330	1	1	2	2
13792	1330	5	8	3	24
13793	1330	4	2	3	6
13806	167	1	2	2	4
13807	167	5	2	3	6
13808	167	4	3	3	9
13809	167	57	1	9	9
13810	167	335	1	5	5
13811	167	339	1	9	9
13812	167	193	1	22	22
13830	1310	1	1	2	2
13831	1310	5	6	3	18
13837	324	333	2	8	16
13838	324	96	2	8	16
13839	324	20	1	8	8
13840	324	57	1	9	9
13841	324	4	1	3	3
15421	1454	3	7	3	21
13859	1336	1	1	2	2
13860	1336	36	1	8	8
13861	1336	62	1	9	9
13878	1338	1	1	2	2
13879	1338	5	3	3	9
13880	1338	4	2	3	6
13881	1338	116	2	8	16
13882	1338	62	1	9	9
13883	1338	340	1	15	15
13884	1338	56	1	12	12
15429	1458	3	8	3	24
15430	1458	1	1	2	2
15456	1461	5	5	3	15
15457	1461	116	2	8	16
15458	1461	64	1	13	13
15459	1461	51	1	8	8
15460	1461	1	1	2	2
13939	1343	4	7	3	21
13940	1343	57	1	9	9
13941	1343	31	1	9	9
13942	1343	51	1	8	8
13943	1343	138	1	8	8
13944	1343	149	2	13	26
13945	1343	145	1	8	8
13946	1343	32	1	8	8
13947	1343	20	1	8	8
15477	1462	1	1	2	2
15478	1462	6	6	3	18
15479	1462	7	1	6	6
15480	1462	8	3	6	18
15481	1462	43	1	12	12
15482	1462	57	1	9	9
15483	1462	58	1	13	13
15484	1462	52	1	8	8
15485	1462	63	1	9	9
15486	1462	31	1	9	9
15495	136	3	1	3	3
15496	136	5	3	3	9
15497	136	44	3	8	24
15498	136	114	1	10	10
15499	136	57	1	9	9
15500	136	51	1	8	8
15501	136	52	2	8	16
15502	136	1	1	2	2
15506	1464	1	1	2	2
15507	1464	3	7	3	21
15508	1464	5	4	3	12
15519	1466	1	1	2	2
15520	1466	6	3	3	9
15521	1466	3	3	3	9
15522	1466	191	1	30	30
15589	529	1	1	2	2
15590	529	5	8	3	24
15607	515	24	3	8	24
15608	515	3	2	3	6
15609	515	26	1	14	14
13798	1331	32	1	8	8
15545	1468	129	1	9	9
15546	1468	66	1	8	8
20655	1834	32	1	8	8
20656	1834	120	1	18	18
20657	1834	63	1	9	9
20658	1834	64	1	13	13
24485	2175	64	1	13	13
28803	2478	114	1	10	10
28812	2477	1	1	2	2
28813	2477	6	12	3	36
13818	1332	1	1	2	2
13819	1332	5	10	3	30
13820	1332	114	2	10	20
13821	1332	172	1	13	13
13822	1332	148	1	17	17
24496	2177	1	1	2	2
24497	2177	5	8	3	24
24498	2177	32	1	8	8
24499	2177	319	1	14	14
24500	2177	142	1	9	9
28846	1160	1	1	2	2
28847	1160	58	3	13	39
28848	1160	51	1	8	8
13866	1337	1	1	2	2
13867	1337	62	1	9	9
13868	1337	63	1	9	9
13869	1337	70	1	8	8
13870	1337	190	1	30	30
13890	1339	5	8	3	24
13891	1339	1	1	2	2
13892	1339	3	2	3	6
13893	1339	109	1	14	14
13894	1339	151	1	17	17
28849	1160	100	1	17	17
13996	1357	1	1	2	2
13997	1357	311	4	30	120
13998	1357	312	1	30	30
13999	1357	310	1	15	15
14003	452	1	1	2	2
14004	452	57	2	9	18
14005	452	56	1	12	12
14006	1317	311	5	30	150
14007	1317	307	1	24	24
14013	1358	282	2	34	68
14014	1358	278	1	18	18
14015	1358	113	2	25	50
14016	1358	1	1	2	2
14017	1358	149	2	13	26
14018	1358	271	2	24	48
14029	1152	1	1	2	2
14030	1152	114	1	10	10
14031	1152	31	1	9	9
14032	1152	57	1	9	9
14033	1152	52	1	8	8
14034	1152	56	2	12	24
14035	1152	320	1	14	14
14036	1152	161	1	8	8
14041	1346	4	8	3	24
14042	1346	333	1	8	8
14043	1347	5	5	3	15
14044	1347	3	5	3	15
14049	1360	1	1	2	2
14050	1360	6	6	3	18
14051	1360	30	1	8	8
14052	1360	46	1	6	6
14057	1349	3	2	3	6
14058	1349	333	1	8	8
14059	1349	34	1	8	8
14060	1349	150	1	11	11
14063	1350	1	1	2	2
14064	1350	4	5	3	15
14065	1351	130	1	12	12
14066	1352	1	1	2	2
14067	1352	5	2	3	6
14068	1352	51	1	8	8
14069	1352	55	1	8	8
14070	1353	342	1	9	9
14071	1353	150	1	11	11
14072	1354	2	1	2	2
14073	1354	5	3	3	9
14074	1355	307	1	24	24
14075	1355	311	1	30	30
14076	797	145	1	8	8
14077	797	30	1	8	8
14078	797	57	1	9	9
14079	797	51	2	8	16
14080	797	6	1	3	3
14081	1341	1	1	2	2
14082	1341	110	1	9	9
14083	1341	150	1	11	11
14084	1341	151	1	17	17
14085	1341	56	1	12	12
14086	1341	319	1	14	14
14087	1341	64	1	13	13
14088	1340	4	1	3	3
14089	1340	20	1	8	8
14090	1340	56	1	12	12
14091	1340	34	1	8	8
14092	1214	1	1	2	2
14093	1214	335	5	5	25
14094	1214	26	1	14	14
14095	1214	315	1	65	65
14117	1363	1	1	2	2
14118	1363	4	6	3	18
14119	1363	130	1	12	12
14127	594	1	1	2	2
14128	594	6	5	3	15
14129	594	46	3	6	18
14138	1280	1	1	2	2
14139	1280	123	1	18	18
14140	1280	149	2	13	26
14141	1280	334	1	8	8
14142	1280	51	1	8	8
14154	1366	267	1	39	39
14155	1366	131	1	22	22
14160	1367	1	1	2	2
14178	1368	1	1	2	2
14179	1368	4	4	3	12
14143	1280	52	1	8	8
14144	1280	113	1	25	25
14145	1280	263	1	10	10
15547	1468	114	1	10	10
15548	1468	24	1	8	8
15549	1468	151	1	17	17
14149	1365	273	1	69	69
14150	1365	267	1	39	39
14151	1365	19	1	15	15
15550	1468	27	1	8	8
15551	1468	52	1	8	8
15552	1468	71	1	8	8
15569	1470	1	1	2	2
14168	210	1	1	2	2
14169	210	6	2	3	6
14170	210	3	1	3	3
14171	210	52	1	8	8
14176	238	260	1	16	16
14177	238	264	1	10	10
14182	1369	3	6	3	18
14183	1369	30	1	8	8
15570	1470	3	7	3	21
15571	1470	5	5	3	15
15572	1470	114	1	10	10
14212	1372	41	1	15	15
14213	1372	24	1	8	8
14214	1372	51	1	8	8
14215	1372	114	1	10	10
14216	1372	2	1	2	2
15573	1470	20	1	8	8
15574	1470	96	2	8	16
15575	1470	62	1	9	9
15576	1470	333	1	8	8
20659	1834	51	1	8	8
14222	1371	1	1	2	2
14223	1371	3	5	3	15
14224	1371	57	1	9	9
14225	1373	2	1	2	2
14226	1373	36	1	8	8
14227	1373	62	2	9	18
14228	1373	149	5	13	65
14229	1373	113	2	25	50
14235	792	6	11	3	33
14236	792	110	1	9	9
14237	792	344	2	11	22
14238	792	51	1	8	8
14239	792	1	1	2	2
14240	792	46	2	6	12
20660	1834	46	4	6	24
24501	2177	26	1	14	14
15617	1472	1	1	2	2
15618	1472	5	9	3	27
15619	1472	41	1	15	15
15620	1472	51	1	8	8
15638	1473	3	4	3	12
15639	1473	5	3	3	9
15640	1473	230	2	12	24
15641	1473	96	1	8	8
15642	1473	27	1	8	8
15643	1473	38	1	8	8
14284	1377	1	1	2	2
14285	1377	40	2	19	38
14286	1377	5	8	3	24
14287	1377	35	1	17	17
14288	1377	58	1	13	13
14289	1377	25	1	14	14
14290	1377	64	1	13	13
14291	1377	320	1	14	14
14292	1377	148	1	17	17
14301	1378	2	1	2	2
14302	1378	6	6	3	18
14303	1378	8	3	6	18
14304	1378	7	3	6	18
14305	1378	148	1	17	17
14306	1378	29	1	12	12
14307	1378	46	1	6	6
14308	1378	303	3	13	39
14313	1379	6	9	3	27
14314	1379	5	1	3	3
14315	1379	7	1	6	6
14316	1379	1	1	2	2
15644	830	1	1	2	2
15645	830	3	5	3	15
15646	830	149	3	13	39
14320	1380	46	2	6	12
14321	1380	5	1	3	3
14322	1380	32	1	8	8
15647	830	342	2	9	18
15648	830	25	1	14	14
15649	830	26	1	14	14
15650	830	30	1	8	8
15651	830	52	1	8	8
15652	830	104	1	13	13
15653	830	20	1	8	8
15654	830	116	1	8	8
17846	1639	1	1	2	2
17847	1639	335	2	5	10
17848	1639	5	7	3	21
14355	1381	1	1	2	2
14356	1381	6	11	3	33
14357	1381	7	2	6	12
14358	1381	8	1	6	6
15684	1476	2	1	2	2
15685	1476	43	1	12	12
15686	1476	114	1	10	10
15687	1476	96	1	8	8
15688	1476	104	1	13	13
15689	1476	31	1	9	9
15690	1476	24	2	8	16
15691	1476	52	1	8	8
15692	1476	131	2	22	44
28835	2466	5	1	3	3
28836	2466	3	4	3	12
28837	2466	57	1	9	9
28838	2466	149	1	13	13
28839	2466	242	1	8	8
15780	1482	3	4	3	12
15781	1482	5	5	3	15
15782	1482	8	4	6	24
15783	1482	120	1	18	18
15784	1482	40	1	19	19
15785	1482	2	1	2	2
14161	1367	148	1	17	17
14162	1367	31	1	9	9
14163	1367	57	1	9	9
15610	515	25	1	14	14
15611	515	145	1	8	8
15612	515	1	1	2	2
15665	1475	1	1	2	2
15666	1475	5	1	3	3
15667	1475	27	2	8	16
15668	1475	58	1	13	13
15669	1475	40	1	19	19
17829	1637	1	1	2	2
14191	882	1	1	2	2
14192	882	3	8	3	24
14193	882	129	1	9	9
14194	882	51	1	8	8
14195	882	57	1	9	9
14196	882	56	1	12	12
14197	882	46	1	6	6
17830	1637	5	3	3	9
17831	1637	113	1	25	25
15723	1479	43	1	12	12
15724	1479	25	1	14	14
15725	1479	114	2	10	20
15726	1479	30	1	8	8
15727	1479	106	1	14	14
15728	1479	62	1	9	9
15729	1479	149	1	13	13
15730	1479	56	1	12	12
15731	1479	51	2	8	16
15732	1479	339	2	9	18
14261	1376	1	2	2	4
14262	1376	5	1	3	3
14263	1376	3	12	3	36
14264	1376	114	1	10	10
14265	1376	106	1	14	14
14266	1376	25	2	14	28
14267	1376	150	1	11	11
14268	1376	51	1	8	8
15733	1479	116	1	8	8
15734	1479	1	1	2	2
15745	1480	2	1	2	2
15746	1480	3	5	3	15
15747	1480	43	1	12	12
15748	1480	44	1	8	8
15749	1480	114	1	10	10
15750	1480	74	1	8	8
15751	1480	120	3	18	54
15752	1480	57	1	9	9
15753	1480	151	1	17	17
15754	1480	100	1	17	17
17832	1637	149	2	13	26
17833	1637	56	2	12	24
14341	1382	1	2	2	4
14342	1382	5	10	3	30
14343	1382	104	1	13	13
14344	1382	323	1	20	20
14345	1382	149	1	13	13
14346	1382	58	1	13	13
14347	1382	130	1	12	12
14348	1382	109	1	14	14
14349	1382	24	1	8	8
14350	1382	100	1	17	17
14351	1382	274	1	15	15
14352	1382	192	2	30	60
14353	1382	7	4	6	24
14354	1382	8	2	6	12
17834	1637	64	1	13	13
15801	1483	2	1	2	2
15802	1483	230	1	12	12
15803	1483	26	1	14	14
15804	1483	46	2	6	12
15805	1484	2	1	2	2
15806	1484	3	3	3	9
15807	1485	1	1	2	2
15808	1485	6	1	3	3
15809	1485	52	1	8	8
15810	1485	63	2	9	18
14370	1383	129	1	9	9
14371	1383	114	1	10	10
14372	1383	35	1	17	17
14373	1383	58	1	13	13
14374	1383	150	1	11	11
14375	1383	151	1	17	17
14376	1383	28	1	12	12
14377	1383	56	1	12	12
14378	1383	41	1	15	15
14379	1383	326	3	13	39
14380	1383	2	1	2	2
17835	1637	190	1	30	30
15819	1486	1	1	2	2
15820	1486	5	6	3	18
15821	1486	32	1	8	8
15822	1486	114	1	10	10
15823	1486	120	2	18	36
15824	1486	106	1	14	14
15825	1486	339	1	9	9
15826	1486	145	1	8	8
15844	1487	1	1	2	2
15845	1487	3	1	3	3
15846	1487	44	1	8	8
15847	1487	63	1	9	9
15848	1487	20	1	8	8
16682	163	8	2	6	12
16683	163	165	1	8	8
16684	163	52	1	8	8
16779	450	5	5	3	15
16780	450	3	5	3	15
16781	450	41	1	15	15
16782	450	149	3	13	39
16783	450	33	1	11	11
16784	450	213	1	8	8
16785	450	52	1	8	8
16786	450	32	1	8	8
16787	450	116	1	8	8
16788	450	58	1	13	13
16789	450	1	2	2	4
16844	231	1	1	2	2
16845	231	8	3	6	18
16846	231	172	1	13	13
16847	231	63	1	9	9
16848	231	110	2	9	18
16849	231	114	1	10	10
16850	231	113	1	25	25
16861	1555	3	7	3	21
16862	1555	5	1	3	3
16863	1555	7	1	6	6
16864	1555	113	1	25	25
16867	1092	3	2	3	6
16868	1092	5	3	3	9
16869	1092	46	2	6	12
16870	1092	1	1	2	2
28840	2466	51	1	8	8
14201	1370	3	12	3	36
14202	1370	30	1	8	8
14203	1370	2	1	2	2
14245	1374	2	1	2	2
14246	1374	113	1	25	25
14247	1374	36	1	8	8
14248	1374	320	1	14	14
14251	1375	1	1	2	2
14252	1375	6	10	3	30
15875	1489	1	1	2	2
15876	1489	43	2	12	24
15877	1489	57	2	9	18
15898	1118	5	6	3	18
15899	1118	43	2	12	24
15900	1118	58	1	13	13
15901	1118	57	1	9	9
14273	406	1	1	2	2
14274	406	5	8	3	24
15902	1118	114	1	10	10
15903	1118	56	1	12	12
15904	1118	46	1	6	6
14388	1384	1	1	2	2
14389	1384	6	5	3	15
14390	1384	4	1	3	3
14391	1384	3	3	3	9
14392	1384	27	1	8	8
14393	1384	51	1	8	8
14394	1384	52	1	8	8
14405	1385	1	1	2	2
14406	1385	9	2	12	24
14407	1385	116	3	8	24
14408	1385	323	1	20	20
14409	1385	57	4	9	36
14410	1385	63	1	9	9
14411	1385	172	2	13	26
14412	1385	24	2	8	16
14413	1385	51	2	8	16
14414	1385	52	2	8	16
14423	1386	2	1	2	2
14424	1386	6	8	3	24
14425	1386	113	1	25	25
14426	1387	2	1	2	2
14427	1387	3	7	3	21
14428	1387	165	3	8	24
14429	1387	340	1	15	15
14430	1387	116	1	8	8
14438	768	1	1	2	2
14439	768	57	3	9	27
14440	768	104	1	13	13
14441	768	35	1	17	17
14442	768	64	2	13	26
14443	768	30	1	8	8
14444	768	101	3	3	9
14452	1388	2	1	2	2
14453	1388	6	10	3	30
14454	1389	1	1	2	2
14455	1389	8	1	6	6
14456	1389	26	1	14	14
14457	1389	129	1	9	9
14458	1389	43	1	12	12
14461	1390	9	1	12	12
14462	1390	5	13	3	39
14470	1391	1	1	2	2
14471	1391	9	2	12	24
14472	1391	7	2	6	12
14473	1391	8	1	6	6
14474	1391	157	1	17	17
14475	1391	46	2	6	12
14476	1391	100	1	17	17
14481	1392	1	1	2	2
14482	1392	9	1	12	12
14483	1392	213	2	8	16
14484	1392	57	1	9	9
14491	774	1	1	2	2
14492	774	5	4	3	12
14493	774	58	2	13	26
14494	774	26	1	14	14
14495	774	63	1	9	9
14496	774	313	1	16	16
14501	1085	1	1	2	2
14502	1085	5	4	3	12
14503	1085	70	1	8	8
14504	1085	129	1	9	9
14522	1394	1	1	2	2
14523	1394	3	16	3	48
14524	1394	5	1	3	3
14535	1395	1	1	2	2
14536	1395	96	4	8	32
14537	1396	1	1	2	2
14538	1396	6	3	3	9
14539	1396	5	1	3	3
14540	1396	57	2	9	18
14541	1396	63	2	9	18
14542	1396	172	2	13	26
14543	1396	130	1	12	12
14544	1396	116	1	8	8
14563	950	52	1	8	8
14564	950	342	1	9	9
14565	1393	1	2	2	4
14566	1393	5	13	3	39
14567	1393	9	1	12	12
14568	1393	315	1	65	65
14569	1393	3	1	3	3
14570	1393	32	1	8	8
14571	1393	35	2	17	34
14572	1393	172	2	13	26
14573	1393	41	1	15	15
14574	1393	342	1	9	9
14575	1393	56	2	12	24
14576	1393	130	1	12	12
14577	1393	29	1	12	12
14578	1393	100	1	17	17
14579	1393	282	1	34	34
14580	1393	278	1	18	18
14587	1322	1	1	2	2
14588	1322	3	3	3	9
14589	1322	32	1	8	8
14590	1322	58	2	13	26
14591	1322	52	1	8	8
14592	1322	116	1	8	8
14600	460	1	1	2	2
14601	460	3	6	3	18
14612	1313	1	1	2	2
14613	1313	113	1	25	25
14614	1313	4	4	3	12
14615	1313	8	2	6	12
14616	1313	7	2	6	12
14617	1313	149	1	13	13
14646	1399	3	4	3	12
14647	1399	32	3	8	24
14648	1399	43	1	12	12
14649	1399	36	1	8	8
14650	1399	96	4	8	32
14651	1399	25	1	14	14
14652	1399	63	1	9	9
14690	1402	2	1	2	2
14691	1402	36	1	8	8
14692	1402	32	1	8	8
14693	1402	58	1	13	13
14694	1402	26	1	14	14
14695	1402	51	1	8	8
14696	1402	52	1	8	8
14697	1402	118	1	8	8
14698	1402	75	1	12	12
14699	1402	46	2	6	12
14700	1402	159	1	17	17
14701	1402	157	1	17	17
28841	2466	52	1	8	8
28842	2466	110	1	9	9
25623	2250	1	1	2	2
25624	2250	57	1	9	9
25625	2250	96	1	8	8
14742	1407	1	1	2	2
14743	1407	3	8	3	24
14744	1407	52	3	8	24
14745	1407	116	2	8	16
25626	2250	62	1	9	9
25627	2250	63	1	9	9
25628	2250	114	1	10	10
25629	2250	116	2	8	16
25630	2250	151	1	17	17
25631	2250	130	1	12	12
25632	2250	51	1	8	8
25633	2250	52	1	8	8
15922	1490	5	6	3	18
15962	1495	1	1	2	2
15963	1495	5	4	3	12
15964	1495	43	1	12	12
15965	1495	114	1	10	10
15966	1495	20	1	8	8
15967	1495	25	1	14	14
15968	1495	130	1	12	12
16039	1500	1	1	2	2
16040	1500	6	4	3	12
16041	1500	3	2	3	6
16042	1500	32	1	8	8
16043	1500	145	1	8	8
16044	1500	56	1	12	12
16045	1500	334	1	8	8
16046	1500	20	1	8	8
16047	1500	51	1	8	8
16048	1500	46	1	6	6
16049	1500	151	1	17	17
16050	1500	149	1	13	13
16101	1506	2	1	2	2
16102	1506	6	10	3	30
16138	1440	5	2	3	6
16139	1440	3	4	3	12
16140	1440	110	1	9	9
16141	1440	63	2	9	18
16142	1440	271	1	24	24
16169	1512	3	10	3	30
16170	1512	43	2	12	24
16171	1512	57	2	9	18
16172	1512	114	1	10	10
16173	1512	52	1	8	8
16174	1512	46	3	6	18
16175	1512	1	1	2	2
16284	1520	1	1	2	2
16285	1520	6	1	3	3
16286	1520	96	2	8	16
16287	1520	57	1	9	9
16288	1520	51	1	8	8
16289	1520	46	1	6	6
16298	1521	63	1	9	9
16299	1521	116	1	8	8
16300	1521	193	1	22	22
16301	1521	2	1	2	2
16302	1521	6	2	3	6
16303	1521	25	1	14	14
16304	1521	56	1	12	12
16305	1521	62	1	9	9
16318	1523	1	1	2	2
16319	1523	3	5	3	15
16328	1505	6	5	3	15
16329	1505	3	1	3	3
16330	1505	114	1	10	10
16331	1505	36	2	8	16
16332	1505	319	1	14	14
16333	1505	1	1	2	2
16373	1528	120	1	18	18
16374	1528	342	2	9	18
16375	1528	56	1	12	12
16376	1528	63	1	9	9
16377	1528	64	1	13	13
16378	1528	142	1	9	9
16379	1528	46	4	6	24
16380	1528	1	1	2	2
16381	1528	58	4	13	52
16706	1550	5	4	3	12
16707	1550	64	2	13	26
16708	1550	104	3	13	39
16709	1550	56	1	12	12
16710	1550	145	1	8	8
16711	1550	51	1	8	8
16712	1550	40	1	19	19
16713	1550	1	1	2	2
16749	1552	1	1	2	2
16750	1552	129	1	9	9
16751	1552	32	1	8	8
16752	1552	96	2	8	16
16753	1552	57	1	9	9
16754	1552	149	1	13	13
16755	1552	51	2	8	16
16756	1552	56	1	12	12
16757	1552	46	2	6	12
17849	1639	110	1	9	9
17850	1639	167	2	8	16
28850	1160	258	1	3	3
28851	1160	259	1	3	3
14660	475	319	3	14	42
14661	475	170	1	17	17
14662	475	292	1	50	50
14663	475	282	1	34	34
14664	1401	1	1	2	2
14665	1401	9	2	12	24
14666	1401	4	5	3	15
14667	1401	57	1	9	9
14668	1397	5	17	3	51
17851	1639	52	1	8	8
17890	1642	1	1	2	2
15940	1493	5	7	3	21
15941	1493	6	7	3	21
15942	1493	2	1	2	2
15944	1494	3	5	3	15
14803	1410	1	1	2	2
14804	1410	4	6	3	18
14805	1410	9	1	12	12
14806	1410	30	1	8	8
14807	1410	145	1	8	8
14808	1410	51	1	8	8
14809	1410	57	1	9	9
14810	1410	62	1	9	9
14811	1410	63	1	9	9
14812	1410	32	1	8	8
14813	1410	31	1	9	9
14814	1410	116	1	8	8
14815	1410	342	1	9	9
14837	1412	40	2	19	38
14838	1412	8	6	6	36
14839	1412	46	5	6	30
14840	1412	172	1	13	13
14841	1412	5	6	3	18
16028	1501	2	1	2	2
16029	1501	5	3	3	9
16030	1501	3	1	3	3
16031	1501	149	4	13	52
16051	1502	1	1	2	2
16052	1502	3	4	3	12
16053	1502	6	1	3	3
16054	1502	30	1	8	8
16055	1502	52	1	8	8
16056	1502	46	2	6	12
16057	1502	113	1	25	25
16128	1511	2	1	2	2
16129	1511	3	2	3	6
16130	1511	31	1	9	9
16131	1511	8	3	6	18
16132	1511	311	1	30	30
25784	2260	1	1	2	2
25785	2260	5	4	3	12
25786	2260	58	3	13	39
25787	2260	151	1	17	17
16158	417	1	1	2	2
16159	417	7	1	6	6
16160	417	8	1	6	6
16161	417	26	1	14	14
16162	417	151	1	17	17
16163	417	74	2	8	16
16164	417	105	1	13	13
16165	417	101	1	3	3
25788	2260	150	1	11	11
25789	2260	34	1	8	8
25790	2260	52	1	8	8
25791	2260	131	1	22	22
25797	2261	1	1	2	2
25798	2261	114	2	10	20
16208	1514	1	1	2	2
16209	1514	3	2	3	6
16210	1514	32	1	8	8
16211	1514	120	2	18	36
16212	1514	43	1	12	12
16213	1514	52	1	8	8
16214	1514	58	1	13	13
16215	1514	62	1	9	9
16216	1514	319	1	14	14
16217	1514	106	1	14	14
16218	1514	151	1	17	17
16219	1514	157	1	17	17
16232	1517	5	3	3	9
16233	1517	131	4	22	88
16234	1517	167	1	8	8
16235	1517	149	3	13	39
16236	1517	46	2	6	12
16237	1517	343	1	11	11
16238	1517	58	1	13	13
16239	1517	130	1	12	12
16240	1517	1	1	2	2
16275	1519	2	1	2	2
16276	1519	51	3	8	24
16277	1519	57	1	9	9
16311	1522	2	1	2	2
16312	1522	3	10	3	30
16313	1522	105	1	13	13
16314	1522	104	1	13	13
16315	1522	62	1	9	9
16334	1525	3	6	3	18
16335	1525	32	1	8	8
16336	1525	342	1	9	9
16337	1525	339	1	9	9
15905	1118	145	1	8	8
15906	1118	163	1	8	8
14657	1400	4	4	3	12
14658	1400	57	2	9	18
14659	1400	51	1	8	8
20670	1867	52	1	8	8
20671	1867	40	1	19	19
20672	1867	1	1	2	2
24519	2178	1	1	2	2
15907	1118	8	1	6	6
15908	1118	1	1	2	2
24520	2178	213	1	8	8
14709	1260	1	1	2	2
14710	1260	4	4	3	12
14711	1260	120	2	18	36
14712	1260	7	1	6	6
14713	1260	8	1	6	6
14714	1260	100	1	17	17
14715	1260	26	1	14	14
14716	1260	64	1	13	13
14717	1260	320	2	14	28
14722	1404	7	3	6	18
14723	1404	25	1	14	14
14724	1404	149	1	13	13
14725	1405	1	1	2	2
14726	1405	8	3	6	18
14727	1405	7	2	6	12
14728	1405	100	1	17	17
24521	2178	57	1	9	9
24522	2178	51	2	8	16
24523	2178	27	1	8	8
14732	1406	1	1	2	2
14733	1406	4	4	3	12
14734	1406	46	4	6	24
14735	1406	193	1	22	22
14758	740	2	1	2	2
14759	740	74	1	8	8
14760	740	36	1	8	8
14761	740	27	1	8	8
14762	740	120	1	18	18
14763	740	96	1	8	8
14764	740	56	1	12	12
14765	740	63	1	9	9
14766	740	58	1	13	13
14767	740	64	1	13	13
14768	740	52	2	8	16
14769	740	157	1	17	17
15950	110	303	1	13	13
15951	110	6	3	3	9
15952	110	149	4	13	52
15953	110	113	1	25	25
15954	110	1	1	2	2
24524	2178	63	1	9	9
24525	2178	114	1	10	10
24526	2178	334	2	8	16
14794	1409	57	2	9	18
14795	1409	334	1	8	8
14796	1409	51	1	8	8
14797	1409	52	1	8	8
14798	1409	109	1	14	14
14799	1409	339	1	9	9
14800	1409	63	1	9	9
14801	1409	46	1	6	6
14802	1409	1	1	2	2
14855	867	5	6	3	18
14856	867	4	3	3	9
16017	1499	5	5	3	15
16018	1499	3	1	3	3
16019	1499	149	2	13	26
16020	1499	63	2	9	18
16021	1499	157	1	17	17
16022	1499	29	1	12	12
16023	1499	116	1	8	8
16024	1499	120	1	18	18
16025	1499	96	1	8	8
16026	1499	263	1	10	10
16027	1499	347	1	13	13
16064	1503	1	1	2	2
16065	1503	3	3	3	9
16066	1503	32	1	8	8
16067	1503	114	1	10	10
16068	1503	52	1	8	8
16069	1503	46	1	6	6
16082	1504	1	1	2	2
16083	1504	3	4	3	12
16084	1504	57	2	9	18
16085	1504	114	1	10	10
16086	1504	46	1	6	6
16087	1504	145	1	8	8
16121	1508	1	1	2	2
16122	1508	6	9	3	27
16123	1508	149	5	13	65
16124	1510	1	1	2	2
16125	1510	6	6	3	18
16126	1510	7	1	6	6
16127	1510	8	2	6	12
16198	1515	1	1	2	2
16199	1515	3	3	3	9
16200	1515	33	1	11	11
16201	1515	340	1	15	15
16202	1515	52	1	8	8
16203	1515	56	1	12	12
16204	1515	46	1	6	6
16253	414	1	1	2	2
16254	414	6	7	3	21
16255	414	3	8	3	24
16256	1518	5	1	3	3
16257	1518	3	4	3	12
16258	1518	319	1	14	14
16259	1518	57	1	9	9
16260	1518	70	1	8	8
16261	1518	149	1	13	13
16262	1518	51	1	8	8
16263	1518	63	1	9	9
16264	1518	142	1	9	9
16265	1488	1	1	2	2
16266	1488	5	3	3	9
16267	1488	3	3	3	9
16851	231	153	1	17	17
16852	231	311	1	30	30
17871	349	1	1	2	2
17872	349	3	5	3	15
17873	349	335	2	5	10
17874	349	62	1	9	9
17875	349	51	1	8	8
17876	349	145	1	8	8
20763	1874	1	1	2	2
20764	1874	120	2	18	36
20765	1874	114	1	10	10
20766	1874	142	1	9	9
17895	1626	1	1	2	2
17896	1626	6	10	3	30
20767	1874	159	1	17	17
20768	1874	36	1	8	8
20769	1874	165	1	8	8
20770	1874	51	1	8	8
20771	1874	172	2	13	26
20772	1874	58	1	13	13
20773	1874	339	1	9	9
20811	1876	1	2	2	4
20812	1876	6	10	3	30
20813	1876	3	13	3	39
17980	1648	1	1	2	2
17981	1648	3	5	3	15
17982	1648	5	1	3	3
17983	1648	27	1	8	8
17984	1648	32	1	8	8
17985	1648	96	3	8	24
24545	2182	1	1	2	2
24546	2182	3	7	3	21
24547	2182	5	2	3	6
24548	2182	96	1	8	8
20877	1881	5	3	3	9
20878	1881	63	2	9	18
20879	1881	57	2	9	18
20880	1881	150	2	11	22
20881	1881	51	2	8	16
20882	1881	335	1	5	5
18091	1659	1	1	2	2
18092	1659	5	10	3	30
18093	1659	114	1	10	10
18094	1659	129	1	9	9
18095	1659	32	1	8	8
18096	1659	51	2	8	16
18097	1659	116	2	8	16
18098	1659	163	1	8	8
20883	1881	96	1	8	8
20884	1881	64	1	13	13
20885	1881	32	1	8	8
20886	1881	116	1	8	8
20887	1881	24	1	8	8
18139	1663	1	1	2	2
18140	1663	5	12	3	36
18141	1663	110	1	9	9
18142	1663	116	1	8	8
18143	1663	51	1	8	8
20888	1881	92	1	9	9
20889	1881	1	1	2	2
20931	1586	1	1	2	2
20932	1586	120	1	18	18
20933	1586	40	1	19	19
20934	1586	46	1	6	6
24549	2182	342	1	9	9
24550	2182	132	1	17	17
24562	2181	1	1	2	2
20939	1884	1	1	2	2
20940	1884	3	4	3	12
20941	1884	129	1	9	9
20942	1884	43	1	12	12
20943	1884	114	1	10	10
20944	1884	96	1	8	8
20945	1884	63	1	9	9
20946	1884	51	1	8	8
18215	1675	1	1	2	2
18216	1675	5	5	3	15
18217	1675	32	2	8	16
18218	1675	120	1	18	18
18219	1675	149	1	13	13
18229	1670	5	3	3	9
18230	1670	3	6	3	18
18231	1670	130	1	12	12
18232	1674	5	6	3	18
18233	1674	335	1	5	5
18234	1674	1	1	2	2
18235	1674	64	1	13	13
18236	1676	1	1	2	2
18237	1676	5	5	3	15
18238	1676	3	3	3	9
18239	1001	3	6	3	18
18240	1001	5	3	3	9
18241	1001	1	1	2	2
18242	1001	116	1	8	8
18243	1001	62	1	9	9
18244	1647	1	1	2	2
18245	1647	5	6	3	18
18246	1647	157	1	17	17
18251	1650	1	1	2	2
18252	1650	5	6	3	18
18253	1669	1	1	2	2
18254	1669	5	2	3	6
18255	1669	3	10	3	30
18256	571	1	1	2	2
18257	571	5	2	3	6
18258	571	24	1	8	8
18259	571	99	1	12	12
18260	1660	1	1	2	2
18261	1660	3	5	3	15
18262	1660	52	1	8	8
18263	1660	62	1	9	9
18264	1660	172	1	13	13
18265	1644	1	1	2	2
18266	1644	5	7	3	21
18326	1683	1	1	2	2
18327	1683	30	1	8	8
18328	1683	323	2	20	40
18329	1683	129	1	9	9
18330	1683	31	1	9	9
18331	1683	142	1	9	9
18332	1683	110	1	9	9
18333	1683	20	1	8	8
18334	1683	40	1	19	19
17865	1641	1	1	2	2
16871	1558	1	1	2	2
16872	1558	114	2	10	20
16873	1558	36	3	8	24
16874	1558	342	1	9	9
17866	1641	5	3	3	9
17867	1641	334	1	8	8
17868	1641	51	1	8	8
16878	1559	120	6	18	108
16879	1559	1	1	2	2
17869	1641	52	1	8	8
17870	1641	163	1	8	8
20696	1872	1	1	2	2
20697	1872	41	1	15	15
20698	1872	114	1	10	10
20699	1872	6	4	3	12
16889	1561	1	1	2	2
16890	1561	3	4	3	12
16891	1561	149	1	13	13
20700	1872	3	2	3	6
17888	1634	3	6	3	18
17889	1634	32	1	8	8
17900	1262	5	5	3	15
17901	1262	4	5	3	15
17902	1262	110	1	9	9
16898	1557	1	1	2	2
16899	1557	110	1	9	9
16900	1557	334	1	8	8
16901	1557	70	2	8	16
16902	1557	32	1	8	8
16903	1557	342	1	9	9
16904	1563	164	1	9	9
16905	1563	3	5	3	15
16906	1563	75	2	12	24
16907	1563	63	1	9	9
16908	1563	334	1	8	8
16909	1563	1	1	2	2
17903	1262	62	1	9	9
17904	1262	52	1	8	8
17905	1262	96	1	8	8
17906	1631	1	1	2	2
17907	1631	3	4	3	12
17908	1631	62	1	9	9
17909	1631	110	1	9	9
16917	1564	2	1	2	2
16918	1564	33	2	11	22
16919	1564	56	1	12	12
16920	1564	104	1	13	13
16921	1564	46	3	6	18
16922	1564	40	1	19	19
16923	1564	64	1	13	13
17910	1631	51	1	8	8
17911	1631	20	1	8	8
20701	1872	64	1	13	13
20702	1872	52	1	8	8
20703	1872	57	1	9	9
20704	1872	32	1	8	8
20705	1872	96	1	8	8
20706	1872	145	1	8	8
20726	1871	5	4	3	12
20727	1871	3	5	3	15
20728	1871	96	1	8	8
16935	422	63	1	9	9
16936	422	109	1	14	14
16937	422	132	1	17	17
16938	1565	2	1	2	2
16939	1565	3	4	3	12
16940	1565	96	2	8	16
16941	1565	27	2	8	16
16942	1565	32	1	8	8
16943	1565	31	1	9	9
16944	1565	145	1	8	8
16945	1565	51	1	8	8
20729	1871	341	1	9	9
20730	1871	342	1	9	9
20731	1871	136	1	8	8
20732	1871	1	1	2	2
24538	2180	1	1	2	2
24539	2180	3	10	3	30
24540	2180	57	2	9	18
24541	2180	25	1	14	14
16978	1566	1	1	2	2
16979	1566	3	10	3	30
16980	1562	1	1	2	2
16981	1562	149	6	13	78
16982	1562	264	1	10	10
17023	1569	1	1	2	2
17024	1569	40	1	19	19
17025	1569	43	1	12	12
17026	1569	6	1	3	3
17027	1569	105	1	13	13
17028	1569	149	4	13	52
17029	1569	342	1	9	9
17030	1569	64	2	13	26
17064	1573	1	2	2	4
17065	1573	129	1	9	9
17066	1573	63	3	9	27
17067	1573	185	2	50	100
17068	1573	58	3	13	39
17069	1573	51	6	8	48
17070	1573	153	1	17	17
17077	237	2	1	2	2
17078	237	3	3	3	9
17088	71	43	1	12	12
17089	71	56	3	12	36
17090	71	149	1	13	13
17091	71	106	1	14	14
17092	71	1	1	2	2
17093	1577	1	1	2	2
17094	1577	6	12	3	36
17098	1574	2	1	2	2
17099	1574	3	1	3	3
17100	1574	24	1	8	8
17101	1574	129	1	9	9
17102	1574	52	1	8	8
17108	1576	1	1	2	2
17109	1576	165	1	8	8
17110	1576	58	1	13	13
17111	1576	63	1	9	9
17112	1576	339	1	9	9
17113	1576	145	1	8	8
17071	1573	130	1	12	12
17072	1573	41	1	15	15
17073	1573	164	1	9	9
17074	1573	20	1	8	8
17075	1573	56	2	12	24
17076	1573	116	1	8	8
17891	1642	4	3	3	9
17892	1642	75	1	12	12
17893	1642	20	1	8	8
17894	1642	40	1	19	19
24542	2180	46	3	6	18
24543	2180	334	1	8	8
24544	2180	52	1	8	8
17130	1581	44	1	8	8
17131	1581	27	3	8	24
17132	1581	163	1	8	8
17133	1581	32	1	8	8
17134	1581	165	1	8	8
17135	1581	20	1	8	8
17136	1581	56	2	12	24
17139	1582	2	1	2	2
17140	1582	96	1	8	8
17141	1582	51	1	8	8
17154	1571	1	1	2	2
17155	1571	335	2	5	10
17156	1571	44	2	8	16
17157	1571	51	2	8	16
17158	1571	129	1	9	9
17159	1571	172	1	13	13
17160	1571	56	1	12	12
17172	1583	120	2	18	36
17173	1583	104	1	13	13
17174	1583	114	1	10	10
17175	1583	58	1	13	13
17176	1583	339	1	9	9
17177	1583	31	2	9	18
18012	1653	1	1	2	2
18013	1653	6	13	3	39
18014	1653	149	1	13	13
18015	1653	52	1	8	8
18016	1653	260	1	16	16
28982	2127	40	2	19	38
18070	1657	2	1	2	2
18071	1657	41	1	15	15
18072	1657	96	1	8	8
18073	1657	63	1	9	9
18074	1657	323	1	20	20
17403	1600	1	1	2	2
17404	1600	335	5	5	25
17405	1600	6	3	3	9
17406	1600	20	1	8	8
17407	1600	46	2	6	12
18122	1661	2	1	2	2
18123	1661	5	6	3	18
18124	1661	114	1	10	10
18125	1661	120	1	18	18
18126	1661	172	1	13	13
18127	1661	165	1	8	8
18128	1661	129	1	9	9
18129	1661	105	1	13	13
18130	1661	56	1	12	12
18131	1661	96	1	8	8
18132	1661	52	1	8	8
18133	1661	112	1	41	41
18316	1671	5	8	3	24
18392	1694	1	1	2	2
18393	1694	5	6	3	18
18394	1694	149	1	13	13
18395	1694	64	1	13	13
18396	1694	339	1	9	9
18440	883	4	4	3	12
18441	883	120	1	18	18
18444	1699	1	1	2	2
18445	1699	4	4	3	12
18446	1699	6	2	3	6
18447	1699	32	1	8	8
18448	1699	31	1	9	9
18449	1699	106	1	14	14
18450	1699	75	1	12	12
18451	1699	56	1	12	12
18452	1699	20	1	8	8
18453	1651	32	1	8	8
18454	1651	116	1	8	8
18455	1651	149	1	13	13
18456	1679	1	1	2	2
18457	1679	5	2	3	6
18458	1679	3	2	3	6
18459	1679	63	1	9	9
18460	1679	20	1	8	8
18461	1679	323	1	20	20
18462	1685	6	3	3	9
18463	1685	4	1	3	3
18464	1685	56	1	12	12
18465	1685	32	1	8	8
18466	1685	1	1	2	2
18472	1688	1	1	2	2
18473	1688	5	25	3	75
18474	1689	1	1	2	2
18475	1689	5	7	3	21
18476	1689	3	5	3	15
18477	1697	5	1	3	3
18487	804	172	2	13	26
18488	804	31	1	9	9
18495	1652	1	1	2	2
18496	1652	5	8	3	24
18497	1652	3	3	3	9
18498	1652	116	1	8	8
18499	1687	1	1	2	2
18500	1687	109	1	14	14
18501	1687	56	1	12	12
18504	1691	1	1	2	2
17114	1576	151	1	17	17
17115	1578	103	1	31	31
17116	1578	3	4	3	12
17117	1578	76	1	36	36
17137	1580	1	1	2	2
17138	1580	3	6	3	18
17142	1575	2	1	2	2
17143	1575	64	1	13	13
17144	1575	33	1	11	11
17145	1575	149	2	13	26
17146	1575	46	1	6	6
17147	1579	2	1	2	2
17148	1579	41	1	15	15
17149	1579	58	1	13	13
17150	1579	64	1	13	13
17151	1579	213	2	8	16
17188	1585	1	1	2	2
17189	1585	3	4	3	12
17190	1585	36	1	8	8
17191	1585	105	2	13	26
17192	1585	118	1	8	8
17193	1585	31	1	9	9
17194	1585	52	1	8	8
17195	1585	62	1	9	9
17196	1585	132	2	17	34
17197	1585	185	1	50	50
28925	2285	6	1	3	3
17211	1587	1	1	2	2
17212	1587	62	1	9	9
17213	1587	63	1	9	9
17214	1587	46	1	6	6
17215	1587	157	1	17	17
17216	1587	149	1	13	13
17217	1587	131	1	22	22
17218	1587	132	1	17	17
17219	1587	314	1	30	30
17225	1588	2	1	2	2
17226	1588	51	1	8	8
17227	1588	52	1	8	8
17228	1588	114	1	10	10
17229	1588	190	1	30	30
17242	1589	1	2	2	4
17243	1589	51	1	8	8
17244	1589	52	1	8	8
17245	1589	58	1	13	13
17246	1589	66	1	8	8
17247	1589	20	1	8	8
17248	1589	149	2	13	26
17249	1589	145	1	8	8
17250	1589	40	1	19	19
17251	1589	159	3	17	51
17252	1589	157	1	17	17
17253	1589	96	1	8	8
17912	1631	30	1	8	8
28926	2285	3	2	3	6
28927	2285	51	1	8	8
28928	2285	56	1	12	12
28966	2488	1	1	2	2
28967	2488	3	8	3	24
28968	2488	32	1	8	8
28969	2488	43	1	12	12
28970	2488	58	2	13	26
28971	2488	114	2	10	20
28972	2488	116	2	8	16
28973	2488	96	1	8	8
17342	519	1	1	2	2
17343	519	110	1	9	9
17344	519	165	1	8	8
17345	519	116	1	8	8
17349	1597	129	1	9	9
17350	1597	33	2	11	22
17351	1597	63	1	9	9
17352	1597	70	1	8	8
17353	1597	131	1	22	22
17354	1597	1	1	2	2
17355	1596	2	1	2	2
17356	1596	335	2	5	10
17357	1596	27	1	8	8
17358	1596	46	2	6	12
17359	1596	114	1	10	10
17360	1596	62	1	9	9
17361	1596	51	1	8	8
17362	1596	339	1	9	9
17363	1590	149	4	13	52
17364	1590	31	1	9	9
17365	1590	104	1	13	13
17366	1590	105	1	13	13
17367	1590	56	1	12	12
17368	1590	74	1	8	8
17369	1590	145	1	8	8
17370	1590	46	2	6	12
17371	1592	52	1	8	8
17372	1592	213	2	8	16
17373	1592	27	1	8	8
17374	1592	96	1	8	8
17375	1592	339	1	9	9
17376	1592	63	1	9	9
17377	1572	334	1	8	8
17378	1572	20	2	8	16
17379	1572	51	1	8	8
17380	1595	1	1	2	2
17381	1595	6	4	3	12
17382	1595	31	1	9	9
17397	1599	131	2	22	44
17954	1645	1	1	2	2
17955	1645	40	1	19	19
17956	1645	4	3	3	9
17957	1645	5	2	3	6
17958	1645	31	1	9	9
17959	1645	339	1	9	9
17960	1645	109	2	14	28
17992	1649	1	1	2	2
17993	1649	62	1	9	9
17994	1649	63	1	9	9
17995	1649	148	1	17	17
17996	1649	116	1	8	8
17997	1649	347	1	13	13
18035	1655	1	1	2	2
18036	1655	5	2	3	6
18037	1655	96	1	8	8
18038	1655	120	1	18	18
18045	1656	1	1	2	2
18046	1656	3	8	3	24
18047	1656	5	2	3	6
18048	1656	319	1	14	14
18049	1656	20	1	8	8
18050	1656	323	1	20	20
18058	441	1	1	2	2
18059	441	5	5	3	15
18060	441	341	1	9	9
18061	441	31	1	9	9
18062	441	334	1	8	8
18063	441	62	1	9	9
18064	441	63	1	9	9
17925	800	1	1	2	2
17926	800	5	5	3	15
17927	800	3	4	3	12
17928	800	96	2	8	16
17929	800	143	2	9	18
17930	800	62	2	9	18
17931	800	64	1	13	13
17932	800	116	1	8	8
28915	592	43	1	12	12
28916	592	36	1	8	8
28917	592	51	1	8	8
17161	1234	1	1	2	2
17162	1234	5	4	3	12
17163	1234	32	2	8	16
17164	1234	39	1	8	8
28918	592	62	1	9	9
28919	592	64	1	13	13
17971	1646	1	1	2	2
17972	1646	5	3	3	9
17973	1646	3	19	3	57
17171	1584	269	1	27	27
18024	1654	1	1	2	2
18025	1654	3	4	3	12
18026	1654	5	4	3	12
18027	1654	51	1	8	8
18028	1654	334	1	8	8
18029	1654	70	1	8	8
18030	1654	96	1	8	8
28937	2481	1	2	2	4
28938	2481	5	11	3	33
28939	2481	335	2	5	10
28940	2481	51	1	8	8
28941	2481	52	2	8	16
28942	2481	105	1	13	13
28943	2481	64	1	13	13
28944	2484	3	2	3	6
28945	2484	25	1	14	14
28946	2484	1	1	2	2
28963	1471	2	1	2	2
18182	1668	1	1	2	2
18183	1668	3	3	3	9
18184	1668	32	1	8	8
18185	1668	114	1	10	10
18186	1668	96	1	8	8
18187	1668	116	2	8	16
18188	1668	145	1	8	8
28964	1471	51	1	8	8
24600	2184	2	1	2	2
24601	2184	3	2	3	6
24602	2184	46	5	6	30
24603	2184	58	1	13	13
24604	2184	51	1	8	8
17286	1591	2	1	2	2
17287	1591	32	1	8	8
17288	1591	35	1	17	17
17289	1591	151	1	17	17
17290	1591	130	2	12	24
17291	1591	56	1	12	12
17292	1591	116	1	8	8
17293	1570	1	1	2	2
17294	1570	31	2	9	18
17295	1570	40	1	19	19
17296	1570	341	1	9	9
17297	1570	165	1	8	8
17298	1570	151	3	17	51
17299	1570	149	2	13	26
17300	1570	56	2	12	24
17301	1570	120	1	18	18
17302	1570	342	2	9	18
17303	1570	58	1	13	13
24605	2184	52	1	8	8
18271	1678	1	1	2	2
18272	1678	106	1	14	14
18273	1678	5	3	3	9
18274	1678	172	1	13	13
24606	2184	318	1	12	12
24607	2185	1	1	2	2
24608	2185	5	3	3	9
20824	1877	1	1	2	2
20825	1877	5	3	3	9
17314	1593	1	1	2	2
17315	1593	34	1	8	8
17316	1593	36	1	8	8
17317	1593	27	1	8	8
17318	1593	20	1	8	8
17319	1593	101	3	3	9
17320	1593	145	1	8	8
20826	1877	24	1	8	8
28965	1471	3	1	3	3
17346	1594	46	2	6	12
17347	1594	132	1	17	17
17348	1594	104	1	13	13
18306	645	1	1	2	2
18307	645	5	6	3	18
18308	645	3	2	3	6
18309	645	116	1	8	8
18310	645	335	1	5	5
18311	645	163	1	8	8
17390	1598	110	1	9	9
17391	1598	96	2	8	16
17392	1598	51	1	8	8
17393	1598	31	1	9	9
17394	1598	278	1	18	18
17395	1598	303	1	13	13
17396	1598	311	1	30	30
18312	1664	5	1	3	3
18313	1664	36	1	8	8
18314	1664	116	1	8	8
18315	1664	64	1	13	13
20827	1877	25	1	14	14
20828	1877	142	1	9	9
20829	1877	64	1	13	13
20830	1877	58	1	13	13
20831	1877	104	1	13	13
20832	1877	187	1	30	30
20833	1877	188	1	30	30
24609	2185	3	5	3	15
24610	2185	26	1	14	14
24611	2185	62	1	9	9
18420	1696	1	1	2	2
18421	1696	116	2	8	16
18422	1696	62	1	9	9
18423	1696	64	1	13	13
18424	1696	149	1	13	13
18425	1696	6	10	3	30
18437	883	1	1	2	2
18438	883	145	2	8	16
18439	883	129	1	9	9
18478	1697	104	1	13	13
18479	1697	213	1	8	8
18480	1697	31	1	9	9
18481	1697	170	2	17	34
18482	1697	1	1	2	2
18493	1451	5	6	3	18
18494	1451	116	1	8	8
18526	1672	5	7	3	21
18538	1013	1	1	2	2
18539	1013	5	7	3	21
18540	1013	6	4	3	12
18556	1666	5	10	3	30
18562	692	110	1	9	9
18563	692	64	1	13	13
18564	692	172	1	13	13
18565	692	130	2	12	24
18570	1701	315	1	65	65
18571	1701	282	1	34	34
24563	2181	6	4	3	12
24564	2181	32	3	8	24
24565	2181	51	1	8	8
24566	2181	57	1	9	9
24574	2183	1	1	2	2
24575	2183	5	10	3	30
24576	2183	3	10	3	30
24590	1496	145	1	8	8
20796	1875	1	1	2	2
20797	1875	3	5	3	15
20798	1875	57	1	9	9
20799	1875	58	1	13	13
20800	1875	96	1	8	8
20801	1875	43	1	12	12
20802	1875	129	1	9	9
20803	1875	116	1	8	8
20804	1875	35	1	17	17
20805	1875	26	2	14	28
20806	1875	52	1	8	8
20807	1875	151	1	17	17
20808	1875	63	1	9	9
20809	1875	64	1	13	13
20810	1875	59	1	9	9
20848	1878	1	1	2	2
20849	1878	341	1	9	9
20850	1878	51	2	8	16
20851	1878	105	1	13	13
20852	1878	116	1	8	8
20853	1878	58	1	13	13
20854	1878	100	1	17	17
20855	1878	314	1	30	30
20973	1886	5	8	3	24
20974	1886	335	2	5	10
20975	1886	96	2	8	16
20976	1886	1	1	2	2
21035	1891	1	1	2	2
21036	1891	5	6	3	18
21037	1891	27	1	8	8
21038	1891	26	1	14	14
21039	1891	36	2	8	16
21040	1891	264	1	10	10
21041	1891	185	1	50	50
21946	1960	342	1	9	9
21947	1960	339	3	9	27
21948	1960	20	1	8	8
21969	1963	1	1	2	2
21970	1963	6	11	3	33
21971	1963	129	1	9	9
21972	1963	20	2	8	16
21973	1963	51	1	8	8
21974	1963	62	2	9	18
21982	1415	1	1	2	2
21983	1415	114	1	10	10
21984	1415	64	1	13	13
21985	1415	342	1	9	9
21986	1415	96	1	8	8
21987	1415	52	1	8	8
21988	1415	74	1	8	8
22014	1965	1	1	2	2
22015	1965	3	7	3	21
22016	1966	1	1	2	2
22017	1966	3	5	3	15
22018	1966	114	1	10	10
22019	1966	150	1	11	11
22020	1966	129	1	9	9
22021	1966	36	1	8	8
22022	1966	52	1	8	8
22023	1966	59	1	9	9
22024	1966	190	1	30	30
22071	1969	1	1	2	2
22072	1969	3	10	3	30
22073	1969	100	1	17	17
22074	1969	120	1	18	18
22075	1969	104	2	13	26
22740	1995	1	1	2	2
22741	1995	3	6	3	18
22742	1995	96	1	8	8
22743	1995	114	1	10	10
22744	1995	271	1	24	24
22748	2004	1	1	2	2
22749	2004	5	12	3	36
22750	2004	260	1	16	16
22779	2030	1	1	2	2
22780	2030	5	2	3	6
22781	2030	65	1	8	8
22782	2030	150	1	11	11
22783	1860	105	1	13	13
22784	1860	104	1	13	13
22785	1860	319	1	14	14
22786	1860	107	1	14	14
22794	1998	96	1	8	8
22795	1998	56	1	12	12
22796	1998	91	1	8	8
22797	1998	113	1	25	25
22798	1992	1	1	2	2
22799	1992	3	6	3	18
22800	1992	5	6	3	18
22801	1992	62	1	9	9
22802	1992	342	1	9	9
22803	1992	333	1	8	8
22804	1992	91	1	8	8
22805	1717	1	1	2	2
22806	1717	5	5	3	15
22807	1717	31	3	9	27
22808	1717	165	1	8	8
22809	1717	36	1	8	8
22810	1717	114	1	10	10
22818	2032	2	1	2	2
22819	2032	5	7	3	21
22820	2032	4	2	3	6
22823	2034	1	1	2	2
22824	2034	6	4	3	12
22825	2034	105	1	13	13
22826	2034	62	1	9	9
18489	804	64	1	13	13
18490	804	56	2	12	24
18491	804	32	1	8	8
18492	804	132	1	17	17
18503	1690	5	10	3	30
18513	1693	1	1	2	2
18514	1693	51	1	8	8
18515	1693	318	1	12	12
18516	1693	342	1	9	9
18517	1693	172	1	13	13
18518	1693	323	1	20	20
18519	1695	1	1	2	2
18520	1695	3	4	3	12
18521	1695	110	1	9	9
18522	1695	31	1	9	9
18523	1695	36	1	8	8
18527	1673	1	1	2	2
18528	1673	5	3	3	9
18529	1673	62	1	9	9
18530	1673	143	1	9	9
18535	1684	20	1	8	8
18536	1684	142	1	9	9
18542	1221	1	1	2	2
18543	1221	5	5	3	15
18544	1221	335	1	5	5
18545	1221	165	1	8	8
20908	263	1	1	2	2
20909	263	6	14	3	42
20910	263	26	1	14	14
18614	1703	185	1	50	50
18615	1704	1	2	2	4
18616	1704	6	10	3	30
18617	1704	5	11	3	33
20947	1885	1	1	2	2
20948	1885	5	7	3	21
20949	1885	3	5	3	15
20950	1885	63	2	9	18
20951	1885	43	1	12	12
20952	1885	242	1	8	8
20953	1885	130	2	12	24
20954	1885	32	2	8	16
20960	1006	5	21	3	63
20961	1006	1	1	2	2
20962	1006	24	2	8	16
20963	1006	58	1	13	13
24637	2187	2	1	2	2
24638	2187	5	2	3	6
24639	2187	3	6	3	18
24644	787	5	8	3	24
24645	787	1	1	2	2
21068	1554	1	1	2	2
21069	1554	6	8	3	24
21070	1554	8	4	6	24
21071	1554	58	1	13	13
21072	1554	43	1	12	12
21073	1554	63	1	9	9
21074	1554	29	1	12	12
29073	2496	1	1	2	2
29074	2496	3	9	3	27
24669	383	149	4	13	52
24670	383	7	1	6	6
24671	383	8	1	6	6
24672	383	1	1	2	2
24705	2191	1	1	2	2
24706	2191	6	4	3	12
24707	2191	51	1	8	8
24708	2191	57	1	9	9
24709	2191	165	1	8	8
24710	2191	101	2	3	6
24711	2191	116	1	8	8
24712	2191	46	4	6	24
29075	2496	6	5	3	15
29076	2496	7	3	6	18
29077	2496	64	1	13	13
29078	2496	75	1	12	12
29079	2496	35	1	17	17
29080	2496	100	1	17	17
22249	1917	113	1	25	25
22250	1917	5	1	3	3
22251	1917	3	2	3	6
22283	1971	2	1	2	2
22284	1971	5	3	3	9
22285	1971	3	4	3	12
22318	1975	114	1	10	10
22319	1975	27	1	8	8
22330	1979	192	1	30	30
22390	2010	1	1	2	2
22391	2010	6	3	3	9
22392	2010	4	2	3	6
22393	2010	35	1	17	17
22394	2010	342	2	9	18
22395	2010	20	1	8	8
22396	2010	105	1	13	13
22469	269	1	1	2	2
22470	269	5	10	3	30
22471	269	96	2	8	16
22472	269	41	1	15	15
22473	269	172	2	13	26
22474	269	114	1	10	10
22475	269	52	2	8	16
22476	1463	1	1	2	2
22477	1463	5	6	3	18
22478	1463	335	1	5	5
22514	2015	1	1	2	2
22515	2015	5	10	3	30
22522	2016	1	1	2	2
22523	2016	3	8	3	24
22524	2016	5	7	3	21
22525	2016	62	2	9	18
22526	2016	114	1	10	10
22527	2016	319	1	14	14
22545	2018	105	1	13	13
22546	2018	319	1	14	14
22547	2018	104	1	13	13
22548	751	1	1	2	2
22549	751	3	3	3	9
22550	751	31	1	9	9
22551	751	44	1	8	8
18502	1687	107	1	14	14
18509	1446	1	1	2	2
18510	1446	3	5	3	15
18511	1446	5	5	3	15
18512	1446	113	1	25	25
18537	267	5	4	3	12
18541	1700	173	1	40	40
18546	1643	5	3	3	9
18547	1643	4	1	3	3
18548	1643	52	2	8	16
18549	1643	64	1	13	13
18550	1643	96	1	8	8
18557	1682	1	1	2	2
18558	1682	5	4	3	12
18559	1682	20	1	8	8
18560	1682	339	1	9	9
18561	1682	129	1	9	9
20930	1883	46	1	6	6
24591	1496	318	1	12	12
24592	1496	32	1	8	8
24593	1496	65	1	8	8
24594	1496	29	1	12	12
18613	1702	282	1	34	34
24595	1496	101	1	3	3
24596	1496	342	1	9	9
24597	1496	1	1	2	2
24613	2186	1	1	2	2
24614	2186	6	11	3	33
20977	1887	6	2	3	6
20978	1887	114	1	10	10
20979	1887	165	1	8	8
20980	1887	151	1	17	17
20981	1887	24	1	8	8
24615	2186	106	1	14	14
24616	2186	25	1	14	14
21013	1888	32	1	8	8
21014	1888	96	1	8	8
21015	1888	43	1	12	12
21016	1888	129	1	9	9
21017	1888	116	1	8	8
21018	1888	62	1	9	9
21019	1888	30	1	8	8
21020	1888	26	1	14	14
29018	2480	1	1	2	2
29019	2480	6	3	3	9
29020	2480	3	7	3	21
29027	2491	2	1	2	2
29028	2491	3	2	3	6
29029	2491	58	2	13	26
29030	2491	57	1	9	9
29031	2491	213	1	8	8
24654	2188	1	1	2	2
24655	2188	96	3	8	24
24656	2188	32	1	8	8
29045	906	2	1	2	2
29046	906	6	2	3	6
29047	906	148	1	17	17
29048	906	130	1	12	12
29052	2494	1	1	2	2
29053	2494	57	5	9	45
29054	2494	109	1	14	14
29055	2494	46	1	6	6
29056	2494	8	1	6	6
29057	2494	7	1	6	6
29081	2495	1	1	2	2
29082	2495	5	6	3	18
29083	2495	3	5	3	15
22263	2001	1	1	2	2
22264	2001	96	1	8	8
22265	2001	105	1	13	13
22266	2001	172	1	13	13
22267	2001	145	2	8	16
22268	2001	157	1	17	17
22269	2001	62	1	9	9
22270	2001	70	1	8	8
22320	176	5	4	3	12
22321	176	3	4	3	12
22322	176	65	1	8	8
22323	1978	1	1	2	2
22324	1978	5	5	3	15
22325	1978	6	5	3	15
22326	1978	129	1	9	9
22327	1978	30	1	8	8
22328	1978	62	1	9	9
22329	1978	35	1	17	17
22343	1984	1	1	2	2
22344	1984	5	8	3	24
22345	1984	165	1	8	8
22346	1984	116	1	8	8
22347	1984	96	2	8	16
22348	1984	62	1	9	9
22366	2008	1	1	2	2
22367	2008	5	1	3	3
22368	2008	3	3	3	9
22369	2008	100	1	17	17
22370	2008	342	1	9	9
22371	2008	96	1	8	8
22372	2008	193	1	22	22
22378	2009	1	1	2	2
22379	2009	5	4	3	12
22380	2009	52	2	8	16
22381	2009	30	1	8	8
22382	2009	96	1	8	8
22405	2011	1	1	2	2
22406	2011	145	1	8	8
22407	2011	62	1	9	9
22408	2011	213	1	8	8
22422	1135	6	4	3	12
22423	1135	44	1	8	8
22424	1135	213	1	8	8
22425	1135	106	1	14	14
22426	1135	70	2	8	16
22427	1135	264	1	10	10
18505	1691	5	5	3	15
18506	1691	6	3	3	9
18507	1691	328	1	15	15
18508	1691	22	1	9	9
18524	1698	1	1	2	2
18525	1698	5	6	3	18
18531	1677	5	5	3	15
18532	1677	63	1	9	9
18533	1692	41	1	15	15
18534	1692	116	1	8	8
18551	1192	1	1	2	2
18552	1192	4	4	3	12
18553	1192	120	3	18	54
18554	1192	5	3	3	9
18555	1192	75	1	12	12
24612	2185	96	1	8	8
28997	752	1	1	2	2
28998	752	3	6	3	18
28999	752	36	1	8	8
29000	752	75	1	12	12
29001	752	30	1	8	8
29002	752	64	1	13	13
18605	1710	3	7	3	21
18606	1710	5	3	3	9
18607	1710	43	1	12	12
18608	1710	120	1	18	18
18609	1710	213	1	8	8
18610	1710	129	1	9	9
18611	1710	32	1	8	8
18612	1710	1	1	2	2
18619	1706	96	2	8	16
18620	1707	172	1	13	13
18621	1707	105	1	13	13
18622	1707	56	1	12	12
18623	1707	46	2	6	12
18624	1707	315	3	65	195
18632	1422	4	2	3	6
18633	1422	5	2	3	6
18634	1422	43	1	12	12
18635	1422	27	1	8	8
18636	1422	32	1	8	8
18637	1422	130	2	12	24
18638	1422	56	1	12	12
18639	1708	4	4	3	12
18640	1708	1	1	2	2
18641	1708	149	1	13	13
18642	1708	129	1	9	9
18643	1708	46	2	6	12
18651	1712	2	1	2	2
18652	1712	149	4	13	52
18653	1712	172	1	13	13
18654	1712	307	2	24	48
18655	1712	315	1	65	65
18656	1711	4	2	3	6
18657	1711	5	1	3	3
18666	1714	5	8	3	24
18667	1714	129	1	9	9
18668	1714	25	1	14	14
18669	1714	1	1	2	2
18673	1715	307	1	24	24
18674	1715	311	1	30	30
18675	1715	310	2	15	30
18681	1716	40	1	19	19
18682	1716	43	1	12	12
18683	1716	5	2	3	6
18684	1716	2	1	2	2
18685	1716	282	1	34	34
18693	741	40	1	19	19
18694	741	1	1	2	2
18695	741	105	1	13	13
18696	741	56	1	12	12
18697	741	149	1	13	13
18698	741	132	1	17	17
18699	741	120	1	18	18
18717	1718	1	1	2	2
18718	1718	6	2	3	6
18719	1718	3	2	3	6
18720	1718	43	1	12	12
18721	1718	129	1	9	9
18722	1718	96	1	8	8
18723	1718	172	1	13	13
18724	1718	36	1	8	8
18725	1718	58	1	13	13
18726	1718	70	1	8	8
18727	1718	114	1	10	10
18728	1718	34	1	8	8
18729	1718	131	1	22	22
18735	1719	58	1	13	13
18736	1719	130	1	12	12
18737	1719	40	1	19	19
18738	1719	311	1	30	30
18739	1719	1	1	2	2
18751	1720	1	2	2	4
18752	1720	30	1	8	8
18753	1720	57	1	9	9
18754	1720	96	1	8	8
18755	1720	51	2	8	16
18756	1720	46	3	6	18
18757	1720	65	1	8	8
18758	1720	114	1	10	10
18759	1720	73	1	8	8
18760	1720	344	1	11	11
18761	1720	26	2	14	28
18769	1721	1	1	2	2
18770	1721	28	3	12	36
18771	1721	25	1	14	14
18772	1721	114	1	10	10
18773	1721	46	2	6	12
18774	1721	116	1	8	8
18775	1721	58	1	13	13
18776	1713	1	1	2	2
18777	1713	4	5	3	15
18778	1713	136	1	8	8
18779	1713	303	4	13	52
18783	1722	132	1	17	17
18784	1722	311	1	30	30
18785	1722	307	2	24	48
18824	1724	1	1	2	2
18825	1724	27	2	8	16
18826	1724	32	2	8	16
18827	1724	51	1	8	8
18828	1724	52	1	8	8
18829	1724	307	1	24	24
18838	1725	5	5	3	15
18839	1725	4	4	3	12
18851	1726	1	1	2	2
18852	1726	25	1	14	14
24657	2188	6	3	3	9
24658	2188	242	1	8	8
24659	2188	63	1	9	9
24660	2189	1	4	2	8
18807	1723	149	7	13	91
18808	1723	114	1	10	10
18809	1723	57	1	9	9
18810	1723	120	1	18	18
18811	1723	26	1	14	14
18812	1723	33	1	11	11
18813	1723	62	1	9	9
18814	1723	63	1	9	9
18815	1723	32	1	8	8
18816	1723	1	1	2	2
18817	1723	6	8	3	24
18860	1727	52	1	8	8
18861	1727	51	1	8	8
18862	1727	57	1	9	9
18863	1727	303	1	13	13
18906	1729	2	1	2	2
18907	1729	100	1	17	17
18908	1729	40	1	19	19
18915	1730	8	2	6	12
18916	1730	51	3	8	24
18917	1730	40	1	19	19
18918	1730	149	1	13	13
18919	1730	2	1	2	2
18920	1730	185	1	50	50
18944	1733	2	2	2	4
18945	1733	41	1	15	15
18946	1733	58	1	13	13
18947	1733	120	1	18	18
18948	1733	116	1	8	8
18949	1733	114	1	10	10
18950	1733	43	1	12	12
18976	1734	1	1	2	2
18977	1734	40	2	19	38
18978	1734	51	2	8	16
18979	1734	9	3	12	36
18980	1734	132	1	17	17
18981	1734	20	1	8	8
18982	1734	130	1	12	12
18983	1734	172	1	13	13
18984	1734	334	1	8	8
18985	1734	120	1	18	18
18989	1421	5	3	3	9
18990	1421	46	4	6	24
18991	1421	341	1	9	9
18992	1421	39	2	8	16
18993	1421	65	1	8	8
18994	1421	142	2	9	18
18995	1421	1	1	2	2
19015	1738	1	1	2	2
19016	1738	4	10	3	30
19017	1738	5	1	3	3
19050	1740	1	1	2	2
19051	1740	6	4	3	12
19052	1740	32	3	8	24
19053	1740	114	2	10	20
19054	1740	105	1	13	13
19055	1740	165	3	8	24
19056	1740	57	2	9	18
19057	1740	51	4	8	32
19058	1740	334	1	8	8
19059	1740	62	3	9	27
24661	2189	3	40	3	120
24662	2189	5	2	3	6
24663	2189	96	2	8	16
19074	1742	1	1	2	2
19075	1742	8	6	6	36
19076	1742	58	1	13	13
19077	1742	114	1	10	10
19078	1742	41	1	15	15
19079	1742	105	2	13	26
19080	1742	165	1	8	8
19081	1742	149	1	13	13
24664	2189	120	1	18	18
24665	2189	57	2	9	18
24666	2189	62	1	9	9
21028	1890	2	1	2	2
21029	1890	7	2	6	12
21030	1890	341	1	9	9
21031	1890	52	1	8	8
21032	1890	148	1	17	17
21033	1890	39	1	8	8
19113	1747	1	1	2	2
19114	1747	8	4	6	24
19115	1747	120	1	18	18
19116	1747	114	1	10	10
19117	1747	172	1	13	13
19118	1747	56	1	12	12
19153	1749	1	1	2	2
19154	1749	63	3	9	27
19155	1749	57	2	9	18
19156	1749	51	2	8	16
19157	1749	96	2	8	16
19158	1749	116	2	8	16
19159	1749	32	1	8	8
19167	1752	131	1	22	22
19168	1752	132	1	17	17
21034	1890	334	1	8	8
24667	2189	150	1	11	11
24668	2189	6	1	3	3
29003	2489	5	10	3	30
29004	2489	9	1	12	12
29005	2489	172	2	13	26
29006	2489	51	1	8	8
29007	2489	52	1	8	8
29008	2489	74	3	8	24
29009	2489	116	1	8	8
24682	421	1	1	2	2
24683	421	3	20	3	60
24799	2197	1	1	2	2
24800	2197	3	2	3	6
24801	2197	51	1	8	8
24802	2197	32	1	8	8
24803	2197	27	2	8	16
24890	2202	3	10	3	30
24891	2202	46	8	6	48
24892	2202	151	1	17	17
24893	2202	43	1	12	12
24901	89	1	1	2	2
24902	89	44	1	8	8
24903	89	118	1	8	8
24904	89	25	2	14	28
24905	89	56	2	12	24
18840	1725	105	1	13	13
18841	1725	165	1	8	8
18842	1725	51	1	8	8
18843	1725	32	1	8	8
18844	1725	116	1	8	8
18845	1725	1	1	2	2
21075	1892	1	1	2	2
21076	1892	24	1	8	8
21077	1892	3	4	3	12
21078	1892	5	2	3	6
21079	1892	63	2	9	18
21080	1892	62	1	9	9
21081	1892	51	1	8	8
21082	1892	114	1	10	10
21083	1892	116	1	8	8
21087	1893	1	1	2	2
21088	1893	6	3	3	9
21089	1893	32	1	8	8
21090	1893	31	2	9	18
21091	1893	43	1	12	12
21092	1893	149	1	13	13
21093	1893	334	1	8	8
21094	1893	34	1	8	8
21095	1893	116	1	8	8
21096	1893	63	1	9	9
29010	2489	1	1	2	2
18890	1728	1	1	2	2
18891	1728	114	2	10	20
18892	1728	32	1	8	8
18893	1728	129	1	9	9
18894	1728	96	2	8	16
18895	1728	63	1	9	9
18896	1728	60	1	8	8
18897	1728	145	1	8	8
18898	1728	34	1	8	8
18899	1728	334	1	8	8
18900	1728	52	1	8	8
18901	1728	116	1	8	8
18902	1728	30	1	8	8
24696	1312	1	1	2	2
24697	1312	5	5	3	15
29039	2492	1	1	2	2
21116	1889	131	2	22	44
21117	1889	1	1	2	2
21118	1889	5	5	3	15
21119	1889	40	2	19	38
21120	1889	62	1	9	9
21121	1889	56	2	12	24
21122	1889	116	1	8	8
21123	1896	1	1	2	2
21124	1896	5	3	3	9
21125	1896	57	1	9	9
21126	1896	149	2	13	26
21127	1896	96	1	8	8
21128	1896	151	1	17	17
21129	1896	150	1	11	11
21130	1896	40	1	19	19
21131	1896	101	3	3	9
21132	1896	258	1	3	3
21143	1859	3	5	3	15
21159	1898	132	1	17	17
21160	1898	30	1	8	8
21161	1898	7	2	6	12
19029	1739	1	1	2	2
19030	1739	40	1	19	19
19031	1739	5	3	3	9
19032	1739	6	1	3	3
19033	1739	63	1	9	9
19034	1739	57	1	9	9
19035	1739	52	1	8	8
19036	1739	145	1	8	8
19037	1739	116	1	8	8
19038	1739	114	1	10	10
19039	1739	105	1	13	13
19063	1741	1	1	2	2
19064	1741	335	2	5	10
19065	1741	46	2	6	12
19083	1743	278	2	18	36
21162	1898	2	1	2	2
19099	1746	311	4	30	120
19119	1748	1	1	2	2
19120	1748	8	4	6	24
19121	1748	39	1	8	8
19122	1748	51	1	8	8
19123	1748	57	1	9	9
19124	1748	172	1	13	13
19125	1748	56	1	12	12
21163	1898	109	1	14	14
21195	1900	1	1	2	2
21196	1900	335	2	5	10
21197	1900	27	1	8	8
21198	1900	342	1	9	9
21199	1900	71	1	8	8
21200	1900	151	1	17	17
21201	1900	165	1	8	8
29040	2492	9	2	12	24
29041	2492	58	2	13	26
29042	2492	120	2	18	36
29043	2492	157	1	17	17
29044	2492	35	1	17	17
29058	1999	1	1	2	2
29059	1999	6	4	3	12
29060	1999	40	1	19	19
29061	1999	62	1	9	9
29062	1999	36	1	8	8
29063	1999	151	1	17	17
29064	1999	303	2	13	26
21212	1902	1	1	2	2
21213	1902	7	5	6	30
21214	1902	26	1	14	14
21215	1902	114	1	10	10
21216	1902	341	1	9	9
21217	1902	58	1	13	13
21218	1902	95	1	8	8
21219	1902	148	1	17	17
21357	1911	1	1	2	2
21358	1911	52	1	8	8
21359	1911	339	1	9	9
21360	1911	151	1	17	17
21361	1911	136	1	8	8
21362	1911	319	1	14	14
21379	1913	1	1	2	2
21380	1913	5	6	3	18
21381	1913	27	2	8	16
21382	1913	96	2	8	16
21383	1913	116	2	8	16
21384	1913	51	1	8	8
21385	1913	52	1	8	8
21386	1913	63	1	9	9
21387	1913	62	1	9	9
21388	1914	5	4	3	12
21389	1914	7	2	6	12
21390	1914	1	1	2	2
18853	1726	100	1	17	17
18854	1726	339	1	9	9
18855	1726	63	1	9	9
24698	1312	114	1	10	10
24699	1312	334	1	8	8
24700	1312	57	1	9	9
21142	1895	1	1	2	2
18872	209	6	4	3	12
18873	209	31	1	9	9
18874	209	96	1	8	8
18875	209	145	2	8	16
18876	209	1	1	2	2
24701	1312	62	1	9	9
24702	1312	34	1	8	8
24703	1312	131	1	22	22
24704	1312	132	1	17	17
24723	2190	5	8	3	24
18951	1731	2	1	2	2
18952	1731	41	1	15	15
18953	1731	5	3	3	9
18954	1731	32	1	8	8
18955	1731	114	1	10	10
18956	1731	46	2	6	12
18957	1731	63	1	9	9
18958	1731	157	1	17	17
18996	1735	1	1	2	2
18997	1735	104	2	13	26
18998	1735	52	1	8	8
19007	1737	1	1	2	2
19008	1737	5	4	3	12
19009	1737	43	1	12	12
19010	1737	46	1	6	6
19011	1737	339	1	9	9
21239	1904	148	1	17	17
21240	1904	130	1	12	12
21241	1904	40	1	19	19
21242	1904	35	1	17	17
19084	1736	2	1	2	2
19085	1736	8	8	6	48
19086	1736	7	2	6	12
19087	437	32	1	8	8
19088	437	114	1	10	10
19089	437	1	1	2	2
21263	1903	1	1	2	2
21264	1903	5	3	3	9
21265	1903	25	2	14	28
21266	1903	35	1	17	17
21267	1903	32	1	8	8
21268	1903	62	1	9	9
21269	1903	157	1	17	17
21270	1903	96	1	8	8
21271	1903	52	1	8	8
21272	1903	151	2	17	34
21273	1903	159	1	17	17
21294	1906	307	20	24	480
21295	1906	311	1	30	30
21296	1906	5	3	3	9
21297	1906	56	3	12	36
21298	1906	145	1	8	8
21299	1906	32	1	8	8
21300	1906	109	1	14	14
21301	1906	26	2	14	28
21302	1906	105	1	13	13
21303	1906	1	1	2	2
21333	1909	6	5	3	15
21334	1909	1	1	2	2
21335	1909	242	1	8	8
21336	1909	52	1	8	8
21337	1909	57	1	9	9
21338	1909	129	1	9	9
21339	1909	30	1	8	8
21363	1910	1	1	2	2
21364	1910	109	7	14	98
21365	1910	187	1	30	30
21391	1912	1	1	2	2
21392	1912	6	5	3	15
21436	1918	1	1	2	2
21437	1918	3	3	3	9
21438	1918	120	2	18	36
21439	1918	31	1	9	9
21440	1918	105	1	13	13
21441	1918	40	1	19	19
21454	1879	1	1	2	2
21455	1879	57	2	9	18
21456	1879	51	2	8	16
21457	1879	130	1	12	12
21458	1879	56	1	12	12
21459	1879	148	1	17	17
21490	1921	2	1	2	2
21491	1921	27	1	8	8
21492	1921	149	1	13	13
21493	1921	40	2	19	38
21494	1921	157	1	17	17
21495	1921	153	1	17	17
21496	1921	132	1	17	17
21506	1922	64	1	13	13
21507	1922	109	1	14	14
21508	1922	151	1	17	17
21509	1922	100	2	17	34
21510	1922	145	1	8	8
21511	1922	59	1	9	9
21512	1922	132	1	17	17
21513	1922	148	1	17	17
21514	1922	319	1	14	14
21515	1922	5	1	3	3
21516	1922	1	1	2	2
21600	1933	1	1	2	2
21601	1933	57	1	9	9
21602	1933	52	1	8	8
21603	1933	116	1	8	8
21604	1933	105	1	13	13
21605	1933	62	1	9	9
21606	1933	63	1	9	9
21607	1933	35	2	17	34
21608	1933	56	1	12	12
21609	1933	40	1	19	19
21610	1933	190	1	30	30
21632	1934	1	1	2	2
21633	1934	72	1	8	8
21634	1934	20	1	8	8
21635	1934	64	1	13	13
21636	1934	191	1	30	30
21647	1935	3	3	3	9
21648	1935	1	1	2	2
21649	1935	63	1	9	9
21650	1935	56	1	12	12
21672	1237	1	1	2	2
21673	1237	3	5	3	15
21097	1894	1	1	2	2
21098	1894	5	5	3	15
21099	1894	3	7	3	21
24727	2193	1	1	2	2
24728	2193	6	3	3	9
21154	1897	1	1	2	2
24729	2193	32	1	8	8
24730	2193	57	3	9	27
24731	2193	165	1	8	8
24732	2193	52	1	8	8
24733	2193	129	1	9	9
24734	2193	116	1	8	8
24735	2193	26	1	14	14
19091	1744	335	5	5	25
19134	813	1	1	2	2
19135	813	3	1	3	3
19136	813	5	1	3	3
19137	813	6	2	3	6
19138	813	34	2	8	16
19139	813	63	1	9	9
19140	813	172	1	13	13
19141	813	57	1	9	9
19203	1300	1	1	2	2
19204	1300	46	3	6	18
19205	1300	6	20	3	60
19206	1300	149	4	13	52
19208	79	40	1	19	19
19211	1755	2	1	2	2
19212	1755	5	8	3	24
19223	1758	63	1	9	9
19224	1758	120	1	18	18
19228	1507	7	1	6	6
19229	1507	57	1	9	9
19230	1507	51	1	8	8
19231	1507	1	1	2	2
19234	1760	1	1	2	2
19235	1760	52	2	8	16
19236	1759	1	1	2	2
19237	1759	5	5	3	15
19238	1759	3	5	3	15
19244	1761	1	1	2	2
19245	1761	4	5	3	15
19246	1761	40	1	19	19
19247	1761	56	1	12	12
19248	1761	148	1	17	17
19252	822	5	7	3	21
19253	822	3	7	3	21
19254	822	1	1	2	2
19264	1762	339	1	9	9
19265	1762	9	1	12	12
19266	1762	63	1	9	9
19267	1762	1	1	2	2
19276	1763	2	1	2	2
19277	1763	335	3	5	15
19278	1763	51	2	8	16
19279	1763	3	1	3	3
19280	1763	57	1	9	9
19281	1763	191	2	30	60
19282	1764	26	1	14	14
19283	1764	62	1	9	9
19293	1765	113	1	25	25
19294	1765	9	1	12	12
19295	1765	4	4	3	12
19296	1765	6	5	3	15
19297	1765	27	1	8	8
19298	1765	136	1	8	8
19299	1765	57	1	9	9
19300	1765	114	1	10	10
19301	1765	95	1	8	8
19302	1756	2	1	2	2
19303	1756	5	7	3	21
19311	1751	2	1	2	2
19312	1751	8	2	6	12
19329	1767	1	2	2	4
19330	1767	149	4	13	52
19331	1767	25	2	14	28
19332	1767	33	1	11	11
19333	1767	58	1	13	13
19334	1767	46	2	6	12
19335	1767	131	1	22	22
19336	1768	5	4	3	12
19337	1768	1	1	2	2
19348	1770	35	1	17	17
19349	1770	46	4	6	24
19350	1770	58	1	13	13
19351	1769	5	13	3	39
19352	1769	149	2	13	26
19353	1769	190	1	30	30
19354	1769	185	1	50	50
19355	1769	131	1	22	22
19356	1769	132	1	17	17
19357	1769	1	1	2	2
19370	1772	2	1	2	2
19371	1772	3	2	3	6
19372	1772	5	1	3	3
19373	1772	63	1	9	9
19374	1772	57	1	9	9
19375	1772	56	1	12	12
19376	1772	105	1	13	13
19377	1772	130	1	12	12
19378	1772	326	1	13	13
19387	1773	5	4	3	12
19388	1773	149	3	13	39
19389	1774	1	1	2	2
19390	1774	40	3	19	57
19391	1774	3	7	3	21
19392	1774	57	2	9	18
19393	1774	105	1	13	13
19394	1774	52	1	8	8
19402	1775	1	1	2	2
19403	1775	6	5	3	15
19404	1775	96	1	8	8
19439	1771	1	1	2	2
19440	1771	5	5	3	15
19441	1771	3	5	3	15
19442	1771	9	2	12	24
19405	1775	342	1	9	9
19421	1776	1	1	2	2
19422	1776	6	2	3	6
19423	1776	120	4	18	72
19424	1776	44	1	8	8
19425	1776	335	2	5	10
19426	1776	57	2	9	18
19427	1776	27	1	8	8
19428	1776	31	1	9	9
19429	1776	165	1	8	8
19430	1776	172	1	13	13
19431	1776	58	1	13	13
19432	1776	149	1	13	13
19433	1776	213	1	8	8
19434	1776	114	1	10	10
19435	1776	116	1	8	8
24724	2190	8	3	6	18
21111	1880	62	1	9	9
19466	266	1	1	2	2
19467	266	6	8	3	24
19481	507	2	1	2	2
19482	507	4	2	3	6
19483	507	5	1	3	3
19484	507	119	1	31	31
19485	507	347	1	13	13
21112	1880	51	1	8	8
21113	1880	36	1	8	8
21114	1880	30	1	8	8
21115	1880	114	1	10	10
21136	1866	1	1	2	2
21137	1866	6	10	3	30
21138	1866	149	1	13	13
21139	1866	56	2	12	24
21140	1866	150	1	11	11
21141	1866	153	1	17	17
21176	1899	1	1	2	2
19568	1784	2	1	2	2
19569	1784	40	1	19	19
19570	1784	58	1	13	13
19571	1784	46	1	6	6
19572	1784	74	1	8	8
19573	1785	1	1	2	2
19574	1785	3	8	3	24
19623	1788	1	1	2	2
19624	1788	63	1	9	9
19625	1788	106	1	14	14
19626	1788	120	2	18	36
19627	1788	116	1	8	8
19628	1788	149	1	13	13
21177	1899	149	2	13	26
21178	1899	57	1	9	9
21179	1899	41	1	15	15
21180	1899	136	1	8	8
21181	1899	3	3	3	9
21182	1899	32	1	8	8
21183	1899	52	1	8	8
21184	1899	151	1	17	17
21185	1899	148	1	17	17
21186	1899	46	1	6	6
19701	1795	51	3	8	24
19702	1795	130	1	12	12
19703	1795	56	1	12	12
19704	1795	2	1	2	2
19709	1797	1	1	2	2
19710	1797	149	6	13	78
19711	1797	57	2	9	18
19712	1797	52	1	8	8
21187	1899	95	1	8	8
24725	2190	7	2	6	12
24726	2190	1	1	2	2
19734	1799	1	1	2	2
19735	1799	335	2	5	10
19736	1799	6	8	3	24
19737	1799	165	1	8	8
19738	1799	114	1	10	10
19739	1799	58	1	13	13
24744	2194	6	8	3	24
21281	1905	1	1	2	2
21282	1905	6	4	3	12
21283	1905	3	3	3	9
21284	1905	114	1	10	10
21285	1905	116	1	8	8
21286	1905	62	1	9	9
21287	1905	157	1	17	17
21288	1905	32	1	8	8
21289	1905	96	1	8	8
21290	1905	185	1	50	50
21320	1907	1	1	2	2
21321	1907	96	1	8	8
21322	1907	30	1	8	8
21323	1907	108	1	8	8
21324	1907	31	1	9	9
21325	1907	145	1	8	8
21326	1907	32	1	8	8
21349	1908	5	8	3	24
21350	1908	3	3	3	9
21351	1908	1	1	2	2
21366	896	57	2	9	18
21367	896	32	1	8	8
21368	896	31	1	9	9
21369	896	52	1	8	8
24745	2194	3	7	3	21
24746	2194	172	1	13	13
24747	2194	114	1	10	10
24748	2194	35	1	17	17
24757	2179	1	2	2	4
24758	2179	3	7	3	21
21411	1916	1	1	2	2
21412	1916	6	2	3	6
21413	1916	120	1	18	18
21414	1916	43	1	12	12
21415	1916	96	1	8	8
21416	1916	149	1	13	13
21417	1916	130	1	12	12
21418	1916	56	1	12	12
21419	1916	151	1	17	17
21451	1920	1	1	2	2
21452	1920	3	10	3	30
21453	1920	5	5	3	15
21497	1923	1	1	2	2
21498	1923	3	8	3	24
21499	1923	172	1	13	13
21500	1923	242	1	8	8
21501	1923	27	1	8	8
21502	1923	116	1	8	8
21503	1923	39	1	8	8
21504	1923	63	1	9	9
21505	1923	191	1	30	30
21155	1897	5	8	3	24
21156	1897	165	1	8	8
21157	1897	114	1	10	10
21158	1897	96	1	8	8
29091	2487	5	2	3	6
29092	2487	3	4	3	12
29093	2487	339	1	9	9
24749	1491	1	1	2	2
24750	1491	3	8	3	24
24751	1491	57	2	9	18
21222	1901	132	4	17	68
21223	1901	282	1	34	34
29094	2487	342	1	9	9
19455	1777	1	1	2	2
19456	1777	129	1	9	9
19457	1777	32	1	8	8
19458	1777	165	1	8	8
19459	1777	52	1	8	8
19460	1777	63	1	9	9
19461	1777	70	1	8	8
19462	1777	20	1	8	8
19463	1777	166	1	8	8
19502	1779	3	10	3	30
19503	1779	8	2	6	12
19585	7	3	11	3	33
19586	7	36	1	8	8
29095	2487	52	1	8	8
24780	2196	1	2	2	4
24781	2196	58	2	13	26
19617	1789	1	1	2	2
19618	1789	40	1	19	19
19619	1789	33	1	11	11
19620	1789	105	1	13	13
19621	1789	58	1	13	13
19622	1789	6	2	3	6
19660	1791	3	3	3	9
19661	1791	5	3	3	9
19662	1791	2	1	2	2
19663	1791	334	1	8	8
19664	1791	63	1	9	9
19665	1791	114	1	10	10
19666	1791	51	3	8	24
19667	1791	40	1	19	19
19668	1791	29	1	12	12
19669	1791	185	1	50	50
19670	1791	1	1	2	2
24782	2196	26	1	14	14
24783	2196	63	1	9	9
24784	2196	150	1	11	11
24785	2196	149	1	13	13
24786	2196	52	1	8	8
24787	2196	62	1	9	9
19725	1798	1	1	2	2
19726	1798	4	20	3	60
19727	1798	56	2	12	24
21393	1915	3	10	3	30
21394	1915	108	1	8	8
21445	1919	1	1	2	2
21446	1919	6	2	3	6
21447	1919	3	2	3	6
19765	1801	1	1	2	2
19766	1801	4	3	3	9
19767	1801	5	5	3	15
19768	1801	63	1	9	9
19769	1801	114	1	10	10
19770	1801	129	1	9	9
21448	1919	63	1	9	9
21449	1919	131	1	22	22
21450	1919	132	1	17	17
21552	1928	1	1	2	2
21553	1928	6	9	3	27
21554	1928	129	1	9	9
21555	1928	20	1	8	8
21556	1928	63	1	9	9
21575	1930	25	2	14	28
21576	1930	2	2	2	4
21577	1930	6	4	3	12
21578	1930	20	1	8	8
21579	1930	116	1	8	8
21580	1930	143	1	9	9
21581	1930	148	1	17	17
21582	1930	32	1	8	8
21583	1930	39	2	8	16
21584	1930	40	1	19	19
21585	1931	1	1	2	2
21586	1931	6	2	3	6
21587	1931	3	1	3	3
21588	1931	113	1	25	25
21616	600	1	1	2	2
21617	600	3	15	3	45
21618	600	27	1	8	8
21619	600	36	1	8	8
21620	600	20	1	8	8
21662	1937	1	1	2	2
21663	1937	6	2	3	6
21664	1937	153	1	17	17
21665	1937	150	1	11	11
21666	1937	62	1	9	9
21719	1942	1	1	2	2
21720	1942	96	3	8	24
21721	1942	51	2	8	16
21722	1942	62	1	9	9
21723	1942	63	1	9	9
21724	1942	100	1	17	17
21732	1944	1	1	2	2
21733	1944	4	4	3	12
21734	1944	64	2	13	26
21735	1944	129	1	9	9
21736	1944	334	1	8	8
21737	1944	116	1	8	8
21738	1944	52	1	8	8
22277	2002	1	1	2	2
22278	2002	3	3	3	9
22279	2002	5	3	3	9
22280	2002	31	1	9	9
22281	2002	30	1	8	8
22282	2002	96	1	8	8
22286	1972	1	1	2	2
22287	1972	5	2	3	6
22288	1972	32	1	8	8
22289	1972	57	1	9	9
22309	2005	1	1	2	2
22310	2005	5	5	3	15
22311	1968	27	1	8	8
22312	1968	3	2	3	6
29096	2485	5	5	3	15
29097	2485	3	7	3	21
29098	2497	1	1	2	2
19452	1567	1	1	2	2
19453	1567	3	15	3	45
19454	1567	149	3	13	39
29099	2497	32	1	8	8
29100	2497	172	1	13	13
29101	2497	51	2	8	16
29102	2497	52	1	8	8
29103	2497	56	3	12	36
21460	1864	6	2	3	6
21461	1864	5	3	3	9
21462	1864	30	1	8	8
29104	2497	62	2	9	18
24831	2199	1	1	2	2
24832	2199	6	10	3	30
24833	2199	149	1	13	13
24834	2199	33	1	11	11
24835	2199	114	1	10	10
24836	2199	43	1	12	12
24837	2199	52	1	8	8
24838	2199	58	1	13	13
24839	2199	150	1	11	11
24840	2199	65	1	8	8
24841	2199	71	1	8	8
24842	2199	339	1	9	9
21527	1924	1	1	2	2
21528	1924	41	1	15	15
21529	1924	269	1	27	27
21530	1924	3	9	3	27
21531	1924	5	4	3	12
21532	1924	24	1	8	8
21533	1924	101	1	3	3
21542	1926	5	6	3	18
21543	1926	1	1	2	2
21544	1927	1	1	2	2
21545	1927	3	5	3	15
21546	1927	35	3	17	51
24843	2199	56	1	12	12
24844	2199	39	1	8	8
24845	2198	2	1	2	2
24846	2198	43	1	12	12
24847	2198	3	1	3	3
21559	1929	1	1	2	2
19634	1790	1	1	2	2
19635	1790	46	2	6	12
19636	1790	5	10	3	30
21560	1929	6	10	3	30
24848	2198	31	1	9	9
24849	1680	3	10	3	30
24861	2200	1	1	2	2
24862	2200	5	6	3	18
24863	2200	8	2	6	12
24864	2200	58	1	13	13
24865	2200	120	1	18	18
24866	2200	36	1	8	8
24867	2200	35	1	17	17
21670	1938	1	1	2	2
21671	1938	6	3	3	9
21687	1939	2	1	2	2
21688	1939	6	8	3	24
21689	1939	335	5	5	25
29974	2544	1	1	2	2
19654	1792	1	1	2	2
19655	1792	40	1	19	19
19656	1792	25	1	14	14
19657	1792	96	1	8	8
19658	1792	3	8	3	24
19659	1792	6	2	3	6
29975	2544	3	9	3	27
29976	2544	149	1	13	13
29977	2544	260	1	16	16
19746	1800	3	3	3	9
19747	1800	5	5	3	15
19748	1800	58	2	13	26
19749	1800	165	1	8	8
19750	1800	63	1	9	9
19751	1800	1	1	2	2
22313	1968	2	1	2	2
22314	1974	5	2	3	6
22315	1974	114	1	10	10
22316	1974	52	1	8	8
22317	1974	96	1	8	8
22349	1996	3	15	3	45
22363	2007	1	1	2	2
22364	2007	5	9	3	27
22365	2007	3	3	3	9
22436	705	5	5	3	15
22437	705	333	1	8	8
22438	705	165	1	8	8
22439	705	334	1	8	8
22440	705	192	2	30	60
22446	2012	1	1	2	2
22447	2012	4	9	3	27
22448	2012	5	2	3	6
22449	2012	96	1	8	8
22450	2012	166	1	8	8
22463	1977	1	1	2	2
22464	1977	5	2	3	6
22465	1977	3	3	3	9
22466	1977	114	1	10	10
22467	1977	52	2	8	16
22468	1977	107	1	14	14
22490	1987	1	1	2	2
22491	1987	4	8	3	24
22492	1987	260	1	16	16
22493	1987	264	1	10	10
22500	2014	1	1	2	2
22501	2014	3	2	3	6
22502	2014	34	1	8	8
22503	2014	96	1	8	8
22504	2014	52	1	8	8
22505	2014	145	1	8	8
22506	2014	143	1	9	9
22507	2014	4	1	3	3
22508	368	1	1	2	2
22509	368	136	1	8	8
22510	368	20	2	8	16
22511	368	52	1	8	8
22533	2017	1	1	2	2
22534	2017	6	6	3	18
22535	2017	333	1	8	8
22536	2017	341	1	9	9
24788	2196	151	1	17	17
24789	2196	56	2	12	24
24790	2196	3	10	3	30
24809	2	1	1	2	2
24810	2	5	2	3	6
24811	2	57	1	9	9
19509	1780	40	6	19	114
19510	1780	57	1	9	9
19511	1780	58	1	13	13
19512	1780	33	1	11	11
19513	1780	149	2	13	26
19514	1780	63	1	9	9
19515	1780	62	1	9	9
19516	1780	20	2	8	16
19517	1780	116	2	8	16
19518	1780	148	2	17	34
19519	1780	56	1	12	12
19520	1780	52	1	8	8
19521	1780	25	1	14	14
19522	1780	1	1	2	2
19529	1781	282	4	34	136
19530	1781	285	3	15	45
19531	1781	284	1	11	11
19532	1781	185	1	50	50
19533	1781	30	1	8	8
19534	1781	307	1	24	24
19541	1782	2	1	2	2
19542	1782	3	6	3	18
19543	1782	5	2	3	6
19544	1782	149	2	13	26
19575	1750	2	1	2	2
19576	1750	149	2	13	26
19577	1750	46	1	6	6
19713	1796	1	1	2	2
19714	1796	3	4	3	12
19715	1796	5	8	3	24
19716	1796	148	2	17	34
19717	1796	25	1	14	14
19718	1796	62	1	9	9
19719	1796	116	1	8	8
19720	1796	129	1	9	9
19721	1796	242	1	8	8
19771	904	5	4	3	12
19772	904	4	1	3	3
19773	904	57	2	9	18
19774	904	165	1	8	8
19775	904	106	1	14	14
19776	904	64	1	13	13
19777	904	114	1	10	10
19783	1802	1	1	2	2
19784	1802	6	2	3	6
19785	1802	32	1	8	8
19786	1802	51	1	8	8
19787	1802	70	1	8	8
19790	1803	1	1	2	2
19791	1803	6	6	3	18
19803	1361	3	4	3	12
19804	1361	57	2	9	18
19805	1361	120	1	18	18
19806	1361	5	2	3	6
19807	1361	40	1	19	19
19808	1361	33	1	11	11
19809	1361	31	1	9	9
19810	1361	20	1	8	8
19811	1361	64	1	13	13
19812	1361	307	1	24	24
19813	1361	315	1	65	65
19822	1804	1	1	2	2
19823	1804	5	1	3	3
19824	1804	3	5	3	15
19825	1804	40	1	19	19
19826	1804	145	1	8	8
19827	1804	165	2	8	16
19828	1804	20	1	8	8
19829	1804	166	1	8	8
19840	1805	1	1	2	2
19841	1805	335	2	5	10
19842	1805	120	4	18	72
19843	1805	56	2	12	24
19844	1805	44	1	8	8
19845	1805	106	1	14	14
19846	1805	114	1	10	10
19847	1805	20	1	8	8
19848	1805	157	1	17	17
19849	1805	5	1	3	3
19868	1807	3	10	3	30
19869	1807	100	1	17	17
19870	1807	51	1	8	8
19871	1807	24	1	8	8
19872	1807	63	1	9	9
19873	1807	1	1	2	2
19883	1808	1	1	2	2
19884	1808	5	3	3	9
19885	1808	57	4	9	36
19886	1808	58	2	13	26
19887	1808	120	1	18	18
19888	1808	25	1	14	14
19889	1808	157	1	17	17
19890	1808	105	2	13	26
19891	1808	114	1	10	10
19903	1809	5	4	3	12
19904	1809	3	2	3	6
19905	1809	92	1	9	9
19906	1809	151	3	17	51
19907	1809	51	1	8	8
19908	1809	52	1	8	8
19909	1809	57	1	9	9
19910	1809	62	1	9	9
19940	1810	3	2	3	6
19941	1810	136	1	8	8
19942	1810	161	1	8	8
19943	1810	56	1	12	12
19944	1810	51	1	8	8
19945	1810	52	1	8	8
19946	1810	143	1	9	9
19947	1810	1	1	2	2
19969	1811	40	1	19	19
19970	1811	3	3	3	9
19971	1811	213	2	8	16
19972	1813	1	1	2	2
19973	1813	3	11	3	33
19974	1813	52	3	8	24
19975	1813	335	2	5	10
19985	1814	27	1	8	8
19911	1809	96	1	8	8
19912	1809	116	1	8	8
19913	1809	2	1	2	2
19923	1783	4	19	3	57
19924	1783	1	1	2	2
19933	154	1	1	2	2
19934	154	6	9	3	27
19935	154	57	3	9	27
19936	154	96	2	8	16
19937	154	27	2	8	16
19938	154	132	2	17	34
19939	154	46	1	6	6
20025	1817	1	1	2	2
20026	1817	5	8	3	24
20027	1817	43	1	12	12
20028	1817	58	3	13	39
20029	1817	172	2	13	26
20030	1817	130	1	12	12
20031	1817	129	1	9	9
24812	2	344	1	11	11
24813	2	25	1	14	14
21539	1925	3	5	3	15
21540	1925	114	2	10	20
21541	1925	1	1	2	2
24814	2	130	1	12	12
24815	2	63	1	9	9
24816	2	100	1	17	17
24850	1238	1	1	2	2
24851	1238	5	5	3	15
24852	1238	3	7	3	21
24853	2192	295	1	85	85
20092	1823	46	4	6	24
20093	1823	56	2	12	24
20094	1823	62	1	9	9
20095	1823	2	1	2	2
21654	1936	1	1	2	2
21655	1936	5	6	3	18
21656	1936	3	8	3	24
21669	1932	3	10	3	30
21674	1882	3	4	3	12
21675	1882	29	2	12	24
21676	1882	170	1	17	17
21677	1882	34	1	8	8
21678	1882	145	1	8	8
21679	1882	57	1	9	9
21680	1882	63	1	9	9
21681	1882	339	1	9	9
21682	1882	335	1	5	5
21683	1882	70	1	8	8
21693	1940	36	2	8	16
21694	1940	114	2	10	20
21695	1940	1	1	2	2
21699	1941	1	1	2	2
21700	1941	114	3	10	30
21701	1941	96	1	8	8
20216	1835	157	1	17	17
20217	1835	153	1	17	17
20218	1835	30	1	8	8
20219	1835	40	1	19	19
20220	1835	107	1	14	14
20221	1835	104	1	13	13
20222	1835	1	1	2	2
22459	2013	5	2	3	6
22460	2013	3	2	3	6
22461	2013	319	1	14	14
22462	2013	157	1	17	17
22487	1973	1	1	2	2
22488	1973	4	8	3	24
22489	1973	113	1	25	25
20307	1837	3	7	3	21
22571	2019	1	1	2	2
22572	2019	5	6	3	18
22573	2019	341	1	9	9
22574	2019	165	1	8	8
22575	2019	129	1	9	9
22576	2019	41	1	15	15
22577	2019	105	1	13	13
22578	2019	59	1	9	9
22579	2019	62	1	9	9
22580	2019	170	1	17	17
22585	1189	1	1	2	2
22586	1189	5	2	3	6
22587	1189	3	3	3	9
22588	1189	31	1	9	9
22589	1189	109	1	14	14
22590	1189	165	1	8	8
22591	2020	5	6	3	18
22592	2020	4	2	3	6
22593	2020	62	1	9	9
22594	2020	257	1	3	3
22611	2022	1	1	2	2
22612	2022	5	4	3	12
22613	2022	333	3	8	24
22614	2022	65	1	8	8
22615	2022	62	1	9	9
22616	2022	344	2	11	22
22617	2022	166	1	8	8
22618	2022	39	1	8	8
22638	2023	1	1	2	2
22639	2023	62	2	9	18
22640	2023	95	1	8	8
22641	2023	334	1	8	8
22642	2023	257	1	3	3
22658	1980	4	4	3	12
22659	1980	1	1	2	2
22660	1980	149	1	13	13
22661	2026	2	1	2	2
22662	2026	5	2	3	6
22663	2026	62	2	9	18
22664	2026	341	1	9	9
22668	1986	5	1	3	3
22669	1986	4	5	3	15
22670	1986	344	1	11	11
22671	1986	95	1	8	8
22695	2028	2	1	2	2
22696	2028	5	4	3	12
22697	2028	36	3	8	24
22698	2028	62	1	9	9
22699	1983	1	1	2	2
22700	1983	5	5	3	15
22713	344	1	1	2	2
22714	344	3	5	3	15
22715	344	5	2	3	6
22722	1411	40	2	19	38
22723	1411	101	4	3	12
22726	1990	1	1	2	2
21741	1943	1	1	2	2
21742	1943	113	1	25	25
21743	1943	30	1	8	8
21744	1943	96	1	8	8
21745	1943	148	1	17	17
20000	1815	3	4	3	12
20001	1815	63	1	9	9
20002	1815	32	1	8	8
20003	1815	52	1	8	8
20004	1815	46	1	6	6
20005	1815	1	1	2	2
20009	1816	149	2	13	26
20010	1816	172	1	13	13
20011	1816	1	1	2	2
21746	1943	62	1	9	9
21747	1943	36	1	8	8
21748	1943	344	1	11	11
21749	1943	116	1	8	8
21750	1943	145	1	8	8
21751	1943	39	1	8	8
20074	1822	5	3	3	9
20075	1822	120	1	18	18
20076	1822	153	1	17	17
20077	1822	109	1	14	14
20078	1822	64	1	13	13
20079	1822	63	1	9	9
20080	1822	27	1	8	8
20081	1822	149	1	13	13
20082	1822	33	1	11	11
20083	1822	7	2	6	12
20084	1822	1	1	2	2
20089	1821	4	4	3	12
20090	1821	57	3	9	27
20091	1821	278	1	18	18
21796	1948	1	1	2	2
21797	1948	4	10	3	30
20187	1833	1	1	2	2
20188	1833	3	8	3	24
20189	1833	32	1	8	8
20190	1833	57	1	9	9
20191	1833	51	1	8	8
20192	1833	116	1	8	8
20193	1833	56	1	12	12
21798	1948	30	1	8	8
21799	1948	106	1	14	14
21800	1948	150	1	11	11
21801	1948	100	1	17	17
21802	1948	114	1	10	10
21803	1948	40	1	19	19
21807	1949	1	1	2	2
21808	1949	6	10	3	30
21809	1949	56	2	12	24
20275	1841	1	1	2	2
20276	1841	57	1	9	9
20277	1841	6	2	3	6
20278	1841	40	1	19	19
20279	1841	108	1	8	8
20280	1841	63	1	9	9
20281	1841	191	1	30	30
20308	1843	62	1	9	9
20309	1843	63	1	9	9
20310	1843	165	1	8	8
20311	1843	142	1	9	9
20312	1843	339	1	9	9
20313	1843	57	1	9	9
20314	1843	24	1	8	8
20315	1843	303	1	13	13
20320	1845	3	7	3	21
21930	1958	34	1	8	8
21931	1958	96	1	8	8
21932	1958	149	1	13	13
21933	1958	116	1	8	8
21934	1958	4	5	3	15
21996	1964	1	1	2	2
21997	1964	3	2	3	6
21998	1964	62	2	9	18
21999	1964	20	1	8	8
22000	1964	40	1	19	19
22001	1964	34	1	8	8
22002	1964	59	1	9	9
22029	470	3	8	3	24
22030	470	1	1	2	2
22031	470	51	2	8	16
22032	470	52	2	8	16
22033	470	192	1	30	30
22040	1967	1	1	2	2
22041	1967	3	2	3	6
22042	1967	108	1	8	8
22043	1967	129	1	9	9
22044	1967	150	1	11	11
22045	1967	56	1	12	12
22537	2017	136	1	8	8
22552	1537	3	5	3	15
22553	1537	58	2	13	26
22623	1754	34	1	8	8
22624	1754	39	1	8	8
22625	1754	333	1	8	8
22626	1754	91	1	8	8
22630	233	1	1	2	2
22631	233	5	3	3	9
22632	233	3	10	3	30
22651	1976	2	1	2	2
22652	1976	6	15	3	45
22653	1976	185	1	50	50
22665	1985	1	1	2	2
22666	1985	5	3	3	9
22667	1985	4	7	3	21
22672	1988	1	1	2	2
22673	1988	3	6	3	18
22674	1988	5	4	3	12
22675	1988	6	2	3	6
22676	1988	44	1	8	8
22702	1994	1	1	2	2
22703	1994	5	4	3	12
22704	1994	116	1	8	8
22705	1994	20	1	8	8
22706	1994	96	1	8	8
22707	2024	4	6	3	18
22708	2024	5	4	3	12
22709	2024	62	2	9	18
22745	2003	1	1	2	2
22746	2003	3	12	3	36
22747	2003	170	1	17	17
22756	2029	1	1	2	2
22757	2029	6	4	3	12
22758	2029	62	2	9	18
19962	1812	1	1	2	2
19963	1812	5	3	3	9
19964	1812	172	1	13	13
19965	1812	114	1	10	10
19966	1812	65	1	8	8
19967	1812	63	1	9	9
19968	1812	113	1	25	25
21752	1945	1	1	2	2
21753	1945	6	9	3	27
21843	1953	1	1	2	2
21844	1953	3	2	3	6
21845	1953	96	1	8	8
20038	1818	1	1	2	2
20039	1818	64	2	13	26
20040	1818	149	1	13	13
20041	1818	100	1	17	17
20042	1818	27	2	8	16
20043	1818	242	1	8	8
20055	1820	5	3	3	9
20056	1820	25	1	14	14
20057	1820	104	1	13	13
20058	1820	35	1	17	17
20059	1820	1	1	2	2
20103	1824	1	1	2	2
20104	1824	3	5	3	15
20105	1824	5	2	3	6
20106	1824	20	1	8	8
20107	1824	116	1	8	8
20108	1824	57	1	9	9
20109	1824	52	1	8	8
21846	1953	27	1	8	8
21857	1954	1	1	2	2
21858	1954	5	3	3	9
21859	1954	7	2	6	12
21860	1954	52	1	8	8
20142	1829	1	1	2	2
20143	1829	3	15	3	45
20150	1825	1	1	2	2
20151	1825	6	6	3	18
20152	1825	63	2	9	18
20180	1832	5	1	3	3
20181	1832	1	1	2	2
20182	1832	242	3	8	24
20183	1832	52	1	8	8
20184	1832	62	3	9	27
20185	1832	145	1	8	8
20186	1832	46	1	6	6
21861	1954	58	1	13	13
21862	1954	342	1	9	9
21863	1954	20	1	8	8
20204	1836	1	1	2	2
20205	1836	3	11	3	33
20206	1836	96	1	8	8
20223	1732	1	1	2	2
20224	1732	4	1	3	3
20225	1732	3	4	3	12
20226	1732	43	1	12	12
20227	1732	51	1	8	8
20228	1732	96	1	8	8
20229	1732	114	1	10	10
20230	1732	116	1	8	8
21864	1954	59	1	9	9
21865	1954	29	1	12	12
21866	1954	191	1	30	30
21914	1957	1	1	2	2
21915	1957	25	1	14	14
21916	1957	130	1	12	12
21917	1957	109	1	14	14
21918	1957	64	1	13	13
21919	1957	65	1	8	8
21920	1957	36	1	8	8
21921	1957	52	1	8	8
21922	1957	101	1	3	3
21923	1957	33	1	11	11
21924	1957	150	1	11	11
20338	1840	2	1	2	2
20339	1840	58	1	13	13
20340	1840	57	1	9	9
20341	1840	51	1	8	8
20342	1840	52	1	8	8
21955	1705	1	1	2	2
21956	1705	149	5	13	65
22082	1970	1	1	2	2
22083	1970	3	3	3	9
22084	1970	27	4	8	32
22085	1970	120	2	18	36
22086	1970	52	2	8	16
22087	1970	191	1	30	30
22597	1982	1	2	2	4
22598	1982	5	5	3	15
22599	1982	3	3	3	9
22688	2027	1	1	2	2
22689	2027	5	4	3	12
22690	2027	341	1	9	9
22691	2027	41	1	15	15
22692	2027	62	2	9	18
22693	2027	145	1	8	8
22694	2027	344	2	11	22
22701	1993	319	1	14	14
22724	1989	2	1	2	2
22725	1989	104	7	13	91
22730	1991	1	1	2	2
22731	1991	5	3	3	9
22732	1991	3	3	3	9
22733	1991	20	1	8	8
22734	1991	27	1	8	8
22735	1991	116	1	8	8
22736	1997	1	1	2	2
22737	1997	3	4	3	12
22738	1997	5	3	3	9
22739	1997	341	2	9	18
22759	2029	333	1	8	8
22760	2029	37	1	8	8
22770	829	1	1	2	2
22771	829	5	2	3	6
22772	829	3	1	3	3
22773	829	27	2	8	16
22774	829	44	1	8	8
22787	2025	1	2	2	4
22788	2025	5	5	3	15
22789	2025	62	1	9	9
22790	2025	59	1	9	9
22791	2025	163	1	8	8
22792	1998	3	5	3	15
22793	1998	333	2	8	16
19986	1814	57	1	9	9
19987	1814	58	1	13	13
19988	1814	213	1	8	8
19989	1814	335	1	5	5
19990	1814	56	1	12	12
19991	1814	8	1	6	6
19992	1814	62	1	9	9
19993	1814	1	1	2	2
21760	10	1	1	2	2
21761	10	3	4	3	12
21762	10	114	1	10	10
21763	10	51	1	8	8
21764	10	151	1	17	17
21765	10	339	1	9	9
21783	1947	1	1	2	2
21784	1947	6	4	3	12
21785	1947	51	1	8	8
21786	1947	114	1	10	10
21787	1947	56	1	12	12
21817	1950	1	1	2	2
21818	1950	3	5	3	15
21819	1950	149	2	13	26
20049	1819	5	5	3	15
20050	1819	3	2	3	6
20051	1819	335	2	5	10
20052	1819	129	2	9	18
20053	1819	106	1	14	14
20054	1819	1	1	2	2
21820	1950	151	1	17	17
21821	1950	116	2	8	16
21822	1950	51	1	8	8
21823	1950	56	3	12	36
29118	2498	1	1	2	2
29119	2498	6	4	3	12
20127	1827	32	1	8	8
20128	1827	44	1	8	8
20129	1827	116	1	8	8
20130	1827	56	2	12	24
20131	1827	1	1	2	2
20132	1828	6	1	3	3
20133	1828	1	1	2	2
20134	1828	3	7	3	21
20135	1828	20	1	8	8
20136	1828	116	1	8	8
20147	1830	1	1	2	2
20148	1830	5	3	3	9
20149	1830	6	6	3	18
20167	1831	63	2	9	18
20168	1831	52	2	8	16
20169	1831	1	1	2	2
20170	1831	190	1	30	30
21829	1951	3	2	3	6
20240	1838	7	2	6	12
20241	1838	8	2	6	12
20242	1838	1	1	2	2
20243	1838	334	1	8	8
20244	1838	151	2	17	34
20245	1838	100	2	17	34
20246	1838	46	2	6	12
20247	1838	64	1	13	13
20248	1838	130	1	12	12
20256	1839	1	1	2	2
20257	1839	5	2	3	6
20258	1839	3	2	3	6
20259	1839	116	1	8	8
20260	1839	52	1	8	8
20261	1839	56	1	12	12
20262	1839	191	1	30	30
21830	1951	32	1	8	8
21831	1951	52	1	8	8
21832	1951	335	1	5	5
21833	1951	149	1	13	13
21837	1952	3	6	3	18
20287	1794	4	2	3	6
20288	1794	5	3	3	9
20289	1794	32	2	8	16
20290	1794	57	1	9	9
20291	1794	129	1	9	9
20292	1842	1	1	2	2
20293	1842	145	2	8	16
20294	1842	24	1	8	8
20295	1842	62	1	9	9
20296	1842	257	3	3	9
21838	1952	6	6	3	18
21885	1955	1	1	2	2
21886	1955	3	6	3	18
21887	1955	27	1	8	8
21888	1955	62	1	9	9
21889	1955	57	1	9	9
21890	1955	20	1	8	8
21891	1955	172	1	13	13
21892	1955	43	1	12	12
21893	1955	149	1	13	13
21900	1956	1	1	2	2
21901	1956	35	2	17	34
21902	1956	6	6	3	18
21939	1959	1	1	2	2
21940	1959	116	1	8	8
21941	1959	3	7	3	21
21942	1959	257	2	3	6
21959	1961	3	3	3	9
21960	1961	1	1	2	2
22056	1022	1	1	2	2
22057	1022	25	1	14	14
22058	1022	106	1	14	14
22059	1022	109	2	14	28
22060	1022	70	1	8	8
22061	1022	172	1	13	13
22062	1022	52	1	8	8
22727	1990	114	1	10	10
22728	1990	62	1	9	9
22729	1990	96	1	8	8
22761	2006	1	1	2	2
22762	2006	4	5	3	15
22763	2006	157	1	17	17
22764	2006	35	1	17	17
22838	615	5	2	3	6
22839	615	3	7	3	21
22840	615	105	2	13	26
22841	615	333	1	8	8
22842	615	150	1	11	11
22843	615	148	1	17	17
22862	2036	130	1	12	12
22844	615	65	1	8	8
22845	615	62	1	9	9
22846	615	130	1	12	12
22847	615	59	1	9	9
22848	615	41	2	15	30
29120	2498	7	2	6	12
29121	2498	8	3	6	18
22855	2035	1	1	2	2
22856	2035	5	4	3	12
22857	2035	3	4	3	12
22858	2035	333	2	8	16
29122	2498	145	2	8	16
29123	2498	51	3	8	24
29140	2475	1	1	2	2
22886	658	1	1	2	2
22887	658	5	4	3	12
22888	658	333	1	8	8
29141	2475	5	10	3	30
29142	2475	46	2	6	12
24992	327	1	1	2	2
24993	327	3	6	3	18
24994	327	32	2	8	16
22901	2039	1	1	2	2
22902	2039	65	2	8	16
22903	2039	41	1	15	15
22904	2039	148	1	17	17
22905	2039	130	2	12	24
22906	2039	170	2	17	34
22924	2042	5	7	3	21
22925	2042	108	1	8	8
22926	2042	325	1	17	17
22927	2042	130	1	12	12
24995	327	57	2	9	18
24996	327	51	1	8	8
24997	327	116	1	8	8
25011	2206	1	1	2	2
25012	2206	114	1	10	10
25013	2206	71	1	8	8
25014	2206	56	3	12	36
22941	2044	5	8	3	24
22942	2044	130	1	12	12
22943	2044	148	1	17	17
25015	2206	29	1	12	12
25016	2206	151	1	17	17
25017	2206	24	1	8	8
29186	169	1	1	2	2
22961	2047	1	1	2	2
22962	2047	5	2	3	6
22963	2047	4	3	3	9
22964	2047	148	1	17	17
22965	2047	333	1	8	8
22966	2047	170	2	17	34
22967	2047	166	1	8	8
22982	296	1	1	2	2
22983	296	5	4	3	12
22984	296	4	15	3	45
25068	2172	1	2	2	4
25069	2172	3	8	3	24
23001	2051	112	1	41	41
25070	2172	32	1	8	8
23005	2050	4	5	3	15
23016	2056	3	2	3	6
23017	2056	5	1	3	3
23018	2056	6	2	3	6
23019	2056	95	1	8	8
23020	2056	130	2	12	24
23021	2056	333	2	8	16
23022	2056	166	1	8	8
23023	2056	170	1	17	17
23024	2056	108	1	8	8
23025	2056	91	2	8	16
25071	2172	129	1	9	9
25072	2172	57	1	9	9
25073	2172	31	1	9	9
25074	2172	51	1	8	8
25075	2172	343	1	11	11
23050	2063	1	1	2	2
23051	2063	95	2	8	16
23052	2063	333	1	8	8
23053	2063	166	1	8	8
23073	376	1	1	2	2
23074	376	4	4	3	12
23075	376	95	1	8	8
23076	376	168	1	15	15
23077	376	130	1	12	12
25102	2213	266	1	36	36
25103	2213	1	1	2	2
25104	2213	40	3	19	57
25105	2213	148	1	17	17
25106	2213	6	5	3	15
25107	2213	109	1	14	14
25108	2213	114	1	10	10
25109	2169	6	10	3	30
25123	654	1	1	2	2
25124	654	3	3	3	9
25125	654	5	3	3	9
25126	654	57	1	9	9
25127	654	114	1	10	10
25128	654	105	1	13	13
25129	654	339	1	9	9
25130	654	64	1	13	13
25131	654	51	1	8	8
25132	654	52	1	8	8
25133	654	56	1	12	12
25162	1686	307	2	24	48
25163	1686	311	2	30	60
25173	55	1	1	2	2
25174	55	5	7	3	21
25175	55	20	2	8	16
25176	55	163	3	8	24
25177	55	114	2	10	20
25178	55	36	2	8	16
25179	55	95	2	8	16
25180	55	29	1	12	12
25181	55	46	1	6	6
25799	2261	43	2	12	24
25800	2261	342	1	9	9
25801	2261	63	1	9	9
25830	2265	1	1	2	2
25831	2265	25	2	14	28
25832	2265	136	1	8	8
25833	2265	118	1	8	8
25834	2265	63	1	9	9
22863	2036	319	1	14	14
29124	2499	1	1	2	2
29125	2499	6	8	3	24
29126	2499	51	2	8	16
29127	2499	20	2	8	16
22872	2033	1	1	2	2
22873	2033	5	9	3	27
29128	2499	145	2	8	16
29129	2499	24	2	8	16
24888	2201	2	1	2	2
24889	2201	149	7	13	91
29130	2499	191	1	30	30
22935	520	1	1	2	2
22936	520	5	2	3	6
22937	520	6	5	3	15
22946	2045	1	1	2	2
22947	2045	5	12	3	36
22951	2046	1	1	2	2
22952	2046	4	7	3	21
22953	2046	19	1	15	15
29134	2493	1	1	2	2
29135	2493	3	6	3	18
24914	439	40	2	19	38
24915	439	148	1	17	17
24916	439	9	1	12	12
22988	2052	4	4	3	12
22989	2052	5	4	3	12
22990	2052	333	4	8	32
22998	2053	5	8	3	24
24917	439	57	1	9	9
24918	439	132	2	17	34
24919	439	1	1	2	2
29136	2493	28	1	12	12
29137	2490	3	4	3	12
23027	2058	5	11	3	33
23028	2058	95	2	8	16
23029	2058	1	1	2	2
23033	2059	1	1	2	2
23034	2059	112	1	41	41
23035	2059	5	4	3	12
23058	2064	1	1	2	2
23059	2064	5	8	3	24
23060	2064	130	2	12	24
23061	2064	166	1	8	8
24938	2203	1	1	2	2
24939	2203	3	5	3	15
23096	456	1	1	2	2
23097	456	333	1	8	8
23098	456	95	1	8	8
23099	456	5	1	3	3
23100	456	91	1	8	8
24940	2203	32	3	8	24
24941	2203	57	1	9	9
24942	2203	63	1	9	9
24943	2203	145	1	8	8
24944	2203	30	1	8	8
24945	2203	100	1	17	17
24946	2203	46	2	6	12
24947	2203	323	1	20	20
24948	2204	1	1	2	2
24949	2204	6	1	3	3
24950	2204	213	2	8	16
24951	2204	120	2	18	36
24952	2204	30	1	8	8
24953	2204	145	1	8	8
24954	2204	46	1	6	6
24955	2204	62	2	9	18
24968	514	105	2	13	26
24969	514	104	1	13	13
24970	514	1	1	2	2
24971	514	70	1	8	8
24972	514	43	1	12	12
24973	514	319	1	14	14
24998	1345	5	5	3	15
24999	1345	57	1	9	9
25000	1345	32	1	8	8
25001	1345	43	1	12	12
25002	1345	51	1	8	8
25003	1345	20	1	8	8
25024	2207	1	1	2	2
25025	2207	40	1	19	19
25026	2207	3	3	3	9
25027	2207	7	1	6	6
25028	2207	8	8	6	48
25029	2207	35	1	17	17
25082	1225	1	1	2	2
25083	1225	6	8	3	24
25138	2214	1	1	2	2
25139	2214	5	4	3	12
25140	2214	34	3	8	24
25141	2214	56	1	12	12
25184	2217	1	1	2	2
25185	2217	3	6	3	18
25196	2218	2	1	2	2
25197	2218	5	4	3	12
25198	2218	6	2	3	6
25199	2218	30	2	8	16
25200	2218	27	1	8	8
25201	2218	64	1	13	13
25835	2265	28	1	12	12
25836	2265	145	1	8	8
25837	2265	101	2	3	6
25843	2263	1	1	2	2
25844	2263	4	2	3	6
25845	2263	35	1	17	17
25846	2263	58	1	13	13
25847	2263	74	1	8	8
25853	2251	148	1	17	17
25854	2251	20	1	8	8
25875	1568	151	1	17	17
25898	1437	1	1	2	2
25899	1437	334	1	8	8
25900	1437	116	1	8	8
25901	1437	149	4	13	52
25902	1437	62	1	9	9
25903	1437	145	1	8	8
25904	1437	151	1	17	17
25991	2277	114	1	10	10
25992	2277	62	2	9	18
25993	2277	63	1	9	9
25994	2277	1	1	2	2
25995	2277	5	8	3	24
25996	2277	30	1	8	8
25997	2277	339	1	9	9
22880	2038	1	1	2	2
22881	2038	3	5	3	15
22882	2038	132	3	17	51
24906	89	52	1	8	8
24907	89	318	1	12	12
29138	2490	129	2	9	18
29139	2490	1	1	2	2
29143	2500	1	1	2	2
29144	2500	6	3	3	9
22892	94	1	1	2	2
22893	94	5	2	3	6
22894	94	3	5	3	15
29145	2500	3	7	3	21
22912	2040	1	1	2	2
22913	2040	5	7	3	21
22914	2040	187	1	30	30
22915	2040	193	1	22	22
22916	2040	347	1	13	13
22917	2041	5	8	3	24
22918	2041	130	1	12	12
22919	2041	143	1	9	9
23000	2054	5	3	3	9
23002	1098	1	1	2	2
23003	1098	5	3	3	9
23041	2061	5	6	3	18
23042	2061	130	1	12	12
23043	2061	260	1	16	16
23086	2070	1	1	2	2
23087	2070	5	5	3	15
23088	2070	91	1	8	8
23091	2068	1	2	2	4
23092	2068	5	8	3	24
23093	2068	3	2	3	6
23131	2049	4	5	3	15
23132	2069	1	1	2	2
23133	2069	5	5	3	15
23134	2071	1	1	2	2
23135	2071	5	7	3	21
23136	2072	5	1	3	3
23137	2072	3	1	3	3
23138	2055	5	5	3	15
23139	2057	5	4	3	12
23142	1069	282	2	34	68
23143	1069	303	1	13	13
23144	2060	1	1	2	2
23145	2060	5	6	3	18
23146	2062	1	1	2	2
23147	2062	4	2	3	6
23148	2062	5	6	3	18
23152	2081	193	2	22	44
23153	2081	112	1	41	41
23156	2082	330	1	700	700
23157	2082	332	1	850	850
23163	2048	1	1	2	2
23164	2048	5	3	3	9
23165	2048	4	4	3	12
23166	2048	333	1	8	8
23167	2048	192	1	30	30
23168	2048	186	1	30	30
23169	2066	2	1	2	2
23170	2066	5	6	3	18
23171	2073	2	1	2	2
23172	2073	4	2	3	6
23173	2073	39	2	8	16
23174	2073	282	1	34	34
23179	2076	1	1	2	2
23180	2076	5	10	3	30
23181	2076	4	2	3	6
23182	2076	119	1	31	31
23183	2077	1	1	2	2
23184	2077	5	5	3	15
23185	2077	303	1	13	13
23186	2079	282	2	34	68
23187	2079	91	1	8	8
23188	2079	1	1	2	2
23189	2080	286	1	50	50
23190	2080	282	1	34	34
23191	2075	1	1	2	2
23192	2075	4	10	3	30
23193	2075	333	1	8	8
23194	2075	95	1	8	8
23195	2067	1	2	2	4
23196	1140	1	1	2	2
23197	1140	130	1	12	12
23198	1140	333	2	8	16
23199	1140	91	2	8	16
23200	2043	1	1	2	2
23201	2043	5	4	3	12
23202	2043	43	1	12	12
23203	2043	132	1	17	17
23204	2043	131	1	22	22
23205	849	1	1	2	2
23206	849	5	6	3	18
23207	849	4	5	3	15
23208	377	1	1	2	2
23209	377	4	4	3	12
23223	1348	2	1	2	2
23224	1348	4	7	3	21
23225	1348	32	1	8	8
23226	1348	27	1	8	8
23227	1348	57	1	9	9
23228	1348	58	1	13	13
23229	1348	51	1	8	8
23230	1348	46	3	6	18
23231	1348	303	11	13	143
23232	1348	278	1	18	18
23233	1348	315	1	65	65
23234	2083	282	1	34	34
23238	2085	296	1	170	170
23239	2085	295	1	85	85
23260	2084	311	3	30	90
23261	2084	307	2	24	48
23262	2084	303	2	13	26
23316	2091	38	1	8	8
23317	2091	41	1	15	15
23318	2091	339	2	9	18
23319	2091	37	1	8	8
23348	2095	4	8	3	24
23349	2095	57	1	9	9
23350	2095	120	1	18	18
29149	2501	1	1	2	2
29150	2501	6	5	3	15
29151	2501	3	5	3	15
23265	2087	1	1	2	2
23266	2087	165	1	8	8
23267	2087	114	2	10	20
23268	2087	51	1	8	8
23269	2087	58	1	13	13
23270	2087	145	1	8	8
23271	2087	334	1	8	8
23272	2087	25	1	14	14
23273	2087	130	2	12	24
23274	364	91	1	8	8
23275	364	1	1	2	2
23276	364	136	1	8	8
23277	364	165	2	8	16
23278	364	341	1	9	9
23279	364	4	6	3	18
23294	2088	3	2	3	6
23295	2088	27	1	8	8
23296	2088	172	1	13	13
23297	2088	101	4	3	12
23298	2088	58	1	13	13
23299	2088	46	2	6	12
23300	2088	100	1	17	17
23301	2089	1	1	2	2
23302	2089	4	5	3	15
23303	2089	44	2	8	16
23304	2089	46	5	6	30
23305	2089	74	1	8	8
23306	2089	26	1	14	14
23307	2089	313	1	16	16
23334	2094	1	1	2	2
23335	2094	57	1	9	9
23336	2094	114	1	10	10
23337	2094	120	1	18	18
23338	2094	172	1	13	13
23339	2094	165	1	8	8
23340	2094	27	2	8	16
23341	2094	62	1	9	9
23342	2094	282	1	34	34
29172	2503	1	1	2	2
29173	2503	40	1	19	19
23362	2097	2	1	2	2
23363	2097	5	3	3	9
23364	2097	6	3	3	9
25062	2210	2	1	2	2
25063	2210	6	10	3	30
25089	1547	1	1	2	2
23405	2098	2	1	2	2
23406	2098	4	12	3	36
23407	2098	6	2	3	6
23408	2098	56	2	12	24
23416	2101	1	1	2	2
23417	2101	63	1	9	9
23418	2101	31	1	9	9
23419	2101	57	1	9	9
23420	2101	116	1	8	8
23421	2101	172	1	13	13
23422	2101	315	1	65	65
23423	2101	282	1	34	34
23424	2102	1	1	2	2
23425	2102	4	3	3	9
23426	2102	149	2	13	26
23427	2102	52	1	8	8
23428	2103	2	1	2	2
23429	2103	6	10	3	30
23441	1826	4	3	3	9
23442	1826	129	1	9	9
23443	1826	32	1	8	8
23444	1826	27	1	8	8
23472	2106	1	1	2	2
23473	2106	149	2	13	26
23474	2106	150	1	11	11
23475	2106	120	1	18	18
23476	2106	51	1	8	8
23477	2106	26	1	14	14
23478	2106	145	1	8	8
23479	2106	106	1	14	14
25090	1547	3	8	3	24
25091	1547	8	1	6	6
25092	1547	7	3	6	18
25110	2212	3	6	3	18
25111	2212	8	1	6	6
23524	2111	1	1	2	2
23525	2111	113	2	25	50
23526	2111	8	9	6	54
23527	2111	7	1	6	6
25151	2216	1	1	2	2
25152	2216	6	11	3	33
25153	2216	8	2	6	12
25154	2216	9	2	12	24
23568	2114	2	1	2	2
23569	2114	5	2	3	6
23570	2114	7	2	6	12
23571	2114	8	3	6	18
23572	2114	27	1	8	8
23573	2114	39	1	8	8
23574	2114	159	2	17	34
25969	2274	1	1	2	2
25970	2274	4	3	3	9
25971	2274	5	3	3	9
25972	2274	96	2	8	16
23597	2116	1	1	2	2
23598	2116	9	5	12	60
23599	2117	1	1	2	2
23600	2117	3	1	3	3
23601	2117	35	1	17	17
23602	2117	114	1	10	10
23603	2117	172	1	13	13
23604	2117	320	1	14	14
23631	1513	1	1	2	2
23632	1513	153	2	17	34
23633	1513	57	1	9	9
23634	1513	105	1	13	13
23635	1513	56	1	12	12
23636	1513	130	1	12	12
23641	2107	1	1	2	2
23642	2107	3	10	3	30
23678	2122	1	1	2	2
23679	2122	5	2	3	6
23680	2122	6	1	3	3
23681	2122	57	2	9	18
23682	2122	32	1	8	8
23683	2122	172	2	13	26
23684	2122	63	1	9	9
23263	2086	311	1	30	30
23264	2086	315	1	65	65
23310	2090	303	3	13	39
23311	2090	46	1	6	6
25227	2220	1	1	2	2
25228	2220	3	5	3	15
25229	2220	5	4	3	12
25230	2220	27	3	8	24
25231	2220	20	1	8	8
25232	2220	114	1	10	10
25233	2220	26	1	14	14
25234	2220	52	1	8	8
25235	2220	191	2	30	60
25244	2222	1	1	2	2
25245	2222	5	1	3	3
25246	2222	3	3	3	9
25247	2222	31	1	9	9
25248	2222	120	2	18	36
25249	2222	105	1	13	13
23366	2092	1	1	2	2
23367	2092	32	1	8	8
23368	2092	46	4	6	24
23369	970	311	3	30	90
25297	2226	1	1	2	2
25298	2226	6	4	3	12
25299	2226	96	1	8	8
25300	2226	149	1	13	13
25301	2226	63	1	9	9
25302	2226	142	1	9	9
25303	2226	318	1	12	12
25304	2226	130	1	12	12
25305	2226	61	1	8	8
23400	1275	1	1	2	2
23401	1275	5	8	3	24
23402	1275	185	1	50	50
23409	2099	1	1	2	2
23410	2099	5	10	3	30
23411	2100	1	1	2	2
23412	2100	114	1	10	10
23413	2100	51	1	8	8
23414	2100	20	1	8	8
23415	2100	150	1	11	11
25339	2230	1	1	2	2
25340	2230	5	3	3	9
25341	2230	3	3	3	9
25342	2230	32	1	8	8
25343	2230	51	1	8	8
25344	2230	29	1	12	12
23462	1806	1	1	2	2
23463	1806	5	10	3	30
25345	2230	92	1	9	9
23487	2108	1	1	2	2
23488	2108	5	2	3	6
23489	2108	3	4	3	12
23490	2108	114	1	10	10
23491	2108	96	1	8	8
25353	2231	1	1	2	2
25354	2231	6	5	3	15
25355	2231	28	1	12	12
25356	2231	64	1	13	13
25357	2231	105	1	13	13
25358	2231	319	1	14	14
25359	2231	157	2	17	34
23551	2113	149	1	13	13
23552	2113	313	2	16	32
23553	2113	303	1	13	13
25384	2234	1	1	2	2
25385	2234	120	1	18	18
25386	2234	51	3	8	24
23605	2118	1	1	2	2
23606	2118	6	10	3	30
23607	2118	149	3	13	39
23608	2118	46	4	6	24
23609	2118	165	1	8	8
23610	2118	64	1	13	13
25387	2234	63	1	9	9
25399	2235	1	1	2	2
25400	2235	3	4	3	12
25401	2235	96	1	8	8
25402	2235	43	1	12	12
25403	2235	51	1	8	8
25404	2235	52	1	8	8
23618	1274	2	1	2	2
23619	1274	3	2	3	6
23620	1274	31	1	9	9
23621	1274	131	2	22	44
23622	1274	159	2	17	34
23623	1274	39	1	8	8
23624	1274	191	2	30	60
25405	2235	145	1	8	8
25406	2235	30	1	8	8
23648	2120	1	1	2	2
23649	2120	5	4	3	12
23650	2120	165	1	8	8
23651	2120	341	1	9	9
23652	2120	303	2	13	26
25439	2238	1	1	2	2
23660	2121	2	1	2	2
23661	2121	3	5	3	15
23662	2121	114	1	10	10
23663	2121	32	1	8	8
23664	2121	51	2	8	16
23665	2121	52	1	8	8
23666	2121	193	2	22	44
25440	2238	5	2	3	6
25441	2238	32	2	8	16
25442	2238	57	1	9	9
25443	2238	63	1	9	9
25444	2238	56	1	12	12
25445	2238	116	1	8	8
25453	2239	1	1	2	2
25454	2239	5	4	3	12
25455	2239	3	1	3	3
25456	2239	52	1	8	8
25457	2239	63	2	9	18
23724	174	2	1	2	2
23725	174	91	1	8	8
23726	174	149	6	13	78
23727	174	34	1	8	8
23728	174	100	2	17	34
25469	2240	1	1	2	2
25470	2240	32	1	8	8
25471	2240	165	1	8	8
25472	2240	172	2	13	26
23774	2128	1	1	2	2
23775	2128	5	9	3	27
23786	2132	157	2	17	34
25473	2240	150	1	11	11
25474	2240	64	1	13	13
25475	2240	56	1	12	12
25476	2240	52	2	8	16
25477	2240	100	1	17	17
25478	2240	131	1	22	22
23351	2095	43	1	12	12
23352	2095	100	1	17	17
23356	2096	1	1	2	2
23357	2096	5	2	3	6
23358	2096	3	9	3	27
25210	2219	1	1	2	2
25211	2219	3	4	3	12
25212	2219	27	1	8	8
25213	2219	65	1	8	8
25214	2219	118	1	8	8
23398	738	106	4	14	56
23399	738	58	1	13	13
23430	2093	4	5	3	15
23431	2093	46	1	6	6
25215	2219	56	2	12	24
25216	2219	116	1	8	8
25217	2219	315	1	65	65
23445	2104	62	3	9	27
23446	2104	51	1	8	8
23447	2104	30	1	8	8
23448	2104	282	1	34	34
23449	2104	278	1	18	18
29199	945	2	1	2	2
29200	945	6	4	3	12
29201	945	64	1	13	13
29202	945	30	1	8	8
29203	945	120	2	18	36
29204	2504	1	1	2	2
29205	2504	3	4	3	12
29206	2504	172	1	13	13
23501	2109	1	1	2	2
23502	2109	40	2	19	38
23503	2109	9	2	12	24
23504	2109	106	1	14	14
23505	2109	46	2	6	12
23506	2109	130	1	12	12
23507	2109	314	1	30	30
23508	2109	131	1	22	22
23509	2109	132	1	17	17
23515	2110	2	1	2	2
23516	2110	8	11	6	66
23517	2110	7	1	6	6
23518	2110	311	1	30	30
23519	2110	307	2	24	48
23538	2112	1	1	2	2
23539	2112	120	1	18	18
23540	2112	31	1	9	9
23541	2112	36	3	8	24
23542	2112	62	1	9	9
23543	2112	63	1	9	9
23544	2112	51	1	8	8
23545	2112	52	1	8	8
23546	2112	70	1	8	8
23547	2112	278	1	18	18
29207	2504	52	1	8	8
23577	2115	1	1	2	2
23578	2115	3	3	3	9
23579	2115	58	1	13	13
23580	2115	46	1	6	6
23581	2115	20	1	8	8
23582	2115	150	1	11	11
23583	2115	63	1	9	9
23584	2115	193	1	22	22
23690	2123	1	1	2	2
23691	2123	120	2	18	36
23692	2123	149	1	13	13
23693	2123	57	1	9	9
23694	2124	1	1	2	2
23695	2124	58	1	13	13
23696	2124	57	1	9	9
23697	2124	25	1	14	14
23698	2124	28	1	12	12
23706	2125	1	1	2	2
23707	2125	7	3	6	18
23708	2125	344	1	11	11
23709	2125	116	1	8	8
23710	2125	20	1	8	8
23711	2125	51	1	8	8
23712	2125	56	1	12	12
23716	2126	3	8	3	24
23717	2126	1	1	2	2
23718	2126	40	1	19	19
23753	2129	1	2	2	4
23754	2129	5	10	3	30
23755	2129	57	2	9	18
23756	2129	46	4	6	24
23757	2129	35	1	17	17
23758	2129	172	1	13	13
23759	2129	116	1	8	8
23760	2129	51	1	8	8
23761	2129	159	1	17	17
23762	2129	148	1	17	17
23763	2129	185	2	50	100
23764	2129	303	4	13	52
23777	2130	1	1	2	2
23778	2130	40	1	19	19
23779	2130	26	2	14	28
23780	2130	71	1	8	8
23781	2130	101	1	3	3
23782	2131	1	1	2	2
23783	2131	6	6	3	18
23784	2131	8	2	6	12
23785	2131	58	1	13	13
23796	2134	51	2	8	16
23797	2134	1	1	2	2
23798	2133	1	1	2	2
23799	2133	5	5	3	15
23800	2133	32	1	8	8
23801	2133	30	1	8	8
23802	2133	96	1	8	8
23803	2133	57	1	9	9
23804	2133	63	1	9	9
23812	2135	1	1	2	2
23813	2135	40	1	19	19
23814	2135	46	6	6	36
23815	2135	120	1	18	18
23816	2135	339	1	9	9
23817	2135	149	1	13	13
23818	2135	130	1	12	12
23825	2136	314	1	30	30
23826	2136	303	2	13	26
23827	2136	307	3	24	72
23828	2137	1	1	2	2
23829	2137	5	12	3	36
23830	2137	46	1	6	6
23840	2138	1	1	2	2
23841	2138	3	3	3	9
23842	2138	5	3	3	9
23856	2139	3	6	3	18
23843	2138	6	3	3	9
23844	2138	7	2	6	12
23845	2138	58	4	13	52
23846	2138	116	1	8	8
23847	2138	46	1	6	6
23848	2138	153	1	17	17
23871	2140	1	1	2	2
23872	2140	30	1	8	8
23873	2140	105	2	13	26
23874	2140	104	1	13	13
23875	2140	143	1	9	9
23876	2140	40	1	19	19
23877	2140	52	1	8	8
23878	2140	120	1	18	18
29174	2503	3	5	3	15
29175	2503	43	1	12	12
29176	2503	35	1	17	17
29177	2503	150	1	11	11
29178	2503	319	1	14	14
29179	2503	46	1	6	6
29180	2503	25	1	14	14
25293	2227	1	1	2	2
25294	2227	149	6	13	78
25295	2227	52	1	8	8
25296	2227	132	2	17	34
23932	2143	2	1	2	2
23933	2143	40	1	19	19
23934	2143	149	1	13	13
23935	2143	33	1	11	11
23936	2143	57	1	9	9
25324	2229	1	1	2	2
25325	2229	120	3	18	54
25326	2229	149	1	13	13
25327	2229	114	1	10	10
25328	2229	342	1	9	9
25329	2229	100	2	17	34
23963	2145	2	1	2	2
23964	2145	4	3	3	9
23965	2145	46	1	6	6
23966	2145	70	1	8	8
23967	2145	96	2	8	16
23968	2145	342	1	9	9
23969	2145	51	1	8	8
23970	2145	101	1	3	3
25330	2229	35	1	17	17
25338	2170	6	6	3	18
25383	2233	132	1	17	17
25412	2236	1	1	2	2
25413	2236	3	6	3	18
23997	2147	1	1	2	2
23998	2147	40	2	19	38
23999	2147	157	1	17	17
24000	2147	278	1	18	18
25414	2236	40	1	19	19
25458	2065	3	6	3	18
25484	2241	1	1	2	2
25485	2241	5	4	3	12
25486	2241	64	2	13	26
25487	2241	319	1	14	14
25488	2241	59	1	9	9
25509	2160	129	2	9	18
25510	2160	27	1	8	8
25511	2160	91	1	8	8
25521	2245	1	1	2	2
25522	2245	43	1	12	12
25523	2245	36	1	8	8
25524	2245	27	2	8	16
25525	2245	51	1	8	8
25526	2245	52	3	8	24
25527	2245	344	1	11	11
25541	611	36	3	8	24
25542	611	56	1	12	12
25543	611	5	3	3	9
25677	2078	1	1	2	2
25678	2078	6	6	3	18
25679	2078	51	2	8	16
25680	2078	106	1	14	14
25681	2078	116	1	8	8
25757	2257	2	1	2	2
25758	2257	5	2	3	6
25759	2257	43	1	12	12
25760	2257	32	1	8	8
25761	2257	105	1	13	13
25762	2257	52	2	8	16
25763	2257	91	1	8	8
25764	2257	130	1	12	12
25765	2257	20	1	8	8
25766	2257	95	1	8	8
25767	2257	39	1	8	8
25768	2257	327	1	11	11
25824	1793	344	1	11	11
25825	1793	62	1	9	9
25862	2262	6	2	3	6
25863	2262	52	1	8	8
25864	2262	213	1	8	8
25871	2266	1	1	2	2
25872	2266	242	1	8	8
25873	2266	27	1	8	8
25874	2266	5	2	3	6
25928	2270	2	1	2	2
25929	2270	3	11	3	33
25933	1344	1	1	2	2
25934	1344	5	5	3	15
25935	1344	4	5	3	15
25959	2273	1	1	2	2
25960	2273	5	4	3	12
25961	2273	4	2	3	6
25962	2273	33	2	11	22
25963	2273	41	1	15	15
25964	2273	62	1	9	9
26004	2278	2	1	2	2
26005	2278	5	8	3	24
26006	2278	120	1	18	18
26007	2278	105	1	13	13
26008	2278	27	3	8	24
26009	2278	30	1	8	8
26037	1665	1	1	2	2
23857	2139	57	1	9	9
23858	2139	32	1	8	8
23859	2139	51	1	8	8
23860	2139	52	1	8	8
23861	2139	114	1	10	10
23862	2139	148	1	17	17
23899	2141	1	1	2	2
23900	2141	3	8	3	24
23901	2141	57	2	9	18
23902	2141	56	1	12	12
23903	2141	130	2	12	24
23904	2141	315	2	65	130
29219	564	2	1	2	2
29220	564	63	1	9	9
29221	564	52	1	8	8
29222	564	74	1	8	8
29223	564	172	1	13	13
29224	564	319	2	14	28
29225	564	191	1	30	30
29247	2505	1	1	2	2
29248	2505	3	10	3	30
29249	2505	28	2	12	24
23923	1297	2	1	2	2
23924	1297	8	3	6	18
23925	1297	7	4	6	24
23926	1297	33	2	11	22
23946	2144	5	2	3	6
23947	2144	2	1	2	2
23948	2144	57	1	9	9
23949	2144	63	1	9	9
23950	2144	62	1	9	9
23951	2144	149	1	13	13
23952	2144	151	1	17	17
23953	2144	312	1	30	30
23954	2144	307	1	24	24
23982	2146	4	6	3	18
23983	2146	1	1	2	2
23984	2146	43	1	12	12
23985	2146	129	1	9	9
23986	2146	114	1	10	10
23987	2146	58	2	13	26
23988	2146	51	1	8	8
23989	2146	52	1	8	8
23990	2146	159	2	17	34
23991	2146	64	1	13	13
23992	2146	190	1	30	30
29250	2505	143	1	9	9
29251	2505	142	1	9	9
25255	2223	1	1	2	2
25256	2223	145	1	8	8
25257	2223	339	1	9	9
25258	2223	62	1	9	9
25259	2223	63	1	9	9
25260	2223	262	1	28	28
25274	2224	1	1	2	2
25275	2224	5	6	3	18
25276	2224	20	1	8	8
25277	2224	27	1	8	8
25278	2224	64	2	13	26
25279	2224	145	1	8	8
25306	2225	3	10	3	30
25307	2225	62	1	9	9
25308	2225	151	1	17	17
25309	2225	149	1	13	13
25310	2225	43	1	12	12
25311	2225	91	1	8	8
25312	2225	1	1	2	2
25315	2228	131	1	22	22
25316	2228	132	1	17	17
29297	306	1	1	2	2
29298	306	3	6	3	18
25369	2232	1	1	2	2
25370	2232	5	1	3	3
25371	2232	3	4	3	12
25372	2232	63	1	9	9
25374	366	342	1	9	9
25375	366	51	1	8	8
25376	366	145	1	8	8
25377	366	62	2	9	18
25378	366	2	1	2	2
25415	2237	5	2	3	6
25416	2237	3	11	3	33
25417	2237	51	2	8	16
25418	2237	52	1	8	8
25419	2237	1	1	2	2
25433	302	1	1	2	2
25434	302	3	3	3	9
25435	302	27	2	8	16
25436	302	57	2	9	18
25437	302	213	1	8	8
25438	302	191	1	30	30
25451	2221	57	2	9	18
25452	2221	116	2	8	16
25495	2242	1	1	2	2
25496	2242	5	5	3	15
25497	2242	3	2	3	6
25498	2242	57	2	9	18
25499	2242	52	1	8	8
25500	2242	129	1	9	9
25506	2243	1	1	2	2
25507	2243	5	10	3	30
25533	2246	1	1	2	2
25534	2246	5	7	3	21
25535	2246	20	1	8	8
25536	2246	51	1	8	8
25537	2246	56	1	12	12
25552	2247	1	1	2	2
25553	2247	5	2	3	6
25554	2247	32	2	8	16
25555	2247	96	1	8	8
25556	2247	70	1	8	8
25557	2247	51	2	8	16
25558	2247	63	1	9	9
25559	2247	303	1	13	13
25594	1638	5	3	3	9
25595	1638	8	1	6	6
25596	1638	27	1	8	8
25597	1638	163	1	8	8
25598	1638	167	1	8	8
25599	1638	73	1	8	8
25600	1638	58	1	13	13
25601	1638	96	1	8	8
29187	169	3	4	3	12
29188	169	120	3	18	54
29189	169	105	1	13	13
29190	169	58	1	13	13
29191	169	31	2	9	18
25568	2244	1	1	2	2
25569	2244	5	11	3	33
25570	2248	1	1	2	2
25571	2248	40	1	19	19
25572	2248	5	4	3	12
25573	2248	43	1	12	12
25574	2248	150	1	11	11
25575	2248	151	1	17	17
25576	2248	342	1	9	9
25577	2248	260	1	16	16
25646	2252	1	1	2	2
25647	2252	5	2	3	6
25648	2252	7	2	6	12
25649	2252	8	3	6	18
25650	2252	35	1	17	17
25651	2252	319	1	14	14
25652	2252	27	1	8	8
25653	2252	64	1	13	13
25654	2252	56	2	12	24
25655	2252	318	1	12	12
25664	2253	1	1	2	2
25665	2253	6	2	3	6
25666	2253	213	1	8	8
25667	2253	120	1	18	18
25668	2253	149	1	13	13
25669	2253	58	1	13	13
25670	2253	63	1	9	9
25671	2253	185	1	50	50
25694	2254	1	1	2	2
25695	2254	44	1	8	8
25696	2254	52	1	8	8
25697	2254	74	1	8	8
25716	2255	6	2	3	6
25717	2255	1	1	2	2
25718	2255	58	1	13	13
25719	2255	105	1	13	13
25720	2255	62	1	9	9
25721	2255	150	1	11	11
25739	2256	1	1	2	2
25740	2256	91	2	8	16
25741	2256	57	4	9	36
25742	2256	120	1	18	18
25743	2256	63	1	9	9
25744	2256	337	1	9	9
25745	2256	56	2	12	24
25746	2256	51	1	8	8
25747	2256	52	1	8	8
25748	2256	116	1	8	8
25749	2256	28	1	12	12
25750	2256	39	1	8	8
25848	2267	1	1	2	2
25849	2267	30	1	8	8
25850	2267	95	1	8	8
25851	2267	63	1	9	9
25852	2267	343	2	11	22
25855	2259	1	1	2	2
25856	2259	5	2	3	6
25857	2259	149	1	13	13
25858	2259	339	1	9	9
25859	2259	96	1	8	8
25860	2259	129	1	9	9
25861	2259	143	1	9	9
25894	2268	1	1	2	2
25895	2268	4	4	3	12
25896	2268	6	5	3	15
25897	2268	25	1	14	14
25924	1033	1	1	2	2
25925	1033	3	9	3	27
26014	2279	1	1	2	2
26015	2279	6	2	3	6
26016	2279	52	2	8	16
26017	2279	136	2	8	16
26022	2280	5	10	3	30
26023	2280	105	1	13	13
26024	2280	114	1	10	10
26025	2280	64	1	13	13
26030	2281	1	1	2	2
26031	2281	96	1	8	8
26032	2281	71	1	8	8
26033	2281	129	1	9	9
26038	1665	5	4	3	12
26039	1665	104	1	13	13
26084	186	1	1	2	2
26085	186	3	6	3	18
26086	186	151	1	17	17
26087	186	52	2	8	16
26088	186	58	1	13	13
26089	186	32	1	8	8
26090	186	74	1	8	8
26095	2272	2	1	2	2
26096	2272	5	4	3	12
26097	2272	25	1	14	14
26098	2272	105	1	13	13
26102	2283	119	1	31	31
26103	2283	5	1	3	3
26104	2283	6	3	3	9
26105	2283	1	1	2	2
26129	1143	1	1	2	2
26130	1143	342	1	9	9
26131	1143	149	1	13	13
26132	1143	63	1	9	9
26133	1143	96	2	8	16
26134	1143	109	2	14	28
29192	169	26	1	14	14
26108	2271	5	4	3	12
26109	2271	4	2	3	6
26110	2271	96	1	8	8
26111	2271	24	1	8	8
26123	2284	1	1	2	2
26124	2284	5	3	3	9
26125	2284	4	5	3	15
26126	2284	63	2	9	18
29282	2506	1	1	2	2
29283	2506	318	3	12	36
29284	2506	39	1	8	8
29285	2506	149	1	13	13
29286	2506	165	1	8	8
29287	2506	52	1	8	8
29288	2506	6	6	3	18
26158	2288	4	2	3	6
26159	2288	5	5	3	15
26160	2288	96	1	8	8
26161	2288	32	2	8	16
26162	2288	74	1	8	8
26163	2288	24	1	8	8
26195	2290	1	1	2	2
26196	2290	6	7	3	21
26197	2290	118	1	8	8
26198	2290	167	1	8	8
26199	2290	136	1	8	8
26200	2290	30	1	8	8
26201	2290	65	1	8	8
26226	2293	1	1	2	2
26227	2293	4	4	3	12
26228	2293	5	6	3	18
29344	567	303	5	13	65
26243	1151	96	2	8	16
26244	1151	1	1	2	2
26245	1151	114	2	10	20
26246	1151	36	1	8	8
26247	1151	129	1	9	9
26248	1151	334	1	8	8
26249	1151	65	1	8	8
26250	1151	63	2	9	18
26251	1151	51	2	8	16
26252	1151	52	1	8	8
26253	1151	30	1	8	8
26254	1151	74	2	8	16
26255	1151	5	1	3	3
26279	113	4	28	3	84
26280	670	1	1	2	2
26281	670	5	1	3	3
26282	670	43	1	12	12
26283	670	342	1	9	9
26284	670	145	1	8	8
26287	2292	5	3	3	9
26288	2292	109	1	14	14
26289	2292	142	1	9	9
26290	2292	4	1	3	3
26291	2292	44	1	8	8
26292	2296	5	6	3	18
26293	2296	3	1	3	3
26317	2276	4	4	3	12
26318	2276	116	1	8	8
26319	2276	163	1	8	8
26320	2276	96	1	8	8
26321	2276	44	1	8	8
29473	2518	1	1	2	2
29474	2518	3	10	3	30
29475	2518	55	2	8	16
29500	2424	1	1	2	2
29501	2424	213	3	8	24
29502	2424	120	2	18	36
26386	2305	1	1	2	2
26387	2305	6	5	3	15
26388	2305	96	2	8	16
26389	2305	51	1	8	8
26390	2305	52	1	8	8
26421	2307	2	1	2	2
26422	2307	5	2	3	6
26423	2307	4	2	3	6
26424	2307	96	1	8	8
26425	2307	56	1	12	12
26426	2307	131	1	22	22
26427	2307	40	1	19	19
26438	2308	5	5	3	15
26439	2308	3	3	3	9
26440	2308	27	1	8	8
26441	2308	114	1	10	10
26442	2308	51	1	8	8
26443	2308	31	2	9	18
26444	2308	96	1	8	8
26445	2308	62	1	9	9
26446	2308	337	1	9	9
26447	2308	339	1	9	9
26498	2312	1	1	2	2
26499	2312	5	2	3	6
26500	2312	148	1	17	17
26501	2312	33	1	11	11
26502	2312	342	1	9	9
26503	2312	116	1	8	8
26504	2312	96	1	8	8
26505	2312	339	1	9	9
26506	2312	334	1	8	8
26507	2312	245	1	9	9
26519	2314	1	1	2	2
26520	2314	5	3	3	9
26521	2314	116	2	8	16
26552	2316	5	9	3	27
26553	2316	96	2	8	16
26566	2318	2	1	2	2
26567	2318	4	4	3	12
26568	2318	56	1	12	12
26569	2318	101	3	3	9
26574	2320	119	1	31	31
26575	2320	271	1	24	24
26583	704	1	1	2	2
26584	704	5	1	3	3
26585	704	3	3	3	9
26586	704	63	1	9	9
26587	704	120	1	18	18
26588	704	24	1	8	8
26589	704	260	1	16	16
26599	1636	1	1	2	2
26600	1636	32	1	8	8
26601	1636	5	1	3	3
26602	1636	30	1	8	8
26603	1636	62	1	9	9
26604	1636	52	1	8	8
26605	1636	114	1	10	10
26606	1636	101	2	3	6
26607	1636	262	1	28	28
26099	2272	172	1	13	13
26100	2272	114	1	10	10
26101	2272	62	2	9	18
29208	2504	130	1	12	12
29209	2504	26	1	14	14
29226	1709	1	1	2	2
29227	1709	335	6	5	30
26139	2286	1	1	2	2
26140	2286	5	10	3	30
26141	2286	32	2	8	16
29240	1497	1	1	2	2
29241	1497	9	2	12	24
29242	1497	5	3	3	9
29243	1497	51	1	8	8
29244	1497	57	1	9	9
29245	1497	63	1	9	9
29246	1497	46	2	6	12
29255	1560	5	2	3	6
29256	1560	3	5	3	15
26304	2282	1	1	2	2
26305	2282	52	1	8	8
26306	2282	62	1	9	9
26307	2298	5	2	3	6
26308	2298	3	2	3	6
26309	2298	114	1	10	10
26310	2298	143	1	9	9
26311	2298	70	1	8	8
26312	2298	334	1	8	8
26313	2298	65	1	8	8
26342	2300	1	1	2	2
26343	2300	5	4	3	12
26344	2300	44	1	8	8
26345	2300	114	1	10	10
26346	2300	24	2	8	16
26347	2300	63	1	9	9
26348	2300	116	1	8	8
26349	2300	100	1	17	17
26350	2300	130	2	12	24
26351	2300	56	1	12	12
26366	2302	1	1	2	2
26367	2302	5	10	3	30
29257	1560	1	1	2	2
29265	1492	1	1	2	2
29266	1492	151	1	17	17
26378	2304	1	1	2	2
26379	2304	6	3	3	9
26380	2304	96	2	8	16
26394	2303	1	1	2	2
26395	2303	5	5	3	15
26396	2303	119	1	31	31
26418	2195	1	1	2	2
26419	2195	5	9	3	27
26420	2195	4	3	3	9
29267	1492	318	1	12	12
29268	1492	46	2	6	12
29269	1492	56	1	12	12
29270	1492	7	2	6	12
29271	1492	33	1	11	11
26453	2309	1	1	2	2
26454	2309	3	4	3	12
26455	2309	5	2	3	6
26456	2309	165	1	8	8
26457	2309	120	1	18	18
29305	466	3	7	3	21
29306	466	1	1	2	2
29307	466	278	1	18	18
29321	2508	2	1	2	2
29322	2508	335	10	5	50
29323	2508	7	2	6	12
29328	2479	1	1	2	2
29329	2479	5	1	3	3
29330	2479	3	10	3	30
29352	2486	1	1	2	2
29353	2486	3	5	3	15
29354	2486	114	1	10	10
29355	2486	30	1	8	8
29356	2486	57	1	9	9
26525	2315	2	1	2	2
26526	2315	4	7	3	21
26527	2315	96	1	8	8
29357	2486	110	1	9	9
29358	2486	339	1	9	9
26541	612	1	1	2	2
26542	612	4	6	3	18
26543	612	5	3	3	9
26544	612	96	2	8	16
26545	612	149	3	13	39
26546	612	129	1	9	9
26547	612	116	2	8	16
26548	612	62	1	9	9
26549	612	63	1	9	9
26550	612	65	1	8	8
26551	612	150	2	11	22
26558	2317	1	1	2	2
26559	2317	5	10	3	30
26645	2322	2	1	2	2
26646	2322	3	7	3	21
26647	2322	5	9	3	27
26648	2324	2	1	2	2
26649	2324	3	11	3	33
26650	2324	5	6	3	18
29429	2514	5	9	3	27
29430	2514	3	4	3	12
29431	2514	1	1	2	2
29432	2515	278	1	18	18
29433	2515	314	1	30	30
29437	2037	1	1	2	2
29438	2037	3	4	3	12
29439	2037	27	1	8	8
29440	2037	114	1	10	10
29476	2519	1	1	2	2
29477	2519	40	1	19	19
29478	2519	100	1	17	17
29479	2519	57	1	9	9
29480	2519	32	1	8	8
29481	2519	62	1	9	9
29482	2519	28	1	12	12
29483	2519	51	1	8	8
29484	2519	3	3	3	9
29497	2516	1	1	2	2
29498	2516	3	5	3	15
29499	2516	113	1	25	25
29563	246	1	1	2	2
29564	246	110	1	9	9
29565	246	165	1	8	8
29566	246	172	1	13	13
29567	246	335	1	5	5
29568	246	51	1	8	8
29569	246	64	1	13	13
29570	246	74	1	8	8
26135	1143	260	1	16	16
29299	306	43	1	12	12
29300	306	57	1	9	9
29301	306	61	1	8	8
29302	306	130	1	12	12
29303	306	71	1	8	8
29304	306	101	3	3	9
29313	2507	1	1	2	2
26179	2289	1	1	2	2
26180	2289	5	2	3	6
26181	2289	6	2	3	6
26182	2289	58	2	13	26
26183	2289	31	1	9	9
26184	2289	114	1	10	10
26185	2289	51	1	8	8
26186	2289	52	1	8	8
29314	2507	34	1	8	8
29315	2507	32	2	8	16
29316	2507	43	1	12	12
29317	2507	5	10	3	30
26202	943	1	1	2	2
26203	943	4	9	3	27
26204	2291	1	1	2	2
26205	2291	3	2	3	6
26206	2291	116	1	8	8
26207	2291	31	2	9	18
26208	2291	96	1	8	8
26209	2291	30	1	8	8
29337	2509	1	1	2	2
29338	2509	3	3	3	9
29339	2509	57	1	9	9
26220	2275	5	2	3	6
26221	2275	114	1	10	10
26222	2275	32	1	8	8
26223	2275	150	1	11	11
26224	2275	52	1	8	8
26225	2275	30	1	8	8
26256	2294	5	5	3	15
29340	2509	110	1	9	9
29341	2509	92	1	9	9
29342	2509	145	1	8	8
26265	2295	1	1	2	2
26266	2295	5	4	3	12
26267	2295	3	1	3	3
26268	2295	114	1	10	10
26269	2295	30	1	8	8
26270	2295	56	1	12	12
26271	2295	63	1	9	9
26272	2295	62	1	9	9
29382	2510	24	2	8	16
29383	2510	3	3	3	9
29384	2502	1	1	2	2
29385	2502	51	1	8	8
29386	2502	52	1	8	8
29387	2502	63	2	9	18
26314	2297	5	2	3	6
26315	2297	34	2	8	16
26316	2297	1	1	2	2
29388	2511	7	1	6	6
29389	2511	8	1	6	6
29390	2511	31	1	9	9
29391	2511	323	1	20	20
29392	2511	100	1	17	17
26327	2299	1	1	2	2
26328	2299	52	1	8	8
26329	2299	114	2	10	20
26330	2299	63	1	9	9
26331	2299	36	2	8	16
29393	2511	25	1	14	14
29394	2511	56	2	12	24
29395	2511	51	5	8	40
29396	2511	52	1	8	8
29397	2511	41	1	15	15
29398	2511	148	1	17	17
29399	2511	1	2	2	4
29400	2511	3	7	3	21
26360	2301	1	1	2	2
26361	2301	91	2	8	16
26362	2301	5	5	3	15
26363	2301	44	1	8	8
26364	2301	62	1	9	9
26365	2301	107	1	14	14
26370	2205	129	1	9	9
26371	2205	341	1	9	9
29401	2511	43	1	12	12
29402	2511	57	1	9	9
29403	2511	114	1	10	10
29404	2511	26	1	14	14
29405	2511	339	1	9	9
29406	2511	145	1	8	8
29407	2511	20	1	8	8
26404	2306	1	1	2	2
26405	2306	6	2	3	6
26406	2306	3	2	3	6
26407	2306	61	1	8	8
26408	2306	62	1	9	9
26409	2306	63	1	9	9
26410	2306	342	1	9	9
26465	2310	1	1	2	2
26466	2310	5	11	3	33
26467	2310	114	2	10	20
26468	2310	58	1	13	13
26469	2310	116	1	8	8
26470	2310	61	1	8	8
26471	2310	165	1	8	8
26480	2311	1	1	2	2
26481	2311	6	4	3	12
26482	2311	27	2	8	16
26483	2311	32	1	8	8
26484	2311	96	1	8	8
26485	2311	51	1	8	8
26486	2311	52	1	8	8
26487	2311	257	1	3	3
26570	2319	4	6	3	18
26571	2319	1	1	2	2
26624	2321	1	1	2	2
26625	2321	4	2	3	6
26626	2321	3	1	3	3
26627	2321	5	14	3	42
26628	2321	6	2	3	6
26629	2321	142	1	9	9
26630	2321	24	1	8	8
26631	2321	116	1	8	8
26632	2321	271	1	24	24
29408	2511	185	2	50	100
29415	2512	5	2	3	6
29416	2512	57	1	9	9
29417	2512	100	1	17	17
29418	2512	63	1	9	9
26654	814	1	1	2	2
26655	814	5	10	3	30
26656	814	3	1	3	3
29419	2512	99	1	12	12
29420	2512	1	1	2	2
26662	2325	3	6	3	18
26663	2325	5	1	3	3
26664	2325	129	2	9	18
26665	2325	35	1	17	17
26666	2325	95	1	8	8
26670	199	5	4	3	12
26671	199	339	1	9	9
26672	199	51	1	8	8
26678	1681	1	1	2	2
26679	1681	5	10	3	30
26680	1681	6	2	3	6
26681	1681	136	1	8	8
26682	1681	339	1	9	9
26697	2327	5	1	3	3
26698	2327	20	2	8	16
26699	2327	64	1	13	13
26700	2327	63	1	9	9
26701	2327	56	1	12	12
26702	666	1	1	2	2
26703	666	6	6	3	18
26704	666	5	2	3	6
26705	666	341	1	9	9
26706	666	165	1	8	8
26707	666	142	1	9	9
26716	2328	1	1	2	2
26717	2328	114	1	10	10
26718	2328	105	1	13	13
26719	2328	56	2	12	24
26720	2328	41	1	15	15
26721	2328	51	1	8	8
26722	2328	116	1	8	8
26723	2328	132	1	17	17
26729	227	2	1	2	2
26730	227	5	4	3	12
26731	227	130	2	12	24
26732	227	104	1	13	13
26733	227	63	1	9	9
26736	2329	1	1	2	2
26737	2329	5	11	3	33
26743	2330	1	1	2	2
26744	2330	5	4	3	12
26745	2330	32	1	8	8
26746	2330	20	1	8	8
26747	2330	63	1	9	9
26756	2331	1	1	2	2
26757	2331	5	8	3	24
26758	2331	120	1	18	18
26759	2331	342	1	9	9
26760	2331	136	1	8	8
26761	2331	151	1	17	17
26762	2331	341	1	9	9
26763	2331	157	1	17	17
26770	365	1	1	2	2
26771	365	5	5	3	15
26772	365	30	2	8	16
26773	365	63	2	9	18
26774	365	64	2	13	26
26775	365	106	1	14	14
26779	359	1	1	2	2
26780	359	5	6	3	18
26781	359	130	1	12	12
26790	2332	2	1	2	2
26791	2332	3	9	3	27
26792	2332	185	1	50	50
26808	1004	1	1	2	2
26809	1004	4	3	3	9
26810	1004	5	2	3	6
26811	1004	58	1	13	13
26812	1004	34	1	8	8
26813	1004	51	1	8	8
26814	1004	52	1	8	8
26815	2326	1	1	2	2
26816	2326	5	5	3	15
26817	2326	101	2	3	6
26818	1021	3	6	3	18
26819	1021	101	2	3	6
26820	1021	341	1	9	9
26821	1021	73	1	8	8
26822	1021	118	1	8	8
26823	712	1	1	2	2
26824	712	5	7	3	21
26825	2333	5	2	3	6
26826	2333	62	1	9	9
26827	2333	168	1	15	15
26837	2335	1	1	2	2
26838	2335	5	1	3	3
26839	2335	3	1	3	3
26840	2335	150	1	11	11
26841	2335	149	1	13	13
26842	2335	33	1	11	11
26843	2335	105	1	13	13
26844	2335	62	1	9	9
26845	2335	64	1	13	13
26846	2335	189	1	30	30
26848	2336	3	10	3	30
26850	2337	5	7	3	21
26855	2338	1	1	2	2
26856	2338	5	8	3	24
26857	2338	52	1	8	8
26858	2338	20	1	8	8
26871	2339	1	1	2	2
26872	2339	245	1	9	9
26873	2339	334	1	8	8
26874	2339	118	1	8	8
26875	2339	31	1	9	9
26907	2342	1	1	2	2
26923	2343	1	1	2	2
26924	2343	5	9	3	27
26925	2343	165	1	8	8
26926	2343	129	1	9	9
26927	2343	114	1	10	10
26928	2343	101	4	3	12
26876	2339	114	1	10	10
26877	2339	70	1	8	8
26878	2339	24	1	8	8
26879	2339	20	1	8	8
26880	2339	62	1	9	9
26881	2339	64	1	13	13
26882	2339	5	3	3	9
26885	95	4	6	3	18
26886	95	56	1	12	12
29441	2482	2	1	2	2
29442	2482	3	9	3	27
29443	2482	6	5	3	15
29444	2482	307	2	24	48
26895	2341	5	4	3	12
26896	2341	4	2	3	6
29453	2517	1	1	2	2
29454	2517	31	1	9	9
29455	2517	32	1	8	8
29456	2517	96	1	8	8
29457	2517	51	1	8	8
29458	2517	57	1	9	9
29459	2517	163	1	8	8
29460	2517	342	1	9	9
29487	2520	3	12	3	36
29488	2520	1	1	2	2
26994	2347	1	1	2	2
26995	2347	5	5	3	15
26996	2347	109	1	14	14
26997	2347	342	1	9	9
26998	2347	339	1	9	9
26999	2347	149	1	13	13
27000	2347	44	1	8	8
27001	2347	56	2	12	24
27002	2347	101	8	3	24
27021	5	165	2	8	16
27022	5	1	1	2	2
27023	5	52	1	8	8
27024	5	64	1	13	13
27025	5	62	1	9	9
27026	5	20	1	8	8
29550	2524	3	5	3	15
29551	2524	129	1	9	9
29552	2524	32	1	8	8
29553	2524	31	1	9	9
29554	2524	51	1	8	8
27130	2359	1	1	2	2
27131	2359	40	1	19	19
27132	2359	4	1	3	3
27133	2359	28	1	12	12
27134	2359	56	1	12	12
27135	2359	120	1	18	18
27136	2359	130	1	12	12
27137	2359	148	1	17	17
27138	2359	101	3	3	9
27139	2359	149	1	13	13
27154	2358	1	1	2	2
27155	2358	149	2	13	26
27156	2358	58	1	13	13
27157	2358	143	1	9	9
27158	2358	56	1	12	12
27159	2358	148	1	17	17
27160	2358	70	1	8	8
27161	2358	120	1	18	18
27180	2000	1	1	2	2
27181	2000	5	3	3	9
27182	2000	3	3	3	9
27183	2000	44	1	8	8
27184	2000	65	1	8	8
27185	2000	101	2	3	6
27186	1753	56	4	12	48
27187	1753	2	1	2	2
27188	1753	120	2	18	36
27196	407	315	1	65	65
27197	407	132	1	17	17
27198	407	104	1	13	13
27220	2364	1	1	2	2
27221	2364	5	6	3	18
27222	2364	334	2	8	16
27223	2364	104	1	13	13
27224	2364	341	1	9	9
27225	2364	143	1	9	9
27226	2364	109	1	14	14
27227	2364	189	1	30	30
27228	2364	282	3	34	102
27289	2370	295	1	85	85
27290	2370	297	10	3	30
27298	859	1	1	2	2
27299	859	5	8	3	24
27300	859	4	1	3	3
27301	859	148	1	17	17
27302	859	149	1	13	13
27303	859	64	1	13	13
27304	859	20	1	8	8
27341	391	294	1	55	55
27342	391	282	1	34	34
27343	391	112	1	41	41
27344	2361	1	1	2	2
27345	2361	4	7	3	21
27346	2361	5	3	3	9
27347	2361	101	1	3	3
27348	2376	1	1	2	2
27349	2376	334	1	8	8
27350	2376	110	1	9	9
27351	2376	120	1	18	18
27352	2373	1	1	2	2
27353	2373	40	1	19	19
27354	2373	172	1	13	13
27355	2373	3	1	3	3
27361	2367	1	1	2	2
27362	2367	4	2	3	6
27363	2367	5	4	3	12
27364	2367	167	2	8	16
27365	2367	333	1	8	8
27366	2367	41	1	15	15
27367	2367	101	3	3	9
27368	2367	311	2	30	60
26908	2342	6	8	3	24
26909	2342	213	1	8	8
26910	2342	120	1	18	18
26911	2342	105	1	13	13
26912	2342	56	2	12	24
26913	2342	148	2	17	34
26914	2342	91	1	8	8
26915	2342	39	1	8	8
26916	2342	114	1	10	10
26963	1326	1	2	2	4
26964	1326	5	9	3	27
26965	1326	118	2	8	16
26966	1326	4	2	3	6
26967	1326	105	1	13	13
26968	1326	114	1	10	10
26969	1326	120	1	18	18
26970	1326	100	1	17	17
29503	2424	51	1	8	8
29504	2424	52	1	8	8
29505	2424	62	2	9	18
29506	2424	46	1	6	6
29507	2424	145	1	8	8
29508	2513	1	1	2	2
29509	2513	3	6	3	18
29510	2513	191	1	30	30
27040	2350	1	1	2	2
27041	2350	4	4	3	12
27042	2350	136	1	8	8
27043	2350	20	1	8	8
27044	2350	167	1	8	8
27049	2351	1	1	2	2
27050	2351	6	9	3	27
27051	2351	41	1	15	15
27052	2351	56	1	12	12
29526	354	1	1	2	2
29527	354	57	2	9	18
29528	354	32	1	8	8
29529	354	165	1	8	8
29530	354	129	1	9	9
29531	354	51	2	8	16
29532	354	62	1	9	9
29533	354	39	1	8	8
29534	354	116	1	8	8
29535	2521	1	1	2	2
29536	2521	334	1	8	8
29537	2521	95	1	8	8
29538	2521	114	1	10	10
27102	2357	1	1	2	2
27103	2357	4	10	3	30
27104	2357	165	1	8	8
27105	2357	213	1	8	8
27106	2357	65	1	8	8
27107	2357	101	8	3	24
27108	2357	191	1	30	30
27162	2354	5	12	3	36
27163	2354	1	1	2	2
27164	2354	62	1	9	9
27165	2354	70	1	8	8
27166	2354	101	3	3	9
27167	2355	1	1	2	2
27168	2355	5	10	3	30
27169	2355	187	1	30	30
27170	2355	260	1	16	16
29614	2526	1	1	2	2
29615	2526	6	2	3	6
29616	2526	3	2	3	6
29617	2526	57	1	9	9
29618	2526	52	1	8	8
29619	2526	46	1	6	6
27286	2369	311	3	30	90
27287	2369	307	1	24	24
27288	2369	303	1	13	13
27305	2371	312	1	30	30
27306	2371	282	3	34	102
27330	2362	1	1	2	2
27331	2362	5	4	3	12
27332	2362	4	2	3	6
27333	2362	129	1	9	9
27334	2362	167	1	8	8
27335	2362	193	1	22	22
27336	118	65	1	8	8
27337	118	56	1	12	12
27338	118	190	1	30	30
27339	118	1	1	2	2
27340	1003	134	1	129	129
27356	2209	1	1	2	2
27357	2209	64	1	13	13
27358	2209	61	1	8	8
27359	2209	245	1	9	9
27360	2209	337	1	9	9
29672	2529	1	1	2	2
29673	2529	46	10	6	60
29674	2522	1	1	2	2
29675	2522	3	11	3	33
29676	2523	1	1	2	2
29677	2523	3	6	3	18
29678	2523	157	2	17	34
29679	2523	58	1	13	13
29680	2523	32	1	8	8
29681	2523	112	1	41	41
29731	2533	1	1	2	2
29732	2533	57	4	9	36
29733	2533	51	2	8	16
29734	2533	96	1	8	8
29735	2533	313	2	16	32
26935	2344	1	1	2	2
26936	2344	40	1	19	19
26937	2344	5	5	3	15
26938	2344	62	1	9	9
26939	2344	63	1	9	9
26940	2344	70	1	8	8
26948	2345	2	1	2	2
26949	2345	4	2	3	6
26950	2345	5	5	3	15
26951	2345	105	1	13	13
26952	2345	41	1	15	15
26953	2345	62	1	9	9
26954	2345	95	1	8	8
26978	2346	1	1	2	2
26979	2346	5	2	3	6
26980	2346	4	2	3	6
26981	2346	120	1	18	18
26982	2346	105	1	13	13
26983	2346	109	2	14	28
26984	2346	150	1	11	11
27015	2348	1	1	2	2
27016	2348	5	5	3	15
27017	2348	56	1	12	12
27018	2348	150	1	11	11
27019	2348	65	1	8	8
27020	2348	104	1	13	13
27058	2352	1	1	2	2
27059	2352	4	3	3	9
27060	2352	5	3	3	9
27061	2352	149	2	13	26
27062	2352	20	1	8	8
27067	425	1	1	2	2
27068	425	5	6	3	18
27069	425	64	1	13	13
27070	425	157	1	17	17
27171	2356	1	1	2	2
27172	2356	4	7	3	21
27173	2356	5	2	3	6
27174	2356	24	1	8	8
27175	2353	1	1	2	2
27176	2353	5	4	3	12
27177	2353	4	2	3	6
27178	2353	58	2	13	26
27179	2353	323	1	20	20
27208	2363	39	1	8	8
27209	2363	4	2	3	6
27210	2363	44	1	8	8
27229	2365	1	1	2	2
27230	2365	40	1	19	19
27231	2365	149	2	13	26
27232	2365	20	1	8	8
27252	2366	1	1	2	2
27253	2366	5	3	3	9
27254	2366	64	1	13	13
27255	2366	341	1	9	9
27256	2366	149	3	13	39
27257	2366	132	3	17	51
27258	2366	56	1	12	12
27259	2366	129	1	9	9
27260	2366	311	2	30	60
27261	2366	276	2	120	240
27276	846	278	1	18	18
27277	846	295	2	85	170
27278	846	297	5	3	15
27279	2368	278	2	18	36
27280	2368	281	2	11	22
27307	2208	307	3	24	72
27308	2208	311	2	30	60
27309	2372	135	1	99	99
27310	2372	134	1	129	129
27369	2375	5	2	3	6
27370	2375	1	1	2	2
27371	2375	114	1	10	10
27372	2375	58	1	13	13
27373	2375	339	1	9	9
27374	2375	32	1	8	8
27375	2375	311	2	30	60
27376	2375	309	2	11	22
27377	2374	4	4	3	12
27378	2374	96	1	8	8
27379	2374	311	1	30	30
27393	315	2	1	2	2
27394	315	46	4	6	24
27395	315	1	1	2	2
27396	2377	1	1	2	2
27397	2377	27	2	8	16
27398	2377	163	1	8	8
27399	2377	96	1	8	8
27400	2377	36	1	8	8
27401	2377	57	2	9	18
27402	2377	52	1	8	8
27403	2377	51	1	8	8
27404	2377	282	4	34	136
27405	2377	278	2	18	36
27412	2378	1	1	2	2
27413	2378	4	11	3	33
27414	2378	6	3	3	9
27415	2378	58	1	13	13
27416	2378	341	1	9	9
27417	2378	313	1	16	16
27427	2379	1	1	2	2
27428	2379	27	2	8	16
27429	2379	163	2	8	16
27430	2379	32	2	8	16
27431	2379	58	2	13	26
27432	2379	114	1	10	10
27433	2379	46	7	6	42
27434	2379	95	1	8	8
27435	2379	313	2	16	32
27439	2380	131	2	22	44
27440	2380	311	1	30	30
27441	2380	310	1	15	15
27449	2381	1	1	2	2
27450	2381	43	1	12	12
27451	2381	58	1	13	13
27452	2381	35	1	17	17
27453	2381	46	2	6	12
27454	2381	118	1	8	8
27455	2382	307	2	24	48
27456	2382	120	1	18	18
27460	2383	2	1	2	2
27461	2383	58	2	13	26
27462	2383	150	1	11	11
29588	2525	1	1	2	2
29589	2525	3	2	3	6
29590	2525	163	1	8	8
29591	2525	43	1	12	12
29592	2525	25	1	14	14
29593	2525	57	1	9	9
29594	2525	32	1	8	8
29595	2525	96	1	8	8
29596	2525	263	1	10	10
29640	2527	1	1	2	2
29641	2527	5	3	3	9
29642	2527	57	2	9	18
29643	2527	339	2	9	18
29644	2527	52	1	8	8
29645	2527	63	1	9	9
29646	2527	315	2	65	130
29647	2527	278	1	18	18
29655	2400	1	1	2	2
29656	2400	96	1	8	8
29657	2400	62	1	9	9
29658	2400	57	1	9	9
29659	2400	20	1	8	8
29660	2400	32	1	8	8
29661	2400	129	1	9	9
29662	2400	311	1	30	30
29663	2528	1	1	2	2
29664	2528	3	5	3	15
29665	2528	149	1	13	13
29666	2528	62	2	9	18
29667	2528	130	2	12	24
29668	2528	56	2	12	24
29669	2528	63	1	9	9
29689	861	1	1	2	2
29690	861	3	7	3	21
29691	861	57	1	9	9
29692	861	52	1	8	8
29693	861	63	1	9	9
29694	861	25	3	14	42
29695	861	149	1	13	13
29724	2532	318	1	12	12
29725	2532	114	1	10	10
29760	2454	2	1	2	2
29761	2454	3	2	3	6
29762	2454	7	1	6	6
29763	2454	6	5	3	15
29764	2454	149	3	13	39
29765	2454	150	1	11	11
29766	2454	62	1	9	9
29767	2454	64	1	13	13
29809	2536	35	1	17	17
29810	2536	157	1	17	17
29811	2536	46	1	6	6
29815	942	114	1	10	10
29816	942	104	1	13	13
29817	942	51	1	8	8
29838	2360	1	1	2	2
29839	2360	57	1	9	9
29840	2360	61	1	8	8
29841	2360	150	1	11	11
29842	2360	165	1	8	8
29843	2360	145	1	8	8
29844	2360	63	1	9	9
29845	2360	130	1	12	12
29846	2360	109	1	14	14
29847	2360	30	1	8	8
29848	2360	36	1	8	8
29849	2360	277	1	140	140
29850	2360	64	1	13	13
29851	2360	120	1	18	18
29852	2360	114	1	10	10
29853	2360	339	1	9	9
29854	2360	20	1	8	8
29855	2360	28	1	12	12
29895	2539	3	2	3	6
29896	2539	43	1	12	12
29897	2539	116	1	8	8
29898	2539	114	1	10	10
29899	2539	165	1	8	8
29926	2540	1	2	2	4
29927	2540	3	4	3	12
29928	2540	57	2	9	18
29929	2540	104	1	13	13
29930	2540	96	1	8	8
29931	2540	149	2	13	26
29932	2540	120	2	18	36
29933	2540	62	2	9	18
29934	2540	114	1	10	10
29935	2540	116	1	8	8
29936	2540	319	1	14	14
29937	2540	26	1	14	14
29938	2540	151	1	17	17
29939	2541	1	1	2	2
29940	2541	3	7	3	21
29941	2541	5	2	3	6
29955	2542	1	1	2	2
29956	2542	3	2	3	6
29957	2542	32	1	8	8
29958	2542	57	1	9	9
29959	2542	44	1	8	8
29960	2542	334	1	8	8
29961	2542	34	1	8	8
29962	2542	51	1	8	8
29963	2542	116	1	8	8
29964	2542	46	1	6	6
30025	2264	1	1	2	2
30026	2264	20	1	8	8
30027	2264	151	3	17	51
30028	2264	150	1	11	11
30029	2264	101	3	3	9
30030	2264	52	1	8	8
30031	2264	63	1	9	9
30032	2264	62	1	9	9
27467	2384	2	1	2	2
27468	2384	33	2	11	22
27469	2384	131	2	22	44
27470	2384	46	2	6	12
27472	2385	5	25	3	75
27483	2386	3	1	3	3
27484	2386	52	1	8	8
27485	2386	51	1	8	8
27486	2386	58	1	13	13
27487	2386	27	1	8	8
27488	2386	39	1	8	8
27489	2386	116	1	8	8
27490	2386	307	1	24	24
27491	2386	310	1	15	15
27492	2386	2	1	2	2
29628	1016	1	1	2	2
29629	1016	3	4	3	12
29630	1016	7	1	6	6
29631	1016	8	1	6	6
29632	1016	114	1	10	10
29633	1016	32	1	8	8
29634	1016	129	1	9	9
29635	1016	36	1	8	8
29636	1016	145	1	8	8
29637	1016	342	1	9	9
29638	1016	64	1	13	13
29639	1016	192	1	30	30
27512	2388	5	2	3	6
27513	2388	62	1	9	9
27514	2388	8	2	6	12
27515	2388	7	1	6	6
27516	2388	31	2	9	18
27517	2388	151	2	17	34
27518	2388	114	1	10	10
27519	2388	57	1	9	9
27520	2388	163	1	8	8
27521	2388	334	1	8	8
27522	2388	52	1	8	8
27523	2388	1	1	2	2
27524	2388	132	5	17	85
27525	2389	5	11	3	33
27526	2389	342	1	9	9
27527	2389	25	1	14	14
27528	2389	1	1	2	2
27535	2390	6	6	3	18
27536	2390	2	1	2	2
27537	2390	57	1	9	9
27538	2390	43	1	12	12
27539	2390	51	1	8	8
27540	2390	52	1	8	8
27546	2391	40	1	19	19
27547	2391	151	1	17	17
27548	2391	337	1	9	9
27549	2391	101	2	3	6
27550	2391	2	1	2	2
27554	2387	5	12	3	36
27555	2387	1	1	2	2
27556	2392	58	1	13	13
27557	2392	148	1	17	17
27558	2392	303	2	13	26
27573	2349	1	1	2	2
27574	2349	5	3	3	9
27575	2349	34	3	8	24
27576	2349	63	1	9	9
27577	2349	57	1	9	9
27578	2349	172	2	13	26
27579	2393	6	10	3	30
27580	2393	46	6	6	36
27581	2393	64	1	13	13
27582	2393	132	4	17	68
27583	2393	131	1	22	22
27584	2393	315	1	65	65
27585	2393	313	1	16	16
27586	2393	1	1	2	2
27592	2394	1	1	2	2
27593	2394	130	1	12	12
27594	2394	150	1	11	11
27595	2394	337	1	9	9
27596	2394	100	1	17	17
27606	2395	132	2	17	34
27607	2395	1	1	2	2
27608	2395	55	1	8	8
27609	2395	116	1	8	8
27610	2395	57	1	9	9
27611	2395	32	1	8	8
27612	2395	8	1	6	6
27613	2395	7	1	6	6
27614	2395	150	1	11	11
27621	2396	1	1	2	2
27622	2396	51	2	8	16
27623	2396	62	1	9	9
27624	2396	342	1	9	9
27625	2396	278	1	18	18
27626	2396	282	1	34	34
27631	2397	3	25	3	75
27632	2397	8	5	6	30
27633	2397	7	3	6	18
27634	2397	1	1	2	2
27652	2398	2	1	2	2
27653	2398	3	5	3	15
27654	2398	6	10	3	30
27655	2398	63	2	9	18
27656	2398	62	1	9	9
27657	2398	24	1	8	8
27658	2398	145	2	8	16
27659	2398	116	1	8	8
27660	2398	1	1	2	2
27667	2399	3	5	3	15
27668	2399	5	3	3	9
27669	2399	58	2	13	26
27670	2399	311	1	30	30
27677	2401	3	1	3	3
27678	2401	242	2	8	16
27679	2401	30	2	8	16
27680	2401	28	1	12	12
27690	2403	1	1	2	2
27691	2403	6	10	3	30
27692	2403	101	6	3	18
27698	2404	3	2	3	6
27699	2404	163	1	8	8
27710	876	1	1	2	2
27711	876	3	4	3	12
27712	876	27	1	8	8
27713	876	95	1	8	8
27714	876	25	1	14	14
27700	2404	52	1	8	8
27701	2404	110	1	9	9
27702	2404	145	1	8	8
29703	2530	1	1	2	2
29704	2530	5	2	3	6
29705	2530	27	4	8	32
29706	2530	120	1	18	18
29707	2530	35	2	17	34
29708	2530	62	3	9	27
29709	2530	64	1	13	13
29718	2531	2	1	2	2
29719	2531	3	4	3	12
27809	2414	1	1	2	2
27810	2414	3	8	3	24
27811	2414	57	1	9	9
27812	2414	96	1	8	8
27813	2414	51	1	8	8
27814	2414	172	1	13	13
27815	2414	46	1	6	6
29720	2531	51	2	8	16
29721	2531	56	1	12	12
29722	2531	172	1	13	13
29723	2531	190	1	30	30
27834	1873	1	1	2	2
27835	1873	3	5	3	15
27836	1873	6	6	3	18
27837	1873	96	2	8	16
27838	1873	39	1	8	8
27839	1873	46	1	6	6
27856	2417	1	1	2	2
27857	2417	157	1	17	17
27858	2417	327	1	11	11
27859	2417	5	6	3	18
27860	2417	3	3	3	9
27861	2417	62	2	9	18
27862	2417	28	1	12	12
27863	2417	52	1	8	8
27864	2417	114	1	10	10
27865	2417	36	1	8	8
29744	2534	3	4	3	12
29745	2534	5	1	3	3
29746	2534	335	1	5	5
29747	2534	129	1	9	9
29748	2534	34	1	8	8
29749	2534	57	1	9	9
29750	2534	51	2	8	16
29751	2534	339	1	9	9
28017	2430	1	1	2	2
28018	2430	9	1	12	12
28019	2430	3	4	3	12
28020	2430	51	1	8	8
28021	2430	52	1	8	8
28022	2430	118	1	8	8
28023	2430	96	1	8	8
28024	2430	63	1	9	9
28025	2420	63	2	9	18
28026	2420	62	1	9	9
29778	2465	1	1	2	2
29779	2465	5	2	3	6
29780	2465	96	1	8	8
29781	2465	51	1	8	8
29782	2465	52	1	8	8
29783	2465	57	1	9	9
29784	2465	63	1	9	9
29785	2465	36	1	8	8
29786	2465	46	1	6	6
29787	2465	335	2	5	10
28160	2431	3	8	3	24
28161	2431	335	4	5	20
28162	490	1	1	2	2
28163	490	5	12	3	36
28164	490	46	2	6	12
28165	490	64	1	13	13
28173	2438	1	1	2	2
28174	2438	3	20	3	60
28175	2438	62	1	9	9
28176	2438	104	2	13	26
28177	2438	105	1	13	13
28195	2439	2	1	2	2
28196	2439	6	13	3	39
28197	2439	46	3	6	18
28198	2439	62	2	9	18
28199	2439	116	2	8	16
28200	2439	63	1	9	9
28218	576	40	1	19	19
28219	576	3	6	3	18
28220	576	6	4	3	12
29889	2538	1	1	2	2
29890	2538	57	3	9	27
29891	2538	58	2	13	26
29892	2538	44	2	8	16
29893	2538	96	1	8	8
29894	2538	56	1	12	12
29965	2543	132	1	17	17
29966	2543	2	1	2	2
29967	2543	40	1	19	19
29968	2543	34	1	8	8
29969	2543	165	1	8	8
29970	2543	148	1	17	17
29971	2543	116	1	8	8
29972	2543	150	1	11	11
29973	2543	57	1	9	9
29982	2545	1	1	2	2
29983	2545	31	1	9	9
29984	2545	64	1	13	13
29985	2545	110	1	9	9
29999	1083	40	1	19	19
30000	1083	46	4	6	24
30001	1083	1	1	2	2
30002	1083	51	1	8	8
30003	1083	32	1	8	8
30004	1083	33	1	11	11
30011	2546	27	2	8	16
30012	2546	242	2	8	16
30013	2546	96	1	8	8
30014	2546	51	1	8	8
30015	2546	63	1	9	9
27715	876	151	1	17	17
27716	876	278	1	18	18
27754	2402	1	1	2	2
27755	2402	3	5	3	15
27756	2402	43	1	12	12
27757	2402	32	2	8	16
27758	2402	29	1	12	12
27759	2402	52	1	8	8
27776	2410	318	1	12	12
27777	2410	5	2	3	6
27778	2410	3	2	3	6
27779	2410	62	1	9	9
27780	2410	63	1	9	9
27781	2410	342	1	9	9
27782	2410	28	1	12	12
27783	2409	2	1	2	2
27784	2409	6	5	3	15
27785	2409	3	4	3	12
27798	2411	3	3	3	9
27799	2411	32	2	8	16
27800	2411	51	1	8	8
27801	2411	57	1	9	9
29873	2537	5	4	3	12
29874	2537	57	1	9	9
29875	2537	27	2	8	16
29876	2537	114	1	10	10
29877	2537	32	1	8	8
29878	2537	104	1	13	13
29879	2537	149	2	13	26
27866	2418	1	1	2	2
27867	2418	6	2	3	6
27868	2418	57	1	9	9
27869	2418	20	1	8	8
27870	2418	130	1	12	12
27871	2418	100	1	17	17
27880	2412	114	1	10	10
27881	2412	74	1	8	8
27884	2215	1	1	2	2
27885	2215	5	6	3	18
27886	2215	343	1	11	11
27889	2413	1	1	2	2
27890	2413	7	1	6	6
27891	2413	63	1	9	9
27892	2413	40	1	19	19
27893	2413	56	1	12	12
27894	2413	311	2	30	60
27926	2423	1	1	2	2
27927	2423	8	2	6	12
27928	2423	33	2	11	22
27929	2423	149	2	13	26
27930	2423	58	1	13	13
27931	2423	43	1	12	12
27932	2423	25	2	14	28
27933	2423	63	1	9	9
27934	2423	30	1	8	8
27935	2423	52	1	8	8
27936	2423	95	1	8	8
27952	2425	1	1	2	2
27953	2425	3	2	3	6
27954	2425	120	2	18	36
27955	2425	116	1	8	8
27956	2425	342	1	9	9
27957	2425	130	1	12	12
27958	2425	145	1	8	8
28027	2429	1	1	2	2
28028	2429	8	1	6	6
28029	2429	29	2	12	24
28030	2429	58	1	13	13
28031	2421	5	6	3	18
28032	2421	3	4	3	12
28033	2427	1	1	2	2
28034	2427	5	5	3	15
28035	2427	114	1	10	10
28036	2427	36	1	8	8
28042	2432	2	1	2	2
28043	2432	6	5	3	15
28044	2432	3	5	3	15
28046	2433	295	1	85	85
28052	2434	1	1	2	2
28053	2434	3	3	3	9
28054	2434	57	2	9	18
28055	2434	58	1	13	13
28056	2434	41	1	15	15
28093	1498	1	1	2	2
28094	1498	5	8	3	24
28095	1498	46	4	6	24
28096	1498	27	1	8	8
28097	1498	116	1	8	8
28098	1498	56	3	12	36
28099	1498	25	1	14	14
28100	1498	149	3	13	39
28101	1498	151	1	17	17
28102	1498	105	1	13	13
28103	1498	39	1	8	8
28111	2287	58	1	13	13
28112	2287	62	1	9	9
28113	2287	25	1	14	14
28114	2287	132	1	17	17
28115	2287	311	3	30	90
28116	2287	303	1	13	13
28117	2287	1	1	2	2
28171	2435	1	1	2	2
28172	2435	3	10	3	30
28201	2440	1	1	2	2
28202	2440	3	6	3	18
28212	2441	64	1	13	13
28213	2441	32	1	8	8
28214	2441	46	1	6	6
28215	2441	30	1	8	8
28216	2441	129	1	9	9
28217	2441	130	1	12	12
28232	1165	1	1	2	2
28233	1165	6	8	3	24
28294	2449	1	1	2	2
28295	2449	5	4	3	12
28296	2449	120	2	18	36
28297	2449	149	1	13	13
28298	2449	151	1	17	17
27737	2405	1	1	2	2
27738	2405	5	4	3	12
27739	2405	7	1	6	6
27740	2405	8	5	6	30
27741	2405	129	1	9	9
27742	2405	130	1	12	12
27743	2405	51	1	8	8
27744	2407	1	1	2	2
27745	2407	5	7	3	21
27746	2407	6	3	3	9
27747	2407	7	4	6	24
27748	2407	129	1	9	9
27749	2407	63	1	9	9
27750	2406	2	1	2	2
27751	2406	57	2	9	18
27752	2406	64	1	13	13
27753	2406	114	1	10	10
27760	2408	5	6	3	18
27761	2408	3	10	3	30
27762	2408	1	1	2	2
27820	2415	319	1	14	14
27821	2415	96	1	8	8
27822	2415	307	1	24	24
27823	2415	278	1	18	18
27872	1962	1	1	2	2
27873	1962	3	5	3	15
27874	1962	5	5	3	15
27875	1962	62	1	9	9
27876	1962	57	2	9	18
27877	1962	96	1	8	8
27878	1962	129	1	9	9
27879	1962	136	1	8	8
27887	2419	3	3	3	9
27888	2419	5	4	3	12
27968	2426	1	1	2	2
27969	2426	5	3	3	9
27970	2426	3	3	3	9
27971	2426	51	1	8	8
27972	2426	52	1	8	8
27973	2426	36	2	8	16
27974	2426	74	1	8	8
27975	2426	43	1	12	12
27976	2426	20	1	8	8
27993	2428	1	1	2	2
27994	2428	3	5	3	15
27995	2428	114	1	10	10
27996	2428	57	1	9	9
27997	2428	62	1	9	9
27998	2428	334	1	8	8
27999	2428	26	1	14	14
28000	2428	110	1	9	9
28001	2428	116	1	8	8
28002	2428	20	1	8	8
28003	2428	145	1	8	8
28004	2428	51	1	8	8
28075	2142	3	4	3	12
28076	2142	96	1	8	8
28077	2142	110	1	9	9
28078	2142	52	1	8	8
28079	2142	46	3	6	18
28080	2142	30	1	8	8
28081	2142	63	1	9	9
28136	2437	1	1	2	2
28137	2437	7	3	6	18
28138	2437	8	2	6	12
28139	2437	129	2	9	18
28140	2437	57	2	9	18
28141	2437	58	1	13	13
28142	2437	110	1	9	9
28143	2437	163	1	8	8
28144	2437	30	1	8	8
28145	2437	32	1	8	8
28146	2437	114	2	10	20
28147	2437	43	1	12	12
28148	2437	106	2	14	28
28149	2437	105	1	13	13
28150	2437	172	1	13	13
28151	2437	95	2	8	16
28152	2437	342	1	9	9
28153	2437	151	1	17	17
28188	563	1	1	2	2
28189	563	5	4	3	12
28190	563	27	1	8	8
28191	563	343	1	11	11
28192	563	327	1	11	11
28248	2444	1	1	2	2
28249	2444	5	1	3	3
28250	2444	106	1	14	14
28251	2444	96	1	8	8
28252	2444	303	1	13	13
28253	2446	9	1	12	12
28254	2446	1	1	2	2
28255	2446	27	1	8	8
28256	2446	96	2	8	16
28257	2446	51	2	8	16
28258	2446	145	1	8	8
28266	2447	1	1	2	2
28267	2447	3	2	3	6
28268	2447	153	1	17	17
28269	2447	35	1	17	17
28270	2447	63	1	9	9
28271	2447	58	1	13	13
28272	2447	149	2	13	26
28281	2448	1	1	2	2
28282	2448	3	3	3	9
28283	2448	5	2	3	6
28284	2448	63	1	9	9
28285	2448	32	2	8	16
28286	2448	51	1	8	8
28287	2448	30	1	8	8
28288	2448	105	1	13	13
28299	2443	5	5	3	15
28300	2443	3	5	3	15
28301	2443	99	1	12	12
28302	2443	56	2	12	24
28303	2443	1	1	2	2
28304	2443	278	3	18	54
29880	2537	52	1	8	8
29881	2537	51	1	8	8
29882	2537	120	1	18	18
29883	2537	1	1	2	2
30016	2546	258	2	3	6
30082	1255	3	5	3	15
30083	1255	2	1	2	2
30084	2547	46	5	6	30
30085	2547	2	1	2	2
30097	2548	96	1	8	8
30098	2548	339	1	9	9
30099	2548	43	1	12	12
30100	2548	20	1	8	8
30101	2548	25	1	14	14
30108	2549	1	1	2	2
30109	2549	57	1	9	9
30110	2549	335	1	5	5
30111	2549	100	1	17	17
30112	2549	159	1	17	17
30113	2549	96	2	8	16
30114	2549	105	1	13	13
30115	2549	116	1	8	8
30116	2549	51	1	8	8
30117	2549	52	1	8	8
30121	2550	1	1	2	2
30122	2550	130	3	12	36
30123	2550	43	1	12	12
30124	2550	63	1	9	9
30125	2550	149	1	13	13
30126	2550	150	2	11	22
30127	2553	1	1	2	2
30128	2553	63	1	9	9
30129	2553	114	1	10	10
30130	2553	120	1	18	18
30131	2553	339	1	9	9
30132	2553	172	1	13	13
30133	2553	52	1	8	8
30134	2555	2	1	2	2
30135	2555	31	1	9	9
30136	2555	34	1	8	8
30137	959	1	1	2	2
30138	959	40	1	19	19
30139	959	25	1	14	14
30140	959	116	1	8	8
30141	959	52	2	8	16
30142	959	56	2	12	24
30143	959	33	1	11	11
30144	959	64	1	13	13
30145	959	191	1	30	30
30146	959	347	1	13	13
30147	2551	1	1	2	2
30148	2551	40	2	19	38
30149	2551	114	4	10	40
30150	2551	57	2	9	18
30151	2551	63	1	9	9
30152	2551	56	1	12	12
30153	2551	129	1	9	9
30154	2551	20	1	8	8
30155	2551	342	1	9	9
30156	2552	1	1	2	2
30157	2552	40	1	19	19
30158	2552	26	1	14	14
30159	2552	56	1	12	12
30160	2552	120	1	18	18
30161	2552	27	1	8	8
30162	2552	63	1	9	9
30163	2554	1	1	2	2
30164	2554	114	1	10	10
30165	2554	44	1	8	8
30166	2554	213	1	8	8
30167	2554	31	2	9	18
30168	2554	192	1	30	30
30169	1447	1	1	2	2
30170	1447	99	1	12	12
30171	1447	334	1	8	8
30172	1447	32	1	8	8
30173	11	2	1	2	2
30174	11	32	1	8	8
30175	11	145	1	8	8
30176	11	62	1	9	9
30177	11	51	1	8	8
30178	11	27	1	8	8
30179	11	245	1	9	9
30193	2556	1	1	2	2
30194	2556	64	2	13	26
30195	2556	63	2	9	18
30196	2556	116	1	8	8
30197	2556	51	1	8	8
30198	2556	52	1	8	8
30199	2556	75	1	12	12
30200	2556	96	1	8	8
30201	2556	104	1	13	13
30205	2269	51	1	8	8
30206	2269	120	1	18	18
30207	2269	56	2	12	24
30212	1398	1	1	2	2
30213	1398	165	1	8	8
30214	1398	96	1	8	8
30215	1398	113	1	25	25
30216	93	1	1	2	2
30217	93	143	1	9	9
30218	93	52	2	8	16
30219	93	62	1	9	9
30226	2211	2	1	2	2
30227	2211	114	1	10	10
30228	2211	52	2	8	16
30229	2211	51	1	8	8
30230	2211	62	2	9	18
30231	2211	32	1	8	8
30232	2074	278	2	18	36
30241	2557	1	1	2	2
30242	2557	24	1	8	8
30243	2557	148	1	17	17
30244	2557	100	1	17	17
30245	2557	120	2	18	36
30246	2557	52	1	8	8
30247	2557	43	1	12	12
30248	2557	20	1	8	8
30253	2558	34	1	8	8
30254	2558	27	1	8	8
30255	2558	39	2	8	16
30256	2558	1	1	2	2
30261	2559	2	1	2	2
30262	2559	343	2	11	22
30263	2559	62	1	9	9
30268	2560	99	1	12	12
30278	2561	52	4	8	32
30279	2561	51	1	8	8
30280	2561	165	2	8	16
30264	2559	311	3	30	90
30269	2560	52	3	8	24
30270	2560	96	1	8	8
30292	2562	1	1	2	2
30293	2562	110	1	9	9
30294	2562	145	1	8	8
30295	2562	150	1	11	11
30296	2562	114	1	10	10
30297	2562	63	1	9	9
30298	2562	27	1	8	8
30281	2561	149	1	13	13
30282	2561	109	2	14	28
30283	2561	64	1	13	13
30284	2561	2	1	2	2
30306	2563	1	1	2	2
30307	2563	110	1	9	9
30308	2563	36	1	8	8
30309	2563	20	1	8	8
30310	2563	153	1	17	17
30311	2563	63	1	9	9
30312	2563	56	1	12	12
30318	2564	1	1	2	2
30319	2564	114	2	10	20
30320	2564	32	1	8	8
30321	2564	149	1	13	13
30322	2564	260	1	16	16
30326	2313	1	1	2	2
30327	2313	130	2	12	24
30328	2313	149	1	13	13
30332	2565	5	7	3	21
30333	2565	1	1	2	2
30334	2565	32	2	8	16
30337	2566	3	6	3	18
30338	2566	58	2	13	26
30344	2567	1	1	2	2
30345	2567	110	1	9	9
30346	2567	150	1	11	11
30347	2567	62	1	9	9
30348	2567	58	1	13	13
30357	2568	5	5	3	15
30358	2568	1	1	2	2
30359	2568	6	7	3	21
30360	2568	116	2	8	16
30361	2568	110	2	9	18
30362	2568	58	2	13	26
30363	2568	20	1	8	8
30364	2568	52	1	8	8
30367	1766	5	6	3	18
30368	1766	4	5	3	15
30371	2569	5	6	3	18
30372	2569	33	2	11	22
30380	2570	114	1	10	10
30381	2570	339	1	9	9
30382	2570	165	1	8	8
30383	2570	51	1	8	8
30384	2570	63	1	9	9
30385	2570	20	1	8	8
30386	2570	3	4	3	12
30391	2571	5	3	3	9
30392	2571	30	1	8	8
30393	2571	36	2	8	16
30394	2571	335	1	5	5
30401	2573	2	1	2	2
30402	2573	5	11	3	33
30403	2572	1	1	2	2
30404	2572	4	2	3	6
30405	2572	6	2	3	6
30406	2572	335	1	5	5
30411	2574	5	5	3	15
30412	2574	4	2	3	6
30413	2574	120	3	18	54
30414	2574	52	2	8	16
30417	2575	5	2	3	6
30418	2575	51	1	8	8
30428	2576	1	1	2	2
30429	2576	5	7	3	21
30430	2576	4	3	3	9
30439	1745	1	1	2	2
30440	1745	5	3	3	9
30441	1745	3	3	3	9
30442	1745	143	2	9	18
30443	1745	62	2	9	18
30444	1745	334	1	8	8
30445	1745	96	3	8	24
30446	1745	51	1	8	8
30452	1356	1	1	2	2
30453	1356	40	2	19	38
30454	1356	120	1	18	18
30455	1356	56	1	12	12
30456	1356	151	1	17	17
30462	1757	1	1	2	2
30463	1757	4	2	3	6
30464	1757	62	1	9	9
30465	1757	145	1	8	8
30466	1757	109	1	14	14
30471	2578	5	10	3	30
30472	2578	3	3	3	9
30473	2578	172	1	13	13
30474	2578	260	1	16	16
30475	1981	93	1	9	9
30476	1981	133	1	117	117
30477	1359	134	2	129	258
30482	2579	5	4	3	12
30483	2579	3	6	3	18
30484	2579	114	1	10	10
30485	2579	110	1	9	9
30486	2579	264	1	10	10
30487	2579	260	1	16	16
30493	2580	2	1	2	2
30494	2580	27	2	8	16
30495	2580	116	1	8	8
30496	2580	114	1	10	10
30497	2580	261	1	8	8
30502	2581	1	1	2	2
30503	2581	5	4	3	12
30504	2581	3	4	3	12
30505	2581	96	2	8	16
30514	2583	1	1	2	2
30515	2583	6	6	3	18
30516	2583	96	2	8	16
30517	2583	114	1	10	10
30518	2583	56	1	12	12
30539	2584	1	1	2	2
30540	2584	63	1	9	9
30541	2584	27	1	8	8
30542	2584	109	1	14	14
30543	2584	116	1	8	8
30544	2584	56	1	12	12
30545	2584	262	1	28	28
30568	2582	6	2	3	6
30569	2582	40	1	19	19
30570	2582	1	1	2	2
30595	2589	2	1	2	2
30596	2589	5	4	3	12
30597	2589	31	1	9	9
30619	2592	114	1	10	10
30620	2592	129	1	9	9
30621	2592	165	1	8	8
30622	2592	5	2	3	6
30623	2592	3	1	3	3
30680	2597	1	1	2	2
30681	2597	149	5	13	65
30689	2598	1	1	2	2
30690	2598	165	2	8	16
30691	2598	51	2	8	16
30692	2598	63	1	9	9
30693	2598	149	1	13	13
30694	2598	114	1	10	10
30695	2598	191	2	30	60
30699	1408	114	1	10	10
30700	1408	96	1	8	8
30701	1408	30	1	8	8
30711	2599	1	1	2	2
30712	2599	5	8	3	24
30713	2599	3	8	3	24
30722	2601	63	2	9	18
30723	2601	327	1	11	11
30727	2602	1	1	2	2
30728	2602	3	8	3	24
30729	2602	5	3	3	9
30746	275	5	2	3	6
30747	275	6	4	3	12
30753	2594	31	2	9	18
30754	2594	63	1	9	9
30755	2594	52	1	8	8
30756	2594	20	1	8	8
30757	2594	4	3	3	9
30768	2591	2	1	2	2
30769	2591	58	2	13	26
30770	2591	56	2	12	24
30781	2604	5	18	3	54
30782	2604	20	1	8	8
30797	2606	1	1	2	2
30798	2606	5	6	3	18
30799	2606	63	1	9	9
30800	2606	145	1	8	8
30801	2606	51	1	8	8
30802	2606	52	1	8	8
30803	2606	119	1	31	31
30804	2606	186	1	30	30
30821	2605	142	1	9	9
30822	2605	51	1	8	8
30823	2605	62	1	9	9
30824	2605	96	1	8	8
30825	2605	245	1	9	9
30826	2605	1	1	2	2
30997	2620	1	1	2	2
30998	2620	5	6	3	18
30999	2620	99	1	12	12
31000	2620	33	1	11	11
31001	2620	109	1	14	14
31002	2620	341	1	9	9
31003	2620	105	1	13	13
31004	907	5	2	3	6
31005	907	129	1	9	9
31006	907	75	1	12	12
31007	907	64	1	13	13
31008	907	52	1	8	8
31023	2622	5	2	3	6
31024	2622	4	1	3	3
31025	2622	151	1	17	17
31101	1640	1	1	2	2
31102	1640	5	3	3	9
31103	1640	3	1	3	3
31104	1640	64	1	13	13
31105	1640	159	1	17	17
30532	124	1	2	2	4
30533	124	150	5	11	55
30534	124	118	5	8	40
30535	124	63	5	9	45
30536	124	165	4	8	32
30537	124	62	1	9	9
30538	124	96	5	8	40
30555	2585	1	1	2	2
30556	2585	5	7	3	21
30557	2585	149	4	13	52
30558	2585	165	1	8	8
30559	2585	52	1	8	8
30560	2585	20	1	8	8
30561	2585	30	1	8	8
30562	2585	63	1	9	9
30563	2585	40	3	19	57
30566	2586	1	1	2	2
30567	2586	4	10	3	30
30571	2577	3	4	3	12
30572	2577	27	1	8	8
30573	2577	44	1	8	8
30574	2577	96	1	8	8
30575	2577	145	1	8	8
30576	2577	334	1	8	8
30582	578	2	1	2	2
30583	578	6	3	3	9
30584	578	63	1	9	9
30585	578	64	1	13	13
30586	578	153	1	17	17
30610	2588	5	2	3	6
30628	891	5	3	3	9
30629	891	150	1	11	11
30630	891	63	1	9	9
30631	891	51	1	8	8
30670	2595	1	1	2	2
30671	2595	5	4	3	12
30672	2595	4	2	3	6
30673	2595	24	2	8	16
30674	2595	116	1	8	8
30675	2595	20	1	8	8
30705	346	103	1	31	31
30706	346	76	1	36	36
30707	346	264	1	10	10
30734	230	52	2	8	16
30735	230	149	1	13	13
30736	230	151	1	17	17
30737	230	20	1	8	8
30748	590	1	1	2	2
30749	590	4	3	3	9
30750	590	3	2	3	6
30751	590	58	1	13	13
30752	590	328	1	15	15
30763	2603	5	1	3	3
30764	2603	114	1	10	10
30765	2603	62	1	9	9
30766	2603	172	1	13	13
30767	2603	56	1	12	12
30830	2608	1	1	2	2
30831	2608	5	20	3	60
30832	2608	149	2	13	26
30849	2609	1	1	2	2
30850	2609	30	1	8	8
30851	2609	64	1	13	13
30852	2609	63	1	9	9
30853	2609	52	1	8	8
30868	2612	1	1	2	2
30869	2612	6	4	3	12
30870	2612	44	1	8	8
30871	2612	20	1	8	8
30872	2612	71	1	8	8
30873	2612	73	1	8	8
30874	2612	74	1	8	8
30875	2612	30	1	8	8
30892	2613	5	5	3	15
30893	2613	1	1	2	2
30894	2613	114	1	10	10
30895	2613	339	1	9	9
30896	2613	116	1	8	8
30903	2614	1	1	2	2
30904	2614	5	1	3	3
30905	2614	3	2	3	6
30906	2614	130	1	12	12
30907	2614	147	1	8	8
30908	2614	193	1	22	22
30924	2158	5	2	3	6
30925	2158	6	3	3	9
30926	2158	1	1	2	2
30927	2158	114	1	10	10
30928	2158	31	1	9	9
30959	2616	1	1	2	2
30960	2616	167	2	8	16
30961	2616	52	1	8	8
30962	2616	51	1	8	8
30963	2616	62	2	9	18
30964	2617	1	1	2	2
30965	2617	3	7	3	21
30966	2617	56	1	12	12
31019	2535	5	5	3	15
31020	2535	4	5	3	15
31021	2535	63	1	9	9
31022	2535	51	5	8	40
31038	2625	1	1	2	2
31039	2625	6	4	3	12
31040	2625	110	1	9	9
31041	2625	51	1	8	8
31052	2626	6	2	3	6
31053	2626	58	1	13	13
31054	2626	52	1	8	8
31055	2626	105	1	13	13
31056	2626	3	3	3	9
31077	2628	1	1	2	2
31078	2628	4	7	3	21
31079	2628	260	1	16	16
30589	2587	1	1	2	2
30590	2587	3	4	3	12
30604	2590	1	1	2	2
30605	2590	4	4	3	12
30606	2590	5	4	3	12
30607	2590	51	1	8	8
30608	2590	61	1	8	8
30609	2590	132	1	17	17
30648	2593	1	1	2	2
30649	2593	5	5	3	15
30650	2593	116	1	8	8
30651	2593	56	1	12	12
30652	2593	63	1	9	9
30653	2593	192	1	30	30
30676	2596	1	3	2	6
30677	2596	4	40	3	120
30717	2600	1	1	2	2
30718	2600	112	1	41	41
30719	2600	5	10	3	30
30742	2258	1	1	2	2
30743	2258	5	1	3	3
30744	2258	3	1	3	3
30745	2258	105	1	13	13
30771	995	5	3	3	9
30772	995	6	3	3	9
30773	995	4	3	3	9
30774	995	32	1	8	8
30775	995	74	1	8	8
30776	995	27	1	8	8
30777	995	20	1	8	8
30778	995	116	1	8	8
30813	2607	1	1	2	2
30814	2607	5	5	3	15
30815	2607	145	1	8	8
30816	2607	20	1	8	8
30817	2607	51	1	8	8
30818	2607	96	1	8	8
30819	2607	63	1	9	9
30820	2607	64	1	13	13
30836	216	1	1	2	2
30837	216	5	13	3	39
30838	216	149	5	13	65
30876	2610	5	5	3	15
30877	2610	114	1	10	10
30878	2610	1	1	2	2
30879	864	1	1	2	2
30880	864	5	7	3	21
30881	864	149	2	13	26
30882	864	318	1	12	12
30883	864	63	1	9	9
30884	2611	193	1	22	22
30885	2611	5	6	3	18
30886	2611	61	1	8	8
30914	1786	1	1	2	2
30915	1786	5	10	3	30
30916	1786	3	3	3	9
30917	1786	116	1	8	8
30918	1786	52	1	8	8
30940	1142	1	1	2	2
30941	1142	5	6	3	18
30942	1142	149	2	13	26
30943	1142	64	1	13	13
30944	1142	61	1	8	8
30945	1142	56	2	12	24
30946	1142	339	1	9	9
30947	2615	1	1	2	2
30948	2615	4	2	3	6
30949	2615	116	1	8	8
30950	2615	151	1	17	17
30971	2618	1	1	2	2
30972	2618	5	6	3	18
30973	2618	51	1	8	8
30974	2618	150	1	11	11
30980	2619	1	1	2	2
30981	2619	5	3	3	9
30982	2619	3	3	3	9
30983	2619	149	1	13	13
30984	2619	39	1	8	8
31031	2624	5	6	3	18
31032	2624	4	1	3	3
31033	2624	39	1	8	8
31063	2627	1	1	2	2
31064	2627	149	2	13	26
31065	2627	150	1	11	11
31066	2627	339	1	9	9
31067	2627	56	1	12	12
31068	1787	1	1	2	2
31069	1787	5	3	3	9
31070	1787	4	3	3	9
31071	1787	51	1	8	8
31072	1787	52	2	8	16
31073	1787	130	1	12	12
31115	2632	1	1	2	2
31116	2632	4	7	3	21
31117	2632	172	1	13	13
31118	2632	64	1	13	13
31119	2632	106	1	14	14
31120	2632	114	1	10	10
31129	387	5	5	3	15
31130	387	3	5	3	15
31131	2621	5	1	3	3
31132	2630	245	2	9	18
31133	2630	31	1	9	9
31134	2630	51	1	8	8
31135	2630	1	1	2	2
31136	2630	334	1	8	8
31137	2629	1	1	2	2
31138	2629	5	6	3	18
31139	2629	6	5	3	15
31140	2629	149	2	13	26
31141	2629	129	1	9	9
31142	2631	4	5	3	15
31143	2631	24	1	8	8
31144	2631	1	1	2	2
31178	2634	1	1	2	2
31179	2634	31	1	9	9
31180	2634	109	1	14	14
31181	2634	51	1	8	8
31145	2633	1	1	2	2
31146	2633	5	2	3	6
31147	2633	3	6	3	18
31148	2633	149	1	13	13
31149	2633	58	1	13	13
31150	2633	39	1	8	8
31151	2633	52	1	8	8
31152	2633	56	1	12	12
31153	2633	266	1	36	36
31168	2635	1	1	2	2
31169	2635	4	5	3	15
31170	2635	129	1	9	9
31171	2635	110	2	9	18
31172	2635	101	3	3	9
31173	2635	64	2	13	26
31174	2635	30	1	8	8
31175	2635	130	3	12	36
31176	2635	52	1	8	8
31177	2635	31	1	9	9
31209	2639	2	1	2	2
31210	2639	3	5	3	15
31211	2639	64	1	13	13
31212	2639	105	1	13	13
31225	2640	40	1	19	19
31226	2640	4	10	3	30
31227	2640	334	1	8	8
31228	2640	31	1	9	9
31229	2640	51	1	8	8
31230	2640	52	1	8	8
31231	2640	337	1	9	9
31232	2640	1	1	2	2
31236	2641	1	1	2	2
31237	2641	4	6	3	18
31238	2641	185	1	50	50
31265	2644	1	1	2	2
31266	2644	4	5	3	15
31267	2644	149	3	13	39
31268	2644	64	1	13	13
31269	2644	99	1	12	12
31270	2644	56	1	12	12
31283	2646	1	1	2	2
31284	2646	4	9	3	27
31409	984	4	4	3	12
31410	984	32	2	8	16
31411	984	73	2	8	16
31412	984	75	1	12	12
31413	984	56	1	12	12
31432	2340	1	1	2	2
31433	2340	4	4	3	12
31434	2340	114	1	10	10
31435	2340	52	1	8	8
31436	2340	61	1	8	8
31437	2340	56	1	12	12
31446	2654	1	1	2	2
31447	2654	61	1	8	8
31448	2654	51	1	8	8
31449	2654	52	1	8	8
31450	2654	30	1	8	8
31451	2654	147	1	8	8
31452	823	1	1	2	2
31473	1320	1	1	2	2
31486	2637	2	1	2	2
31487	2637	24	1	8	8
31488	2637	3	1	3	3
31527	2662	1	1	2	2
31528	2662	103	1	31	31
31529	2662	112	2	41	82
31530	2662	75	1	12	12
31531	2662	148	1	17	17
31532	2662	44	1	8	8
31533	2662	335	1	5	5
31538	444	1	1	2	2
31539	444	4	1	3	3
31540	444	105	1	13	13
31541	444	39	1	8	8
31542	2660	1	1	2	2
31543	2660	3	6	3	18
31544	2660	109	1	14	14
31545	2660	56	1	12	12
31546	2660	319	1	14	14
31547	2031	278	4	18	72
31548	2031	281	1	11	11
31549	2031	279	1	5	5
31550	1606	303	5	13	65
31551	1606	307	1	24	24
31552	1606	315	1	65	65
31553	1606	313	1	16	16
31554	2416	1	1	2	2
31555	2416	103	1	31	31
31556	2416	112	1	41	41
31243	2642	1	1	2	2
31244	2642	245	1	9	9
31245	2642	99	1	12	12
31246	2642	30	1	8	8
31253	2643	1	1	2	2
31254	2643	4	3	3	9
31255	2643	24	1	8	8
31256	2643	101	3	3	9
31257	2643	264	1	10	10
31258	2643	257	2	3	6
31293	1362	1	1	2	2
31294	1362	4	5	3	15
31295	1362	99	1	12	12
31296	1362	148	1	17	17
31297	1362	339	1	9	9
31305	2648	1	1	2	2
31306	2648	4	4	3	12
31307	2648	71	1	8	8
31308	2648	56	1	12	12
31309	2648	130	1	12	12
31310	2648	39	2	8	16
31311	2648	101	1	3	3
31331	650	4	5	3	15
31332	650	1	1	2	2
31333	650	56	2	12	24
31334	650	105	1	13	13
31335	650	319	1	14	14
31336	650	129	1	9	9
31421	2659	1	1	2	2
31422	2659	112	1	41	41
31423	2659	4	2	3	6
31424	2659	56	1	12	12
31425	2659	105	1	13	13
31426	2659	314	1	30	30
31427	2659	117	1	24	24
31428	2334	149	1	13	13
31429	2334	64	1	13	13
31430	2334	51	1	8	8
31431	2334	130	1	12	12
31442	2653	1	1	2	2
31443	2653	4	5	3	15
31444	2653	119	1	31	31
31445	2653	51	1	8	8
31462	2655	1	1	2	2
31463	2655	149	1	13	13
31464	2655	51	2	8	16
31465	2655	61	1	8	8
31466	2655	105	1	13	13
31467	2655	101	3	3	9
31468	2655	318	1	12	12
31469	448	1	1	2	2
31470	448	30	1	8	8
31471	448	318	1	12	12
31472	448	31	1	9	9
31474	1556	1	1	2	2
31475	1556	4	1	3	3
31476	1556	149	2	13	26
31477	1556	105	1	13	13
31478	1556	58	1	13	13
31489	2656	1	1	2	2
31490	2656	73	1	8	8
31491	2656	66	1	8	8
31492	2656	334	2	8	16
31493	2656	55	1	8	8
31494	2656	44	1	8	8
31559	1007	103	3	31	93
31560	1007	119	1	31	31
31277	2645	3	3	3	9
31278	2645	31	2	9	18
31279	2645	1	1	2	2
31285	2647	245	1	9	9
31286	2647	55	1	8	8
31287	2647	71	1	8	8
31318	2649	99	1	12	12
31319	2649	75	1	12	12
31320	2649	148	1	17	17
31321	2649	56	1	12	12
31322	2649	51	1	8	8
31323	2649	2	1	2	2
31343	2650	1	1	2	2
31344	2650	148	1	17	17
31345	2650	4	1	3	3
31346	2650	51	1	8	8
31347	2650	52	1	8	8
31348	2650	192	1	30	30
31357	2651	61	2	8	16
31358	2651	1	1	2	2
31359	2651	4	3	3	9
31360	2651	52	1	8	8
31361	2651	73	1	8	8
31362	2651	31	1	9	9
31363	2651	192	1	30	30
31364	2651	270	1	30	30
31373	1844	295	2	85	170
31438	2652	1	1	2	2
31439	2652	4	15	3	45
31440	2652	56	1	12	12
31441	2652	193	1	22	22
31453	981	1	1	2	2
31454	981	4	3	3	9
31455	981	52	1	8	8
31456	1628	334	1	8	8
31457	1628	31	1	9	9
31458	1628	52	2	8	16
31459	1628	110	1	9	9
31460	2623	1	1	2	2
31461	2623	3	4	3	12
31479	2638	1	1	2	2
31480	2638	3	2	3	6
31481	2638	148	2	17	34
31482	2638	105	1	13	13
31483	2636	151	1	17	17
31484	2636	1	1	2	2
31485	2636	4	2	3	6
31495	2657	1	1	2	2
31496	2657	4	2	3	6
31497	2658	1	1	2	2
31498	2658	4	1	3	3
31499	2658	56	1	12	12
31500	2658	149	1	13	13
31501	2658	109	1	14	14
31502	854	40	11	19	209
31514	2661	1	1	2	2
31515	2661	148	1	17	17
31516	2661	318	1	12	12
31517	2661	99	1	12	12
31518	2661	311	1	30	30
31519	2661	303	1	13	13
31561	2663	303	2	13	26
31562	2663	311	1	30	30
\.


--
-- Data for Name: tickets; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.tickets (id, account_num, total, created_at, status, session_id, payment_details, cash_session_id, captured_by_id, cashed_by_id) FROM stdin;
1	V4915	79	2026-03-13 19:42:50.789588	PAID	1	\N	\N	\N	\N
3	V3350	10	2026-03-13 19:53:38.117347	PAID	1	\N	\N	\N	\N
6	V1668	18	2026-03-13 20:17:11.11021	PAID	1	\N	\N	\N	\N
2242	V2881	58	2026-03-26 02:30:54.750448	PAID	5	[{"method": "EFECTIVO", "amount": 58, "received": 100, "cambio": 42, "displayAmount": 100, "type": null, "id": 1774492277715}]	35	18	3
11	V2616	52	2026-03-13 21:53:01.045587	PAID	1	[{"method": "EFECTIVO", "amount": 52, "received": 52, "cambio": 0, "displayAmount": 52, "type": null, "id": 1774580853935}]	70	13	1
27	V0027	117	2026-03-17 03:50:39.172886	PAID	5	[{"method": "EFECTIVO", "amount": 100, "displayAmount": 100, "type": null, "id": 1773720468151}, {"method": "TARJETA", "amount": 4, "displayAmount": 4, "type": "DEBITO", "id": 1773720473475}, {"method": "TARJETA", "amount": 13, "displayAmount": 13, "type": "CREDITO", "id": 1773720481305}]	2	2	1
10	V9407	58	2026-03-13 20:30:13.526537	PAID	2	[{"method": "EFECTIVO", "amount": 58, "received": 200, "cambio": 142, "displayAmount": 200, "type": null, "id": 1774406551574}]	30	8	3
4	V7870	2	2026-03-13 19:58:01.752503	PAID	1	\N	\N	\N	\N
22	TEST_FIX_3	2	2026-03-17 01:00:34.04513	PAID	1	null	\N	1	\N
23	TEST_FIX_4	2	2026-03-17 01:02:53.122971	PAID	1	null	\N	1	\N
24	TEST_FIX_5	2	2026-03-17 01:03:23.776803	PAID	1	null	\N	1	\N
21	TEST_FIX_2	2	2026-03-17 00:58:20.225764	PAID	1	null	\N	\N	1
25	TEST_FIX_6	2	2026-03-17 01:04:04.360963	PAID	1	null	\N	1	\N
15	V0015	28	2026-03-17 00:47:29.064586	PAID	2	[{"method": "EFECTIVO", "amount": 20, "displayAmount": 20, "type": null, "id": 1773709578298}, {"method": "TARJETA", "amount": 8, "displayAmount": 8, "type": "DEBITO", "id": 1773709583826}]	1	\N	1
9	V5981	39	2026-03-13 20:26:54.334624	PAID	1	[{"method": "EFECTIVO", "amount": 39, "displayAmount": 39, "type": null, "id": 1773709649770}]	1	\N	1
8	V5641	7	2026-03-13 20:17:59.58531	PAID	3	[{"method": "TARJETA", "amount": 7, "displayAmount": 7, "type": "DEBITO", "id": 1773709665827}]	1	\N	1
19	V0019	54	2026-03-17 00:48:44.359289	PAID	5	[{"method": "TARJETA", "amount": 54, "displayAmount": 54, "type": "CREDITO", "id": 1773709677882}]	1	\N	1
12	V6300	159	2026-03-13 21:53:16.362769	PAID	1	[{"method": "TARJETA", "amount": 159, "displayAmount": 159, "type": "CREDITO", "id": 1773709694682}]	1	\N	1
18	V0018	39	2026-03-17 00:48:37.494045	PAID	4	[{"method": "EFECTIVO", "amount": 39, "displayAmount": 39, "type": null, "id": 1773717962610}]	2	\N	1
14	V1368	21	2026-03-13 23:22:51.714938	PAID	1	[{"method": "EFECTIVO", "amount": 20, "displayAmount": 20, "type": null, "id": 1773718567098}, {"method": "TARJETA", "amount": 1, "displayAmount": 1, "type": "CREDITO", "id": 1773718574770}]	2	\N	1
13	V5200	286	2026-03-13 22:01:31.933493	PAID	1	[{"method": "EFECTIVO", "amount": 100, "displayAmount": 100, "type": null, "id": 1773718651251}, {"method": "TARJETA", "amount": 18, "displayAmount": 18, "type": "CREDITO", "id": 1773718670903}, {"method": "TARJETA", "amount": 168, "displayAmount": 168, "type": "DEBITO", "id": 1773718686403}]	2	\N	1
17	V0017	128	2026-03-17 00:48:15.528776	PAID	1	[{"method": "EFECTIVO", "amount": 10, "displayAmount": 10, "type": null, "id": 1773719250890}, {"method": "TARJETA", "amount": 48, "displayAmount": 48, "type": "DEBITO", "id": 1773719258078}, {"method": "TARJETA", "amount": 70, "displayAmount": 70, "type": "CREDITO", "id": 1773719268520}]	2	\N	1
16	V0016	80	2026-03-17 00:48:08.927209	PAID	1	[{"method": "EFECTIVO", "amount": 4, "displayAmount": 4, "type": null, "id": 1773719343366}, {"method": "TARJETA", "amount": 14, "displayAmount": 14, "type": "DEBITO", "id": 1773719348354}, {"method": "TARJETA", "amount": 62, "displayAmount": 62, "type": "CREDITO", "id": 1773719353504}]	2	\N	1
28	V0028	53	2026-03-17 04:07:37.504679	PAID	5	[{"method": "EFECTIVO", "amount": 53, "displayAmount": 53, "type": null, "id": 1773721164731}]	2	2	1
26	V0026	676	2026-03-17 03:50:25.831822	PAID	5	[{"method": "EFECTIVO", "amount": 500, "displayAmount": 500, "type": null, "id": 1773719478445}, {"method": "TARJETA", "amount": 170, "displayAmount": 170, "type": "DEBITO", "id": 1773719484808}, {"method": "TARJETA", "amount": 6, "displayAmount": 6, "type": "DEBITO", "id": 1773719489259}]	2	\N	1
35	V0035	46	2026-03-17 04:25:20.302839	PAID	1	[{"method": "TARJETA", "amount": 46, "displayAmount": 46, "type": "DEBITO", "id": 1773875417439}]	11	2	2
29	V0029	3300	2026-03-17 04:11:25.051413	PAID	1	[{"method": "TARJETA", "amount": 3000, "displayAmount": 3000, "type": "DEBITO", "id": 1773720764770}, {"method": "TARJETA", "amount": 300, "displayAmount": 300, "type": "CREDITO", "id": 1773720769875}]	2	2	1
30	V0030	400	2026-03-17 04:12:11.408904	PAID	1	[{"method": "EFECTIVO", "amount": 300, "displayAmount": 300, "type": null, "id": 1773720999199}, {"method": "TARJETA", "amount": 100, "displayAmount": 100, "type": "DEBITO", "id": 1773721006124}]	2	1	1
31	V0031	1150	2026-03-17 04:16:11.587655	PAID	1	[{"method": "TARJETA", "amount": 1150, "displayAmount": 1150, "type": "DEBITO", "id": 1773721117271}]	2	2	1
34	V0034	48	2026-03-17 04:25:11.977735	PAID	1	[{"method": "EFECTIVO", "amount": 48, "displayAmount": 63, "type": null, "id": 1773890705211}]	15	2	1
39	V0039	0	2026-03-17 04:32:47.111733	OPEN	5	\N	\N	\N	\N
37	V0037	39	2026-03-17 04:25:42.814603	PAID	6	[{"method": "EFECTIVO", "amount": 39, "displayAmount": 39, "type": null, "id": 1773721722757}]	3	2	2
38	V0038	140	2026-03-17 04:26:05.622909	PAID	5	[{"method": "EFECTIVO", "amount": 100, "displayAmount": 100, "type": null, "id": 1773873193400}, {"method": "TARJETA", "amount": 40, "displayAmount": 40, "type": "DEBITO", "id": 1773873200176}]	7	1	1
40	V0040	0	2026-03-17 04:36:47.378859	OPEN	2	\N	\N	\N	\N
41	V0041	0	2026-03-17 21:30:53.808876	OPEN	3	\N	\N	\N	\N
42	V0042	0	2026-03-17 21:37:12.191274	OPEN	4	\N	\N	\N	\N
36	V0036	44	2026-03-17 04:25:33.839008	PAID	6	[{"method": "EFECTIVO", "amount": 44, "displayAmount": 44, "type": null, "id": 1773784203258}]	4	2	2
45	V0045	72	2026-03-17 21:48:06.944181	PAID	6	[{"method": "EFECTIVO", "amount": 72, "displayAmount": 72, "type": null, "id": 1773784701204}]	4	4	2
46	V0046	72	2026-03-17 21:57:01.287726	PAID	6	[{"method": "EFECTIVO", "amount": 72, "displayAmount": 72, "type": null, "id": 1773784918122}]	4	4	2
48	V0048	90	2026-03-17 22:07:42.00841	PAID	6	[{"method": "EFECTIVO", "amount": 90, "displayAmount": 90, "type": null, "id": 1773785519774}]	4	4	2
47	V0047	84	2026-03-17 22:01:20.580093	PAID	6	[{"method": "EFECTIVO", "amount": 84, "displayAmount": 84, "type": null, "id": 1773785280223}]	4	4	2
357	V5660	93	2026-03-21 01:17:53.899335	PAID	3	[{"method": "EFECTIVO", "amount": 93, "displayAmount": 100, "type": null, "id": 1774055892885, "received": 100, "cambio": 7}]	21	4	20
915	V9333	102	2026-03-22 03:18:20.037467	PAID	3	[{"method": "EFECTIVO", "amount": 102, "received": 200, "cambio": 98, "displayAmount": 200, "type": null, "id": 1774149517903}]	23	13	20
74	V1585	50	2026-03-18 01:28:36.042654	PAID	6	[{"method": "EFECTIVO", "amount": 50, "displayAmount": 50, "type": null, "id": 1773875388227}]	11	4	2
51	V0051	0	2026-03-17 22:22:54.523699	OPEN	6	\N	\N	\N	\N
52	V6812	300	2026-03-17 22:23:06.103577	PAID	6	[{"method": "EFECTIVO", "amount": 300, "displayAmount": 300, "type": null, "id": 1773786284472}]	4	4	2
71	V4457	77	2026-03-18 00:37:08.020434	PAID	6	[{"method": "EFECTIVO", "amount": 77, "received": 100, "cambio": 23, "displayAmount": 100, "type": null, "id": 1774318856109}]	28	9	20
79	V9541	19	2026-03-18 02:09:19.512042	PAID	1	[{"method": "EFECTIVO", "amount": 19, "displayAmount": 100, "type": null, "id": 1774393036138, "received": 100, "cambio": 81}]	29	13	20
33	V0033	50	2026-03-17 04:19:11.63981	PAID	5	[{"method": "EFECTIVO", "amount": 25, "displayAmount": 25, "type": null, "id": 1773786819839}, {"method": "TARJETA", "amount": 10, "displayAmount": 10, "type": "DEBITO", "id": 1773786825445}, {"method": "TARJETA", "amount": 15, "displayAmount": 15, "type": "CREDITO", "id": 1773786833787}]	4	2	2
49	V0049	77	2026-03-17 22:11:43.582557	PAID	6	[{"method": "EFECTIVO", "amount": 77, "displayAmount": 77, "type": null, "id": 1773787050327}]	5	4	2
2160	V9979	34	2026-03-26 01:05:53.096322	PAID	3	[{"method": "EFECTIVO", "amount": 34, "received": 34, "cambio": 0, "displayAmount": 34, "type": null, "id": 1774492355182}]	35	18	3
61	V0061	0	2026-03-17 23:01:46.029818	OPEN	1	\N	\N	\N	\N
62	V9569	405	2026-03-17 23:23:05.732006	PAID	6	[{"method": "EFECTIVO", "amount": 405, "displayAmount": 405, "type": null, "id": 1773789817385}]	6	4	2
63	V4422	180	2026-03-17 23:26:58.222177	PAID	6	[{"method": "EFECTIVO", "amount": 180, "displayAmount": 180, "type": null, "id": 1773790055171}]	6	2	2
64	V1840	120	2026-03-17 23:33:51.044118	PAID	6	[{"method": "EFECTIVO", "amount": 120, "displayAmount": 120, "type": null, "id": 1773790592527}]	6	2	2
20	V0020	61	2026-03-17 00:49:11.85314	PAID	2	[{"method": "EFECTIVO", "amount": 40, "displayAmount": 40, "type": null, "id": 1773790783917}, {"method": "TARJETA", "amount": 15, "displayAmount": 15, "type": "DEBITO", "id": 1773790789624}, {"method": "TARJETA", "amount": 6, "displayAmount": 6, "type": "CREDITO", "id": 1773790796949}]	6	2	2
66	V9316	65	2026-03-17 23:45:29.456563	PAID	6	[{"method": "EFECTIVO", "amount": 65, "displayAmount": 200, "type": null, "id": 1774054722842, "received": 200, "cambio": 135}]	21	4	20
68	V8464	36	2026-03-18 00:08:19.261317	PAID	6	[{"method": "EFECTIVO", "amount": 36, "displayAmount": 36, "type": null, "id": 1773792550016}]	6	4	2
69	V2276	65	2026-03-18 00:17:16.869313	PAID	6	[{"method": "EFECTIVO", "amount": 65, "displayAmount": 65, "type": null, "id": 1773793077650}]	6	4	2
70	V3746	30	2026-03-18 00:26:27.775105	PAID	6	[{"method": "EFECTIVO", "amount": 30, "displayAmount": 30, "type": null, "id": 1773793659381}]	6	4	2
75	V2712	50	2026-03-18 01:30:46.186969	PAID	6	[{"method": "EFECTIVO", "amount": 50, "displayAmount": 50, "type": null, "id": 1773797559006}]	6	4	2
76	V1287	8	2026-03-18 01:44:38.755099	PAID	6	[{"method": "EFECTIVO", "amount": 2, "displayAmount": 2, "type": null, "id": 1773798331677}, {"method": "TARJETA", "amount": 4, "displayAmount": 4, "type": "DEBITO", "id": 1773798334829}, {"method": "TARJETA", "amount": 2, "displayAmount": 2, "type": "CREDITO", "id": 1773798339653}]	6	8	2
77	V2581	89	2026-03-18 01:47:28.484798	PAID	6	[{"method": "EFECTIVO", "amount": 15, "displayAmount": 15, "type": null, "id": 1773798476888}, {"method": "TARJETA", "amount": 40, "displayAmount": 40, "type": "DEBITO", "id": 1773798482813}, {"method": "TARJETA", "amount": 34, "displayAmount": 34, "type": "CREDITO", "id": 1773798488087}]	6	8	2
78	V1515	163	2026-03-18 02:03:36.472525	PAID	1	[{"method": "EFECTIVO", "amount": 163, "displayAmount": 163, "type": null, "id": 1773799632795}]	6	9	2
53	V5701	144	2026-03-17 22:23:45.90924	PAID	6	[{"method": "EFECTIVO", "amount": 100, "displayAmount": 100, "type": null, "id": 1773873216576}, {"method": "TARJETA", "amount": 14, "displayAmount": 14, "type": "DEBITO", "id": 1773873221609}, {"method": "TARJETA", "amount": 30, "displayAmount": 30, "type": "CREDITO", "id": 1773873226743}]	7	4	1
44	V0044	88	2026-03-17 21:47:56.938934	PAID	6	[{"method": "EFECTIVO", "amount": 50, "displayAmount": 50, "type": null, "id": 1773873240247}, {"method": "TARJETA", "amount": 38, "displayAmount": 38, "type": "DEBITO", "id": 1773873252815}]	7	4	1
56	V5793	35	2026-03-17 22:31:19.150636	PAID	6	[{"method": "TARJETA", "amount": 35, "displayAmount": 35, "type": "DEBITO", "id": 1773873555752}]	8	4	1
57	V2929	600	2026-03-17 22:31:46.379689	PAID	6	[{"method": "TARJETA", "amount": 600, "displayAmount": 600, "type": "CREDITO", "id": 1773873568768}]	8	4	1
54	V7939	1232	2026-03-17 22:31:09.125972	PAID	6	[{"method": "TARJETA", "amount": 1232, "displayAmount": 120032, "type": "DEBITO", "id": 1773873778248}]	9	4	1
65	V9305	120	2026-03-17 23:43:59.632843	PAID	6	[{"method": "EFECTIVO", "amount": 120, "displayAmount": 120, "type": null, "id": 1773873793576}]	9	4	1
67	V2537	70	2026-03-18 00:08:09.680337	PAID	6	[{"method": "EFECTIVO", "amount": 70, "displayAmount": 70, "type": null, "id": 1773873876120}]	10	4	1
73	V8758	34	2026-03-18 01:28:28.455777	PAID	6	[{"method": "TARJETA", "amount": 34, "displayAmount": 34, "type": "DEBITO", "id": 1773873887536}]	10	4	1
50	V0050	48	2026-03-17 22:17:14.639416	PAID	6	[{"method": "EFECTIVO", "amount": 40, "displayAmount": 40, "type": null, "id": 1773875367875}, {"method": "TARJETA", "amount": 8, "displayAmount": 8, "type": "DEBITO", "id": 1773875372003}]	11	4	2
32	V0032	43	2026-03-17 04:17:47.754466	PAID	1	[{"method": "TARJETA", "amount": 43, "displayAmount": 43, "type": "CREDITO", "id": 1773875400906}]	11	2	2
58	V7300	84	2026-03-17 22:32:26.39953	PAID	6	[{"method": "EFECTIVO", "amount": 84, "displayAmount": 84, "type": null, "id": 1773876228358}]	12	8	2
43	V0043	43	2026-03-17 21:40:40.317432	PAID	1	[{"method": "TARJETA", "amount": 43, "displayAmount": 43, "type": "CREDITO", "id": 1773876250704}]	12	2	2
59	V7562	42	2026-03-17 22:32:29.835431	PAID	6	[{"method": "TARJETA", "amount": 42, "displayAmount": 42, "type": "DEBITO", "id": 1773876240110}]	12	8	2
88	V9068	25	2026-03-19 00:20:55.140686	PAID	6	[{"method": "EFECTIVO", "amount": 25, "displayAmount": 25, "type": null, "id": 1773879721143}]	13	4	2
85	V6467	53	2026-03-18 23:55:37.983047	PAID	6	[{"method": "EFECTIVO", "amount": 53, "displayAmount": 53, "type": null, "id": 1773879794665}]	14	4	2
81	V5349	24	2026-03-18 23:42:26.118125	PAID	1	[{"method": "EFECTIVO", "amount": 24, "displayAmount": 24, "type": null, "id": 1773889484439}]	15	8	1
80	V5666	20	2026-03-18 23:42:21.925272	PAID	1	[{"method": "EFECTIVO", "amount": 10, "displayAmount": 10, "type": null, "id": 1773889565354}, {"method": "TARJETA", "amount": 10, "displayAmount": 10, "type": "CREDITO", "id": 1773889579193}]	15	8	1
90	V8792	39	2026-03-19 03:27:36.739624	PAID	1	[{"method": "EFECTIVO", "amount": 39, "displayAmount": 500, "type": null, "id": 1773890801628}]	15	1	\N
91	V2092	31	2026-03-19 03:28:24.185591	PAID	1	[{"method": "EFECTIVO", "amount": 31, "displayAmount": 50, "type": null, "id": 1773890877179}]	15	1	\N
92	V1739	40	2026-03-19 03:29:33.366351	PAID	1	[{"method": "EFECTIVO", "amount": 28, "displayAmount": 28, "type": null, "id": 1773890951835}, {"method": "TARJETA", "amount": 12, "displayAmount": 12, "type": "DEBITO", "id": 1773890961324}]	15	1	\N
82	V4016	68	2026-03-18 23:43:29.71945	PAID	6	[{"method": "EFECTIVO", "amount": 68, "displayAmount": 500, "type": null, "id": 1773924829323, "received": 500, "cambio": 432}]	16	4	3
83	V1526	37	2026-03-18 23:49:06.138695	PAID	6	[{"method": "TARJETA", "amount": 10, "displayAmount": 10, "type": "DEBITO", "id": 1773924857422}, {"method": "EFECTIVO", "amount": 27, "received": 27, "cambio": 0, "displayAmount": 27, "type": null, "id": 1773924863504}]	16	4	3
87	V3734	68	2026-03-19 00:05:47.567019	PAID	6	[{"method": "EFECTIVO", "amount": 60, "displayAmount": 500, "type": null, "id": 1773924880539, "received": 500, "cambio": 440}, {"method": "TARJETA", "amount": 8, "received": 8, "cambio": 0, "displayAmount": 8, "type": "DEBITO", "id": 1773924915076}]	16	4	3
95	V6933	30	2026-03-19 13:13:21.774452	PAID	5	[{"method": "EFECTIVO", "amount": 30, "displayAmount": 50, "type": null, "id": 1774537141203, "received": 50, "cambio": 20}]	69	14	20
84	V6507	64	2026-03-18 23:49:08.749299	PAID	6	[{"method": "EFECTIVO", "amount": 64, "displayAmount": 452, "type": null, "id": 1773924968153, "received": 452, "cambio": 388}]	16	4	3
93	V7499	36	2026-03-19 04:22:07.925062	PAID	1	[{"method": "EFECTIVO", "amount": 36, "received": 36, "cambio": 0, "displayAmount": 36, "type": null, "id": 1774581400710}]	70	4	1
96	V9892	26	2026-03-19 13:15:55.920806	PAID	5	[{"method": "EFECTIVO", "amount": 26, "received": 26, "cambio": 0, "displayAmount": 26, "type": null, "id": 1774310475899}]	28	4	20
94	V8664	23	2026-03-19 13:11:25.491077	PAID	3	[{"method": "EFECTIVO", "amount": 23, "displayAmount": 100, "type": null, "id": 1774450357267, "received": 100, "cambio": 77}]	31	16	20
98	V7616	57	2026-03-19 13:19:00.798689	PAID	4	[{"method": "EFECTIVO", "amount": 57, "received": 100, "cambio": 43, "displayAmount": 100, "type": null, "id": 1773926376329}]	17	8	3
99	V5362	58	2026-03-19 13:21:39.956371	PAID	4	[{"method": "TARJETA", "amount": 58, "received": 58, "cambio": 0, "displayAmount": 58, "type": "DEBITO", "id": 1773926532810}]	17	8	3
100	V6223	199	2026-03-19 13:23:16.574788	PAID	5	[{"method": "EFECTIVO", "amount": 199, "received": 200, "cambio": 1, "displayAmount": 200, "type": null, "id": 1773926608892}]	17	14	3
101	V9611	34	2026-03-19 13:24:16.089283	PAID	5	[{"method": "EFECTIVO", "amount": 34, "received": 100, "cambio": 66, "displayAmount": 100, "type": null, "id": 1773926681460}]	17	14	3
103	V4740	99	2026-03-19 13:25:06.362765	PAID	4	[{"method": "EFECTIVO", "amount": 99, "received": 100, "cambio": 1, "displayAmount": 100, "type": null, "id": 1773926726579}]	17	8	3
104	V4936	54	2026-03-19 13:28:34.282865	PAID	5	[{"method": "EFECTIVO", "amount": 54, "received": 200, "cambio": 146, "displayAmount": 200, "type": null, "id": 1773926943204}]	17	14	3
105	V1369	38	2026-03-19 13:29:02.38163	PAID	4	[{"method": "EFECTIVO", "amount": 38, "received": 50, "cambio": 12, "displayAmount": 50, "type": null, "id": 1773926973785}]	17	8	3
106	V6452	16	2026-03-19 13:29:28.700457	PAID	5	[{"method": "EFECTIVO", "amount": 16, "received": 16, "cambio": 0, "displayAmount": 16, "type": null, "id": 1773927011090}]	17	14	3
107	V7412	28	2026-03-19 13:30:35.593983	PAID	5	[{"method": "EFECTIVO", "amount": 28, "received": 28, "cambio": 0, "displayAmount": 28, "type": null, "id": 1774487314367}]	35	18	3
108	V5374	39	2026-03-19 13:31:40.480705	PAID	5	[{"method": "EFECTIVO", "amount": 39, "received": 50, "cambio": 11, "displayAmount": 50, "type": null, "id": 1773927126956}]	17	14	3
109	V4308	66	2026-03-19 13:32:29.893278	PAID	4	[{"method": "EFECTIVO", "amount": 66, "received": 500, "cambio": 434, "displayAmount": 500, "type": null, "id": 1773927174871}]	17	8	3
919	V2431	18	2026-03-22 03:28:28.165515	PAID	3	[{"method": "EFECTIVO", "amount": 18, "received": 5465, "cambio": 5447, "displayAmount": 5465, "type": null, "id": 1774150129048}]	23	13	20
112	V3797	11	2026-03-19 13:34:47.942333	PAID	5	[{"method": "EFECTIVO", "amount": 11, "received": 11, "cambio": 0, "displayAmount": 11, "type": null, "id": 1773927326790}]	17	14	3
1144	V7383	32	2026-03-22 22:56:09.735983	PAID	3	[{"method": "EFECTIVO", "amount": 32, "received": 32, "cambio": 0, "displayAmount": 32, "type": null, "id": 1774220217837}]	27	28	3
110	V9207	101	2026-03-19 13:32:52.140516	PAID	5	[{"method": "EFECTIVO", "amount": 101, "received": 501, "cambio": 400, "displayAmount": 501, "type": null, "id": 1774314070673}]	28	9	20
111	V5889	52	2026-03-19 13:33:40.744488	PAID	5	[{"method": "EFECTIVO", "amount": 52, "received": 52, "cambio": 0, "displayAmount": 52, "type": null, "id": 1774231129486}]	27	29	3
97	V8628	26	2026-03-19 13:16:53.275268	PAID	4	[{"method": "EFECTIVO", "amount": 26, "received": 26, "cambio": 0, "displayAmount": 26, "type": null, "id": 1773927387577}]	17	8	3
115	V8458	98	2026-03-19 13:36:27.606837	PAID	5	[{"method": "EFECTIVO", "amount": 98, "received": 98, "cambio": 0, "displayAmount": 98, "type": null, "id": 1774199222928}]	27	23	3
114	V4800	17	2026-03-19 13:35:18.245797	PAID	4	[{"method": "EFECTIVO", "amount": 17, "received": 17, "cambio": 0, "displayAmount": 17, "type": null, "id": 1773928522987}]	17	8	3
89	V6309	90	2026-03-19 03:26:08.659526	PAID	1	[{"method": "EFECTIVO", "amount": 90, "received": 90, "cambio": 0, "displayAmount": 90, "type": null, "id": 1774489597233}]	35	18	3
359	V2842	32	2026-03-21 01:21:02.77696	PAID	3	[{"method": "EFECTIVO", "amount": 32, "displayAmount": 100, "type": null, "id": 1774535789329, "received": 100, "cambio": 68}]	69	15	20
360	V4675	105	2026-03-21 01:21:39.761565	PAID	4	[{"method": "EFECTIVO", "amount": 105, "received": 200, "cambio": 95, "displayAmount": 200, "type": null, "id": 1774056112791}]	21	18	20
361	V5211	83	2026-03-21 01:22:22.962493	PAID	5	[{"method": "EFECTIVO", "amount": 83, "displayAmount": 100, "type": null, "id": 1774056185126, "received": 100, "cambio": 17}]	21	21	20
118	V6209	52	2026-03-19 13:39:01.6626	PAID	5	[{"method": "EFECTIVO", "amount": 52, "displayAmount": 52, "type": null, "id": 1774557665054, "received": 52, "cambio": 0}]	69	20	20
553	V3777	85	2026-03-21 14:13:04.165137	PAID	4	[{"method": "EFECTIVO", "amount": 85, "displayAmount": 200, "type": null, "id": 1774102404867, "received": 200, "cambio": 115}]	23	9	20
358	V4607	84	2026-03-21 01:18:41.49423	PAID	4	[{"method": "EFECTIVO", "amount": 84, "displayAmount": 500, "type": null, "id": 1774059360843, "received": 500, "cambio": 416}]	21	18	20
451	V8839	64	2026-03-21 02:46:08.280135	PAID	5	[{"method": "EFECTIVO", "amount": 64, "displayAmount": 100, "type": null, "id": 1774061197866, "received": 100, "cambio": 36}]	21	18	20
453	V6481	141	2026-03-21 02:48:11.485622	PAID	4	[{"method": "TARJETA", "amount": 141, "displayAmount": 141, "type": "DEBITO", "id": 1774061337388}]	21	8	20
457	V6350	68	2026-03-21 02:53:19.346813	PAID	5	[{"method": "EFECTIVO", "amount": 68, "displayAmount": 100, "type": null, "id": 1774061619036, "received": 100, "cambio": 32}]	21	18	20
459	V7749	101	2026-03-21 02:55:45.224177	PAID	6	[{"method": "EFECTIVO", "amount": 101, "displayAmount": 101, "type": null, "id": 1774061800210, "received": 101, "cambio": 0}]	21	4	20
460	V6382	20	2026-03-21 02:57:18.080596	PAID	5	[{"method": "EFECTIVO", "amount": 20, "received": 20, "cambio": 0, "displayAmount": 20, "type": null, "id": 1774307985797}]	28	4	20
463	V3918	45	2026-03-21 02:59:36.627486	PAID	5	[{"method": "EFECTIVO", "amount": 45, "displayAmount": 100, "type": null, "id": 1774062039256, "received": 100, "cambio": 55}]	21	18	20
465	V1969	25	2026-03-21 03:04:59.190934	PAID	5	[{"method": "EFECTIVO", "amount": 25, "displayAmount": 25, "type": null, "id": 1774062343161, "received": 25, "cambio": 0}]	21	18	20
466	V5767	41	2026-03-21 03:05:02.15251	PAID	3	[{"method": "EFECTIVO", "amount": 41, "received": 100, "cambio": 59, "displayAmount": 100, "type": null, "id": 1774576328277}]	70	9	1
468	V3423	64	2026-03-21 03:07:04.353998	PAID	5	[{"method": "EFECTIVO", "amount": 64, "displayAmount": 200, "type": null, "id": 1774062473304, "received": 200, "cambio": 136}]	21	18	20
469	V8735	18	2026-03-21 03:08:00.34573	PAID	4	[{"method": "EFECTIVO", "amount": 18, "displayAmount": 50, "type": null, "id": 1774130628028, "received": 50, "cambio": 32}]	23	27	20
471	V9973	51	2026-03-21 03:08:15.659433	PAID	3	[{"method": "EFECTIVO", "amount": 51, "displayAmount": 52, "type": null, "id": 1774062539288, "received": 52, "cambio": 1}]	21	4	20
476	V7311	44	2026-03-21 03:11:47.673949	PAID	4	[{"method": "EFECTIVO", "amount": 44, "displayAmount": 45, "type": null, "id": 1774062726743, "received": 45, "cambio": 1}]	21	21	20
467	V2974	67	2026-03-21 03:06:00.106015	PAID	3	[{"method": "EFECTIVO", "amount": 67, "displayAmount": 67, "type": null, "id": 1774099027595, "received": 67, "cambio": 0}]	23	4	20
541	V2394	34	2026-03-21 14:04:09.118662	PAID	5	[{"method": "EFECTIVO", "amount": 34, "displayAmount": 34, "type": null, "id": 1774101895842, "received": 34, "cambio": 0}]	23	10	20
547	V2409	39	2026-03-21 14:07:57.136474	PAID	3	[{"method": "EFECTIVO", "amount": 39, "displayAmount": 39, "type": null, "id": 1774102119307, "received": 39, "cambio": 0}]	23	22	20
546	V5070	162	2026-03-21 14:07:25.718339	PAID	5	[{"method": "EFECTIVO", "amount": 162, "received": 500, "cambio": 338, "displayAmount": 500, "type": null, "id": 1774236224739}]	27	28	3
548	V5058	80	2026-03-21 14:09:22.816185	PAID	5	[{"method": "EFECTIVO", "amount": 80, "displayAmount": 100, "type": null, "id": 1774102170065, "received": 100, "cambio": 20}]	23	10	20
549	V1401	53	2026-03-21 14:09:51.721323	PAID	3	[{"method": "EFECTIVO", "amount": 53, "displayAmount": 200, "type": null, "id": 1774102206661, "received": 200, "cambio": 147}]	23	22	20
550	V2575	32	2026-03-21 14:10:52.189081	PAID	5	[{"method": "EFECTIVO", "amount": 32, "received": 32, "cambio": 0, "displayAmount": 32, "type": null, "id": 1774192601000}]	27	10	3
554	V1449	76	2026-03-21 14:13:13.934867	PAID	5	[{"method": "EFECTIVO", "amount": 76, "displayAmount": 500, "type": null, "id": 1774102436383, "received": 500, "cambio": 424}]	23	10	20
555	V6718	61	2026-03-21 14:13:30.642451	PAID	3	[{"method": "EFECTIVO", "amount": 61, "displayAmount": 70, "type": null, "id": 1774102469758, "received": 70, "cambio": 9}]	23	22	20
557	V6965	102	2026-03-21 14:16:40.843716	PAID	5	[{"method": "EFECTIVO", "amount": 102, "displayAmount": 500, "type": null, "id": 1774102624129, "received": 500, "cambio": 398}]	23	10	20
561	V4177	89	2026-03-21 14:20:23.646495	PAID	5	[{"method": "EFECTIVO", "amount": 89, "received": 89, "cambio": 0, "displayAmount": 89, "type": null, "id": 1774310754074}]	28	18	20
566	V7929	57	2026-03-21 14:24:22.23846	PAID	3	[{"method": "EFECTIVO", "amount": 57, "displayAmount": 100, "type": null, "id": 1774103084296, "received": 100, "cambio": 43}]	23	22	20
572	V9382	70	2026-03-21 14:31:22.150271	PAID	5	[{"method": "TARJETA", "amount": 70, "displayAmount": 70, "type": "DEBITO", "id": 1774103532721}]	23	9	20
573	V9828	37	2026-03-21 14:32:20.992215	PAID	4	[{"method": "EFECTIVO", "amount": 37, "displayAmount": 50, "type": null, "id": 1774103563003, "received": 50, "cambio": 13}]	23	10	20
574	V9679	116	2026-03-21 14:32:50.205173	PAID	3	[{"method": "EFECTIVO", "amount": 116, "received": 116, "cambio": 0, "displayAmount": 116, "type": null, "id": 1774224637742}]	27	28	3
585	V1208	15	2026-03-21 14:39:45.213445	PAID	6	[{"method": "EFECTIVO", "amount": 15, "displayAmount": 15, "type": null, "id": 1774104024923, "received": 15, "cambio": 0}]	23	22	20
569	V1660	74	2026-03-21 14:27:26.77095	PAID	5	[{"method": "EFECTIVO", "amount": 74, "received": 74, "cambio": 0, "displayAmount": 74, "type": null, "id": 1774150198434}]	23	13	20
113	V2877	84	2026-03-19 13:34:54.677096	PAID	4	[{"method": "EFECTIVO", "amount": 84, "displayAmount": 84, "type": null, "id": 1774533084021, "received": 84, "cambio": 0}]	69	14	20
116	V3960	20	2026-03-19 13:37:35.649588	PAID	5	[{"method": "EFECTIVO", "amount": 20, "displayAmount": 100, "type": null, "id": 1774107649108, "received": 100, "cambio": 80}]	23	10	20
117	V4374	62	2026-03-19 13:37:43.521151	PAID	4	[{"method": "EFECTIVO", "amount": 62, "received": 200, "cambio": 138, "displayAmount": 200, "type": null, "id": 1773927499761}]	17	8	3
119	V8093	14	2026-03-19 13:40:14.104288	PAID	5	[{"method": "EFECTIVO", "amount": 14, "received": 100, "cambio": 86, "displayAmount": 100, "type": null, "id": 1773927633287}]	17	14	3
120	V6304	40	2026-03-19 13:40:47.858793	PAID	5	[{"method": "EFECTIVO", "amount": 40, "received": 50, "cambio": 10, "displayAmount": 50, "type": null, "id": 1773927663175}]	17	14	3
121	V2985	26	2026-03-19 13:41:01.289584	PAID	5	[{"method": "EFECTIVO", "amount": 26, "received": 30, "cambio": 4, "displayAmount": 30, "type": null, "id": 1773927686564}]	17	14	3
122	V9500	48	2026-03-19 13:42:56.154581	PAID	5	[{"method": "EFECTIVO", "amount": 48, "received": 50, "cambio": 2, "displayAmount": 50, "type": null, "id": 1773927788951}]	17	14	3
123	V8612	94	2026-03-19 13:43:49.537125	PAID	4	[{"method": "EFECTIVO", "amount": 94, "received": 100, "cambio": 6, "displayAmount": 100, "type": null, "id": 1774309740120}]	28	18	20
124	V1218	225	2026-03-19 13:44:02.080081	PAID	5	[{"method": "EFECTIVO", "amount": 225, "displayAmount": 300, "type": null, "id": 1774619341184, "received": 300, "cambio": 75}]	71	17	20
125	V7416	10	2026-03-19 13:44:18.711096	PAID	5	[{"method": "EFECTIVO", "amount": 10, "received": 10, "cambio": 0, "displayAmount": 10, "type": null, "id": 1773928511908}]	17	14	3
128	V2181	31	2026-03-19 13:51:18.92869	PAID	4	[{"method": "EFECTIVO", "amount": 31, "received": 31, "cambio": 0, "displayAmount": 31, "type": null, "id": 1773928544559}]	17	8	3
129	V1986	71	2026-03-19 13:55:22.455238	PAID	3	[{"method": "EFECTIVO", "amount": 71, "received": 500, "cambio": 429, "displayAmount": 500, "type": null, "id": 1773928566758}]	17	8	3
131	V4201	94	2026-03-19 14:00:57.099679	PAID	4	[{"method": "EFECTIVO", "amount": 94, "received": 200, "cambio": 106, "displayAmount": 200, "type": null, "id": 1773928893126}]	17	14	3
132	V4202	33	2026-03-19 14:01:43.89728	PAID	4	[{"method": "EFECTIVO", "amount": 33, "received": 50, "cambio": 17, "displayAmount": 50, "type": null, "id": 1773928922339}]	17	14	3
134	V3744	26	2026-03-19 14:02:23.960339	PAID	3	[{"method": "EFECTIVO", "amount": 26, "received": 200, "cambio": 174, "displayAmount": 200, "type": null, "id": 1773928953085}]	17	8	3
362	V8441	53	2026-03-21 01:24:19.485639	PAID	3	[{"method": "EFECTIVO", "amount": 53, "displayAmount": 100, "type": null, "id": 1774056281449, "received": 100, "cambio": 47}]	21	21	20
133	V5095	14	2026-03-19 14:02:17.701823	PAID	4	[{"method": "EFECTIVO", "amount": 14, "received": 15, "cambio": 1, "displayAmount": 15, "type": null, "id": 1773928987568}]	17	14	3
136	V1910	81	2026-03-19 14:03:53.372562	PAID	4	[{"method": "EFECTIVO", "amount": 81, "received": 101, "cambio": 20, "displayAmount": 101, "type": null, "id": 1774312353785}]	28	9	20
2243	V3297	32	2026-03-26 02:31:34.301657	PAID	3	[{"method": "EFECTIVO", "amount": 32, "received": 200, "cambio": 168, "displayAmount": 200, "type": null, "id": 1774492308678}]	35	24	3
138	V6985	67	2026-03-19 14:06:54.530283	PAID	4	[{"method": "EFECTIVO", "amount": 67, "displayAmount": 100, "type": null, "id": 1773929268610, "received": 100, "cambio": 33}]	17	14	3
150	V7701	126	2026-03-19 14:34:43.939918	PAID	4	[{"method": "EFECTIVO", "amount": 126, "received": 126, "cambio": 0, "displayAmount": 126, "type": null, "id": 1774236448545}]	27	28	3
140	V6203	72	2026-03-19 14:19:59.106934	PAID	4	[{"method": "EFECTIVO", "amount": 72, "received": 100, "cambio": 28, "displayAmount": 100, "type": null, "id": 1773930031813}]	17	14	3
141	V6576	63	2026-03-19 14:21:31.71088	PAID	6	[{"method": "EFECTIVO", "amount": 63, "received": 200, "cambio": 137, "displayAmount": 200, "type": null, "id": 1773930110386}]	17	16	3
144	V2428	29	2026-03-19 14:29:26.203655	PAID	3	[{"method": "TARJETA", "amount": 29, "received": 29, "cambio": 0, "displayAmount": 29, "type": "DEBITO", "id": 1773930599465}]	17	8	3
154	V6726	128	2026-03-19 14:36:12.821152	PAID	4	[{"method": "EFECTIVO", "amount": 128, "received": 130, "cambio": 2, "displayAmount": 130, "type": null, "id": 1774400025437}]	30	8	3
130	V2541	41	2026-03-19 13:57:19.012206	PAID	3	[{"method": "EFECTIVO", "amount": 41, "received": 41, "cambio": 0, "displayAmount": 41, "type": null, "id": 1773930679162}]	17	8	3
143	V7790	12	2026-03-19 14:28:52.709986	PAID	4	[{"method": "EFECTIVO", "amount": 12, "received": 12, "cambio": 0, "displayAmount": 12, "type": null, "id": 1773930697121}]	17	14	3
139	V8932	14	2026-03-19 14:17:56.202407	PAID	4	[{"method": "EFECTIVO", "amount": 14, "received": 14, "cambio": 0, "displayAmount": 14, "type": null, "id": 1773930714197}]	17	14	3
146	V6107	56	2026-03-19 14:32:06.453097	PAID	4	[{"method": "EFECTIVO", "amount": 56, "received": 200, "cambio": 144, "displayAmount": 200, "type": null, "id": 1773930748398}]	17	14	3
147	V9896	63	2026-03-19 14:32:44.184809	PAID	3	[{"method": "EFECTIVO", "amount": 63, "received": 100, "cambio": 37, "displayAmount": 100, "type": null, "id": 1773930803295}]	17	8	3
148	V3778	108	2026-03-19 14:33:36.77314	PAID	4	[{"method": "EFECTIVO", "amount": 108, "received": 200, "cambio": 92, "displayAmount": 200, "type": null, "id": 1773930835828}]	17	14	3
149	V6537	69	2026-03-19 14:34:10.772581	PAID	3	[{"method": "TARJETA", "amount": 69, "received": 69, "cambio": 0, "displayAmount": 69, "type": "DEBITO", "id": 1773930888095}]	17	8	3
153	V2759	67	2026-03-19 14:36:11.9322	PAID	3	[{"method": "EFECTIVO", "amount": 67, "received": 100, "cambio": 33, "displayAmount": 100, "type": null, "id": 1773930985536}]	17	8	3
158	V1160	84	2026-03-19 14:38:51.132194	PAID	4	[{"method": "EFECTIVO", "amount": 84, "received": 84, "cambio": 0, "displayAmount": 84, "type": null, "id": 1773931149375}]	17	14	3
142	V6706	17	2026-03-19 14:28:45.941808	PAID	3	[{"method": "EFECTIVO", "amount": 17, "received": 52, "cambio": 35, "displayAmount": 52, "type": null, "id": 1773931397689}]	17	8	3
137	V7663	30	2026-03-19 14:04:48.244702	PAID	4	[{"method": "EFECTIVO", "amount": 30, "received": 30, "cambio": 0, "displayAmount": 30, "type": null, "id": 1773931468344}]	17	14	3
159	V5448	30	2026-03-19 14:47:39.384968	PAID	6	[{"method": "EFECTIVO", "amount": 30, "received": 30, "cambio": 0, "displayAmount": 30, "type": null, "id": 1773931804774}]	17	16	3
151	V4868	49	2026-03-19 14:34:52.954072	PAID	6	[{"method": "EFECTIVO", "amount": 49, "received": 49, "cambio": 0, "displayAmount": 49, "type": null, "id": 1773931823181}]	17	16	3
135	V4392	29	2026-03-19 14:02:57.319974	PAID	3	[{"method": "EFECTIVO", "amount": 29, "received": 29, "cambio": 0, "displayAmount": 29, "type": null, "id": 1773931388824}]	17	8	3
155	V6262	17	2026-03-19 14:37:02.333284	PAID	3	[{"method": "EFECTIVO", "amount": 17, "received": 85, "cambio": 68, "displayAmount": 85, "type": null, "id": 1773931406908}]	17	8	3
156	V3638	24	2026-03-19 14:37:11.528543	PAID	6	[{"method": "EFECTIVO", "amount": 24, "received": 24, "cambio": 0, "displayAmount": 24, "type": null, "id": 1773931730483}]	17	16	3
157	V1030	17	2026-03-19 14:38:02.815678	PAID	6	[{"method": "EFECTIVO", "amount": 17, "received": 17, "cambio": 0, "displayAmount": 17, "type": null, "id": 1773931747347}]	17	16	3
160	V6811	53	2026-03-19 14:49:06.34249	PAID	3	[{"method": "EFECTIVO", "amount": 53, "received": 53, "cambio": 0, "displayAmount": 53, "type": null, "id": 1773931773493}]	17	8	3
152	V3819	47	2026-03-19 14:36:04.419565	PAID	6	[{"method": "EFECTIVO", "amount": 47, "received": 47, "cambio": 0, "displayAmount": 47, "type": null, "id": 1773931814187}]	17	16	3
363	V2972	77	2026-03-21 01:26:57.908274	PAID	5	[{"method": "EFECTIVO", "amount": 77, "displayAmount": 80, "type": null, "id": 1774056434117, "received": 80, "cambio": 3}]	21	18	20
163	V5658	73	2026-03-19 14:55:17.227232	PAID	6	[{"method": "EFECTIVO", "amount": 73, "received": 73, "cambio": 0, "displayAmount": 73, "type": null, "id": 1774317085236}]	28	18	20
364	V4006	61	2026-03-21 01:29:09.735904	PAID	5	[{"method": "EFECTIVO", "amount": 61, "received": 61, "cambio": 0, "displayAmount": 61, "type": null, "id": 1774473055166}]	34	24	1
370	V5757	54	2026-03-21 01:32:05.728068	PAID	5	[{"method": "EFECTIVO", "amount": 54, "displayAmount": 100, "type": null, "id": 1774056784151, "received": 100, "cambio": 46}]	21	18	20
480	V8515	75	2026-03-21 03:22:27.544422	PAID	3	[{"method": "EFECTIVO", "amount": 75, "displayAmount": 100, "type": null, "id": 1774063361008, "received": 100, "cambio": 25}]	21	4	20
372	V9427	34	2026-03-21 01:33:01.012694	PAID	4	[{"method": "EFECTIVO", "amount": 34, "displayAmount": 50, "type": null, "id": 1774056880582, "received": 50, "cambio": 16}]	21	21	20
373	V3236	54	2026-03-21 01:34:14.297642	PAID	3	[{"method": "EFECTIVO", "amount": 54, "displayAmount": 200, "type": null, "id": 1774056910996, "received": 200, "cambio": 146}]	21	4	20
374	V3930	56	2026-03-21 01:35:30.452717	PAID	5	[{"method": "EFECTIVO", "amount": 56, "received": 100, "cambio": 44, "displayAmount": 100, "type": null, "id": 1774056955983}]	21	18	20
376	V2287	49	2026-03-21 01:41:28.40518	PAID	3	[{"method": "EFECTIVO", "amount": 49, "displayAmount": 500, "type": null, "id": 1774452976175, "received": 500, "cambio": 451}]	31	20	20
384	V3501	16	2026-03-21 01:50:44.582787	PAID	5	[{"method": "EFECTIVO", "amount": 16, "displayAmount": 200, "type": null, "id": 1774101176348, "received": 200, "cambio": 184}]	23	9	20
386	V2454	42	2026-03-21 01:54:46.239065	PAID	6	[{"method": "EFECTIVO", "amount": 42, "displayAmount": 50, "type": null, "id": 1774058109121, "received": 50, "cambio": 8}]	21	9	20
392	V8295	385	2026-03-21 01:58:32.381561	PAID	3	[{"method": "EFECTIVO", "amount": 385, "displayAmount": 385, "type": null, "id": 1774058356159, "received": 385, "cambio": 0}]	21	4	20
393	V5648	121	2026-03-21 01:59:11.676208	PAID	4	[{"method": "EFECTIVO", "amount": 121, "received": 121, "cambio": 0, "displayAmount": 121, "type": null, "id": 1774058402136}]	21	18	20
396	V2937	115	2026-03-21 02:02:42.196553	PAID	5	[{"method": "EFECTIVO", "amount": 115, "displayAmount": 120, "type": null, "id": 1774058578496, "received": 120, "cambio": 5}]	21	18	20
399	V8898	86	2026-03-21 02:05:03.954828	PAID	5	[{"method": "EFECTIVO", "amount": 86, "displayAmount": 500, "type": null, "id": 1774058729245, "received": 500, "cambio": 414}]	21	18	20
400	V1492	53	2026-03-21 02:05:12.697812	PAID	4	[{"method": "EFECTIVO", "amount": 53, "displayAmount": 60, "type": null, "id": 1774058778395, "received": 60, "cambio": 7}]	21	4	20
401	V4108	43	2026-03-21 02:06:21.072404	PAID	4	[{"method": "EFECTIVO", "amount": 43, "displayAmount": 100, "type": null, "id": 1774058813842, "received": 100, "cambio": 57}]	21	4	20
403	V1338	45	2026-03-21 02:07:30.730063	PAID	4	[{"method": "EFECTIVO", "amount": 45, "displayAmount": 200, "type": null, "id": 1774058887520, "received": 200, "cambio": 155}]	21	4	20
404	V6555	44	2026-03-21 02:09:06.677322	PAID	6	[{"method": "EFECTIVO", "amount": 44, "displayAmount": 200, "type": null, "id": 1774058999483, "received": 200, "cambio": 156}]	21	9	20
369	V4388	48	2026-03-21 01:31:07.775397	PAID	4	[{"method": "EFECTIVO", "amount": 48, "displayAmount": 50, "type": null, "id": 1774060971497, "received": 50, "cambio": 2}]	21	18	20
474	V5990	47	2026-03-21 03:10:18.357413	PAID	3	[{"method": "EFECTIVO", "amount": 47, "displayAmount": 50, "type": null, "id": 1774062658025, "received": 50, "cambio": 3}]	21	4	20
475	V5960	143	2026-03-21 03:11:40.240728	PAID	5	[{"method": "EFECTIVO", "amount": 143, "received": 143, "cambio": 0, "displayAmount": 143, "type": null, "id": 1774308382428}]	28	4	20
477	V7823	160	2026-03-21 03:13:49.26693	PAID	5	[{"method": "EFECTIVO", "amount": 160, "displayAmount": 170, "type": null, "id": 1774062883759, "received": 170, "cambio": 10}]	21	18	20
481	V6705	83	2026-03-21 03:32:20.950011	PAID	6	[{"method": "EFECTIVO", "amount": 83, "received": 200, "cambio": 117, "displayAmount": 200, "type": null, "id": 1774193219739}]	27	10	3
482	V9377	173	2026-03-21 03:34:26.826655	PAID	6	[{"method": "EFECTIVO", "amount": 173, "displayAmount": 500, "type": null, "id": 1774064119936, "received": 500, "cambio": 327}]	21	18	20
568	V3812	118	2026-03-21 14:27:02.246387	PAID	3	[{"method": "EFECTIVO", "amount": 118, "displayAmount": 200, "type": null, "id": 1774103247188, "received": 200, "cambio": 82}]	23	22	20
575	V2535	44	2026-03-21 14:32:52.321158	PAID	4	[{"method": "EFECTIVO", "amount": 44, "displayAmount": 100, "type": null, "id": 1774103672480, "received": 100, "cambio": 56}]	23	10	20
587	V8206	73	2026-03-21 14:40:30.393799	PAID	3	[{"method": "EFECTIVO", "amount": 73, "displayAmount": 100, "type": null, "id": 1774104049322, "received": 100, "cambio": 27}]	23	23	20
406	V8613	26	2026-03-21 02:09:42.340609	PAID	4	[{"method": "EFECTIVO", "amount": 26, "received": 26, "cambio": 0, "displayAmount": 26, "type": null, "id": 1774304043248}]	28	18	20
126	V2456	83	2026-03-19 13:47:19.159464	PAID	4	[{"method": "EFECTIVO", "amount": 83, "displayAmount": 200, "type": null, "id": 1774135241155, "received": 200, "cambio": 117}]	23	27	20
377	V6198	14	2026-03-21 01:43:02.94535	PAID	2	[{"method": "EFECTIVO", "amount": 14, "displayAmount": 14, "type": null, "id": 1774467587146, "received": 14, "cambio": 0}]	31	16	20
164	V7453	38	2026-03-19 14:57:41.919416	PAID	3	[{"method": "EFECTIVO", "amount": 38, "received": 40, "cambio": 2, "displayAmount": 40, "type": null, "id": 1773932269497}]	17	8	3
161	V2618	75	2026-03-19 14:53:51.621853	PAID	6	[{"method": "EFECTIVO", "amount": 75, "received": 75, "cambio": 0, "displayAmount": 75, "type": null, "id": 1773932661139}]	17	16	3
162	V5838	29	2026-03-19 14:54:40.189583	PAID	3	[{"method": "EFECTIVO", "amount": 29, "received": 30, "cambio": 1, "displayAmount": 30, "type": null, "id": 1773932669584}]	17	8	3
165	V5662	69	2026-03-19 15:06:54.714249	PAID	3	[{"method": "EFECTIVO", "amount": 69, "received": 100, "cambio": 31, "displayAmount": 100, "type": null, "id": 1773932830325}]	17	16	3
167	V4662	64	2026-03-19 15:10:49.163775	PAID	5	[{"method": "EFECTIVO", "amount": 64, "displayAmount": 500, "type": null, "id": 1774280397658, "received": 500, "cambio": 436}]	28	20	20
168	V2895	112	2026-03-19 15:11:50.576909	PAID	3	[{"method": "EFECTIVO", "amount": 112, "displayAmount": 212, "type": null, "id": 1774130377526, "received": 212, "cambio": 100}]	23	20	20
169	V5880	126	2026-03-19 15:11:57.468564	PAID	5	[{"method": "EFECTIVO", "amount": 126, "received": 150, "cambio": 24, "displayAmount": 150, "type": null, "id": 1774575861966}]	70	4	1
176	V7216	32	2026-03-19 15:33:59.340632	PAID	3	[{"method": "EFECTIVO", "amount": 32, "displayAmount": 32, "type": null, "id": 1774447292441, "received": 32, "cambio": 0}]	31	16	20
190	V8808	43	2026-03-19 16:37:23.987665	PAID	1	[{"method": "EFECTIVO", "amount": 43, "received": 50, "cambio": 7, "displayAmount": 50, "type": null, "id": 1773952544985}]	17	1	3
166	V5864	37	2026-03-19 15:08:14.361694	PAID	3	[{"method": "EFECTIVO", "amount": 37, "received": 37, "cambio": 0, "displayAmount": 37, "type": null, "id": 1773952117055}]	17	16	3
170	V3613	50	2026-03-19 15:14:06.590068	PAID	3	[{"method": "EFECTIVO", "amount": 50, "received": 50, "cambio": 0, "displayAmount": 50, "type": null, "id": 1773952129841}]	17	16	3
171	V4832	38	2026-03-19 15:15:22.135047	PAID	3	[{"method": "EFECTIVO", "amount": 38, "received": 38, "cambio": 0, "displayAmount": 38, "type": null, "id": 1773952152057}]	17	16	3
191	V3724	48	2026-03-19 17:07:50.692011	PAID	3	[{"method": "EFECTIVO", "amount": 48, "received": 48, "cambio": 0, "displayAmount": 48, "type": null, "id": 1773952208631}]	17	16	3
173	V9218	32	2026-03-19 15:30:58.001482	PAID	3	[{"method": "EFECTIVO", "amount": 32, "received": 200, "cambio": 168, "displayAmount": 200, "type": null, "id": 1773963538076}]	18	8	2
174	V4485	130	2026-03-19 15:32:16.514871	PAID	3	[{"method": "EFECTIVO", "amount": 130, "received": 130, "cambio": 0, "displayAmount": 130, "type": null, "id": 1774483480219}]	35	18	3
175	V5122	28	2026-03-19 15:32:55.26503	PAID	3	[{"method": "EFECTIVO", "amount": 28, "received": 28, "cambio": 0, "displayAmount": 28, "type": null, "id": 1773952258083}]	17	16	3
177	V8272	92	2026-03-19 15:39:18.215809	PAID	3	[{"method": "EFECTIVO", "amount": 92, "displayAmount": 92, "type": null, "id": 1774129203654, "received": 92, "cambio": 0}]	23	24	20
178	V8568	16	2026-03-19 15:40:00.848605	PAID	3	[{"method": "EFECTIVO", "amount": 16, "received": 16, "cambio": 0, "displayAmount": 16, "type": null, "id": 1773952290012}]	17	16	3
179	V6696	27	2026-03-19 15:42:55.741056	PAID	3	[{"method": "EFECTIVO", "amount": 27, "received": 27, "cambio": 0, "displayAmount": 27, "type": null, "id": 1773952299471}]	17	16	3
180	V4263	17	2026-03-19 15:43:21.917466	PAID	3	[{"method": "EFECTIVO", "amount": 17, "received": 17, "cambio": 0, "displayAmount": 17, "type": null, "id": 1773952310822}]	17	16	3
181	V2293	69	2026-03-19 15:45:54.332328	PAID	3	[{"method": "EFECTIVO", "amount": 69, "received": 69, "cambio": 0, "displayAmount": 69, "type": null, "id": 1773952322995}]	17	16	3
182	V5275	59	2026-03-19 15:47:43.488306	PAID	3	[{"method": "EFECTIVO", "amount": 59, "received": 59, "cambio": 0, "displayAmount": 59, "type": null, "id": 1773952359583}]	17	16	3
183	V6147	30	2026-03-19 15:51:52.952377	PAID	3	[{"method": "EFECTIVO", "amount": 30, "received": 47, "cambio": 17, "displayAmount": 47, "type": null, "id": 1773952378076}]	17	16	3
184	V5651	14	2026-03-19 15:52:06.1799	PAID	3	[{"method": "EFECTIVO", "amount": 14, "received": 96, "cambio": 82, "displayAmount": 96, "type": null, "id": 1773952398174}]	17	16	3
187	V5279	38	2026-03-19 16:04:25.107713	PAID	3	[{"method": "EFECTIVO", "amount": 38, "received": 38, "cambio": 0, "displayAmount": 38, "type": null, "id": 1773952406714}]	17	16	3
185	V1383	13	2026-03-19 15:56:39.71688	PAID	3	[{"method": "EFECTIVO", "amount": 13, "received": 13, "cambio": 0, "displayAmount": 13, "type": null, "id": 1773952421077}]	17	16	3
186	V8344	82	2026-03-19 15:57:17.39643	PAID	3	[{"method": "EFECTIVO", "amount": 82, "displayAmount": 200, "type": null, "id": 1774532097101, "received": 200, "cambio": 118}]	69	14	20
188	V3892	55	2026-03-19 16:05:10.648845	PAID	3	[{"method": "EFECTIVO", "amount": 55, "received": 85, "cambio": 30, "displayAmount": 85, "type": null, "id": 1773952458732}]	17	16	3
189	V3855	20	2026-03-19 16:06:56.569494	PAID	3	[{"method": "EFECTIVO", "amount": 20, "received": 52, "cambio": 32, "displayAmount": 52, "type": null, "id": 1773952468891}]	17	16	3
192	V2838	56	2026-03-19 17:10:33.448036	PAID	3	[{"method": "EFECTIVO", "amount": 56, "displayAmount": 200, "type": null, "id": 1774101972112, "received": 200, "cambio": 144}]	23	10	20
196	V2026	64	2026-03-19 20:28:23.731277	PAID	3	[{"method": "EFECTIVO", "amount": 64, "received": 666, "cambio": 602, "displayAmount": 666, "type": null, "id": 1773952496243}]	17	4	3
197	V7521	26	2026-03-19 20:32:05.076984	PAID	3	[{"method": "EFECTIVO", "amount": 26, "received": 26, "cambio": 0, "displayAmount": 26, "type": null, "id": 1773952508140}]	17	4	3
193	V8496	53	2026-03-19 20:26:50.078873	PAID	5	[{"method": "EFECTIVO", "amount": 53, "received": 53, "cambio": 0, "displayAmount": 53, "type": null, "id": 1773952518415}]	17	9	3
194	V5881	32	2026-03-19 20:26:53.420167	PAID	4	[{"method": "EFECTIVO", "amount": 32, "received": 32, "cambio": 0, "displayAmount": 32, "type": null, "id": 1773952530220}]	17	10	3
195	V7224	95	2026-03-19 20:27:05.623117	PAID	6	[{"method": "EFECTIVO", "amount": 95, "received": 100, "cambio": 5, "displayAmount": 100, "type": null, "id": 1773952621228}]	17	8	3
366	V6477	45	2026-03-21 01:30:00.579437	PAID	4	[{"method": "EFECTIVO", "amount": 45, "received": 50, "cambio": 5, "displayAmount": 50, "type": null, "id": 1774491755864}]	35	9	3
198	V7795	45	2026-03-19 20:37:32.101031	PAID	6	[{"method": "EFECTIVO", "amount": 45, "received": 45, "cambio": 0, "displayAmount": 45, "type": null, "id": 1773954488264}]	18	8	2
200	V3659	77	2026-03-19 21:10:55.345264	PAID	2	[{"method": "EFECTIVO", "amount": 77, "received": 100, "cambio": 23, "displayAmount": 100, "type": null, "id": 1773954656734}]	18	2	\N
201	V6026	32	2026-03-19 21:11:04.915977	PAID	6	[{"method": "EFECTIVO", "amount": 32, "received": 100, "cambio": 68, "displayAmount": 100, "type": null, "id": 1773954692686}]	18	8	2
202	V5125	38	2026-03-19 21:14:36.813163	PAID	6	[{"method": "EFECTIVO", "amount": 38, "received": 50, "cambio": 12, "displayAmount": 50, "type": null, "id": 1773954905583}]	18	8	2
203	V3273	10	2026-03-19 21:19:50.639658	PAID	4	[{"method": "EFECTIVO", "amount": 10, "displayAmount": 10, "type": null, "id": 1773955208555, "received": 10, "cambio": 0}]	18	2	2
204	V3898	278	2026-03-19 21:34:13.516021	PAID	3	[{"method": "EFECTIVO", "amount": 278, "received": 300, "cambio": 22, "displayAmount": 300, "type": null, "id": 1773956082462}]	18	2	2
205	V3117	146	2026-03-19 21:35:10.741365	PAID	6	[{"method": "TARJETA", "amount": 146, "received": 146, "cambio": 0, "displayAmount": 146, "type": "DEBITO", "id": 1773956170684}]	18	8	2
206	V8096	135	2026-03-19 22:01:52.054799	PAID	3	[{"method": "EFECTIVO", "amount": 135, "received": 135, "cambio": 0, "displayAmount": 135, "type": null, "id": 1773957723454}]	18	2	2
207	V9977	77	2026-03-19 22:02:37.611914	PAID	3	[{"method": "EFECTIVO", "amount": 77, "received": 77, "cambio": 0, "displayAmount": 77, "type": null, "id": 1773957767814}]	18	2	2
209	V9119	47	2026-03-19 22:18:05.973382	PAID	1	[{"method": "EFECTIVO", "amount": 47, "received": 47, "cambio": 0, "displayAmount": 47, "type": null, "id": 1774389539300}]	29	9	20
208	V3498	32	2026-03-19 22:11:19.830906	PAID	4	[{"method": "EFECTIVO", "amount": 32, "received": 32, "cambio": 0, "displayAmount": 32, "type": null, "id": 1773958916414}]	18	18	2
211	V2568	68	2026-03-19 22:27:15.71102	PAID	1	[{"method": "EFECTIVO", "amount": 60, "displayAmount": 100, "type": null, "id": 1773959184723, "received": 100, "cambio": 40}, {"method": "TARJETA", "amount": 8, "displayAmount": 8, "type": "DEBITO", "id": 1773959232434}]	19	1	\N
212	V9255	37	2026-03-19 22:29:01.30032	PAID	4	[{"method": "EFECTIVO", "amount": 37, "received": 100, "cambio": 63, "displayAmount": 100, "type": null, "id": 1773959597076}]	18	18	2
214	V5113	100	2026-03-19 22:35:53.152986	PAID	3	[{"method": "EFECTIVO", "amount": 100, "received": 200, "cambio": 100, "displayAmount": 200, "type": null, "id": 1773959764733}]	18	2	2
213	V4086	32	2026-03-19 22:32:48.134012	PAID	3	[{"method": "EFECTIVO", "amount": 32, "received": 50, "cambio": 18, "displayAmount": 50, "type": null, "id": 1774194180692}]	27	21	3
210	V2212	19	2026-03-19 22:21:44.212996	PAID	3	[{"method": "EFECTIVO", "amount": 19, "received": 19, "cambio": 0, "displayAmount": 19, "type": null, "id": 1774300532048}]	28	4	20
215	V4648	235	2026-03-19 22:38:43.877791	PAID	6	[{"method": "EFECTIVO", "amount": 235, "received": 250, "cambio": 15, "displayAmount": 250, "type": null, "id": 1773959973817}]	18	8	2
216	V5288	106	2026-03-19 22:41:30.779063	PAID	5	[{"method": "EFECTIVO", "amount": 106, "displayAmount": 200, "type": null, "id": 1774622129497, "received": 200, "cambio": 94}]	71	15	20
916	V6258	91	2026-03-22 03:22:26.982362	PAID	5	[{"method": "EFECTIVO", "amount": 91, "received": 101, "cambio": 10, "displayAmount": 101, "type": null, "id": 1774149765832}]	23	27	20
218	V9260	48	2026-03-19 22:46:22.130659	PAID	4	[{"method": "EFECTIVO", "amount": 48, "received": 100, "cambio": 52, "displayAmount": 100, "type": null, "id": 1773960398233}]	18	2	2
219	V2382	118	2026-03-19 22:48:35.747834	PAID	5	[{"method": "EFECTIVO", "amount": 118, "received": 200, "cambio": 82, "displayAmount": 200, "type": null, "id": 1773960550685}]	18	18	2
220	V8865	68	2026-03-19 22:48:39.000632	PAID	4	[{"method": "EFECTIVO", "amount": 68, "received": 70, "cambio": 2, "displayAmount": 70, "type": null, "id": 1773960585454}]	18	2	2
221	V5398	14	2026-03-19 22:51:01.724618	PAID	3	[{"method": "EFECTIVO", "amount": 14, "received": 15, "cambio": 1, "displayAmount": 15, "type": null, "id": 1773960683253}]	18	18	2
222	V4831	91	2026-03-19 22:54:35.543306	PAID	3	[{"method": "EFECTIVO", "amount": 91, "received": 100, "cambio": 9, "displayAmount": 100, "type": null, "id": 1773960888690}]	18	2	2
223	V3530	103	2026-03-19 22:58:44.432993	PAID	5	[{"method": "EFECTIVO", "amount": 103, "received": 200, "cambio": 97, "displayAmount": 200, "type": null, "id": 1773961142209}]	18	8	2
224	V4420	38	2026-03-19 23:01:33.303937	PAID	5	[{"method": "EFECTIVO", "amount": 38, "received": 200, "cambio": 162, "displayAmount": 200, "type": null, "id": 1773961315566}]	18	8	2
225	V6743	50	2026-03-19 23:02:20.600942	PAID	6	[{"method": "EFECTIVO", "amount": 50, "received": 50, "cambio": 0, "displayAmount": 50, "type": null, "id": 1773961356243}]	18	18	2
60	V2436	41	2026-03-17 22:54:32.400252	PAID	6	[{"method": "TARJETA", "amount": 41, "received": 41, "cambio": 0, "displayAmount": 41, "type": "DEBITO", "id": 1773961439909}]	18	9	2
234	V6917	167	2026-03-19 23:29:17.500987	PAID	5	[{"method": "EFECTIVO", "amount": 167, "received": 200, "cambio": 33, "displayAmount": 200, "type": null, "id": 1774222532169}]	27	25	3
227	V1385	60	2026-03-19 23:05:14.623788	PAID	6	[{"method": "EFECTIVO", "amount": 60, "displayAmount": 100, "type": null, "id": 1774535506833, "received": 100, "cambio": 40}]	69	14	20
228	V8782	61	2026-03-19 23:07:02.943402	PAID	5	[{"method": "EFECTIVO", "amount": 61, "received": 200, "cambio": 139, "displayAmount": 200, "type": null, "id": 1773961637617}]	18	8	2
229	V9961	64	2026-03-19 23:12:12.027721	PAID	4	[{"method": "EFECTIVO", "amount": 64, "received": 70, "cambio": 6, "displayAmount": 70, "type": null, "id": 1773961944297}]	18	2	2
230	V6391	54	2026-03-19 23:14:28.869215	PAID	5	[{"method": "EFECTIVO", "amount": 54, "displayAmount": 200, "type": null, "id": 1774621523427, "received": 200, "cambio": 146}]	71	15	20
232	V4890	225	2026-03-19 23:25:21.176405	PAID	5	[{"method": "EFECTIVO", "amount": 225, "received": 400, "cambio": 175, "displayAmount": 400, "type": null, "id": 1773962746201}]	18	8	2
233	V4319	41	2026-03-19 23:26:34.683868	PAID	5	[{"method": "EFECTIVO", "amount": 41, "displayAmount": 45, "type": null, "id": 1774449003046, "received": 45, "cambio": 4}]	31	14	20
199	V6647	29	2026-03-19 21:05:25.938057	PAID	6	[{"method": "EFECTIVO", "amount": 29, "displayAmount": 50, "type": null, "id": 1774535230718, "received": 50, "cambio": 21}]	69	14	20
365	V5908	91	2026-03-21 01:29:25.693298	PAID	3	[{"method": "EFECTIVO", "amount": 91, "displayAmount": 201, "type": null, "id": 1774535701522, "received": 201, "cambio": 110}]	69	15	20
236	V1850	92	2026-03-19 23:33:48.109825	PAID	6	[{"method": "EFECTIVO", "amount": 92, "received": 92, "cambio": 0, "displayAmount": 92, "type": null, "id": 1773963306345}]	18	2	2
238	V6543	26	2026-03-19 23:39:23.910918	PAID	5	[{"method": "EFECTIVO", "amount": 26, "received": 26, "cambio": 0, "displayAmount": 26, "type": null, "id": 1774301067332}]	28	4	20
917	V7990	39	2026-03-22 03:23:34.50943	PAID	5	[{"method": "EFECTIVO", "amount": 39, "received": 39, "cambio": 0, "displayAmount": 39, "type": null, "id": 1774189021514}]	26	22	3
247	V5309	29	2026-03-19 23:50:11.616034	PAID	4	[{"method": "EFECTIVO", "amount": 29, "received": 29, "cambio": 0, "displayAmount": 29, "type": null, "id": 1774111471716}]	23	20	20
246	V4647	66	2026-03-19 23:50:01.239142	PAID	1	[{"method": "EFECTIVO", "amount": 66, "received": 100, "cambio": 34, "displayAmount": 100, "type": null, "id": 1774577769446}]	70	4	1
368	V4111	34	2026-03-21 01:31:04.493275	PAID	5	[{"method": "EFECTIVO", "amount": 34, "displayAmount": 34, "type": null, "id": 1774448269212, "received": 34, "cambio": 0}]	31	16	20
371	V7850	44	2026-03-21 01:32:26.732585	PAID	3	[{"method": "EFECTIVO", "amount": 44, "displayAmount": 44, "type": null, "id": 1774056856801, "received": 44, "cambio": 0}]	21	4	20
375	V1876	162	2026-03-21 01:37:09.026457	PAID	3	[{"method": "EFECTIVO", "amount": 162, "displayAmount": 500, "type": null, "id": 1774057049201, "received": 500, "cambio": 338}]	21	4	20
378	V7119	106	2026-03-21 01:43:44.91793	PAID	3	[{"method": "EFECTIVO", "amount": 106, "displayAmount": 500, "type": null, "id": 1774057453853, "received": 500, "cambio": 394}]	21	4	20
379	V4663	158	2026-03-21 01:44:54.109713	PAID	5	[{"method": "EFECTIVO", "amount": 158, "displayAmount": 158, "type": null, "id": 1774057524734, "received": 158, "cambio": 0}]	21	18	20
380	V2646	111	2026-03-21 01:48:35.766915	PAID	5	[{"method": "EFECTIVO", "amount": 111, "displayAmount": 500, "type": null, "id": 1774057736938, "received": 500, "cambio": 389}]	21	18	20
381	V1037	22	2026-03-21 01:49:01.294315	PAID	6	[{"method": "EFECTIVO", "amount": 22, "displayAmount": 22, "type": null, "id": 1774057781132, "received": 22, "cambio": 0}]	21	9	20
382	V8894	46	2026-03-21 01:50:03.322404	PAID	4	[{"method": "EFECTIVO", "amount": 46, "displayAmount": 50, "type": null, "id": 1774057833451, "received": 50, "cambio": 4}]	21	21	20
383	V4572	66	2026-03-21 01:50:32.1701	PAID	6	[{"method": "EFECTIVO", "amount": 66, "received": 100, "cambio": 34, "displayAmount": 100, "type": null, "id": 1774488915486}]	35	9	3
405	V1292	74	2026-03-21 02:09:10.35458	PAID	4	[{"method": "EFECTIVO", "amount": 74, "received": 74, "cambio": 0, "displayAmount": 74, "type": null, "id": 1774192912964}]	27	22	3
483	V9849	14	2026-03-21 12:59:56.736323	PAID	5	[{"method": "EFECTIVO", "amount": 14, "displayAmount": 14, "type": null, "id": 1774098031050, "received": 14, "cambio": 0}]	23	22	20
487	V8405	27	2026-03-21 13:03:49.83552	PAID	3	[{"method": "EFECTIVO", "amount": 27, "displayAmount": 40, "type": null, "id": 1774098244870, "received": 40, "cambio": 13}]	23	22	20
491	V8403	120	2026-03-21 13:07:37.293541	PAID	3	[{"method": "EFECTIVO", "amount": 120, "displayAmount": 200, "type": null, "id": 1774098475944, "received": 200, "cambio": 80}]	23	22	20
231	V2196	142	2026-03-19 23:17:34.617875	PAID	3	[{"method": "EFECTIVO", "amount": 142, "received": 200, "cambio": 58, "displayAmount": 200, "type": null, "id": 1774317792178}]	28	8	20
498	V2518	49	2026-03-21 13:25:18.737459	PAID	3	[{"method": "EFECTIVO", "amount": 49, "displayAmount": 50, "type": null, "id": 1774099535172, "received": 50, "cambio": 1}]	23	22	20
517	V1839	35	2026-03-21 13:40:07.980787	PAID	3	[{"method": "EFECTIVO", "amount": 35, "displayAmount": 50, "type": null, "id": 1774100416753, "received": 50, "cambio": 15}]	23	22	20
499	V6526	97	2026-03-21 13:25:35.829014	PAID	5	[{"method": "EFECTIVO", "amount": 97, "displayAmount": 100, "type": null, "id": 1774099584770, "received": 100, "cambio": 3}]	23	10	20
505	V4059	152	2026-03-21 13:30:32.261861	PAID	5	[{"method": "EFECTIVO", "amount": 152, "displayAmount": 200, "type": null, "id": 1774099869905, "received": 200, "cambio": 48}]	23	9	20
507	V9121	55	2026-03-21 13:31:55.059998	PAID	3	[{"method": "EFECTIVO", "amount": 55, "received": 55, "cambio": 0, "displayAmount": 55, "type": null, "id": 1774396813041}]	29	4	20
511	V9391	33	2026-03-21 13:36:36.735758	PAID	5	[{"method": "EFECTIVO", "amount": 33, "displayAmount": 35, "type": null, "id": 1774100211047, "received": 35, "cambio": 2}]	23	10	20
523	V1430	29	2026-03-21 13:45:54.780977	PAID	3	[{"method": "EFECTIVO", "amount": 29, "displayAmount": 50, "type": null, "id": 1774100807377, "received": 50, "cambio": 21}]	23	22	20
510	V3142	120	2026-03-21 13:36:05.963606	PAID	6	[{"method": "EFECTIVO", "amount": 120, "received": 120, "cambio": 0, "displayAmount": 120, "type": null, "id": 1774111919398}]	23	20	20
576	V8231	49	2026-03-21 14:33:50.279142	PAID	3	[{"method": "EFECTIVO", "amount": 49, "received": 200, "cambio": 151, "displayAmount": 200, "type": null, "id": 1774572515173}]	70	13	1
580	V7673	50	2026-03-21 14:37:41.683916	PAID	6	[{"method": "EFECTIVO", "amount": 50, "received": 200, "cambio": 150, "displayAmount": 200, "type": null, "id": 1774103872678}]	23	22	20
581	V2297	106	2026-03-21 14:37:59.025492	PAID	5	[{"method": "EFECTIVO", "amount": 106, "displayAmount": 106, "type": null, "id": 1774103896853, "received": 106, "cambio": 0}]	23	9	20
583	V8893	66	2026-03-21 14:38:36.638057	PAID	4	[{"method": "EFECTIVO", "amount": 66, "displayAmount": 100, "type": null, "id": 1774103939480, "received": 100, "cambio": 34}]	23	10	20
584	V9373	36	2026-03-21 14:39:13.245142	PAID	5	[{"method": "EFECTIVO", "amount": 36, "displayAmount": 200, "type": null, "id": 1774103979735, "received": 200, "cambio": 164}]	23	9	20
586	V3554	32	2026-03-21 14:40:23.910804	PAID	4	[{"method": "EFECTIVO", "amount": 32, "displayAmount": 32, "type": null, "id": 1774104076401, "received": 32, "cambio": 0}]	23	10	20
588	V7232	58	2026-03-21 14:41:35.536388	PAID	5	[{"method": "EFECTIVO", "amount": 58, "displayAmount": 100, "type": null, "id": 1774104107389, "received": 100, "cambio": 42}]	23	22	20
589	V1054	38	2026-03-21 14:41:48.490498	PAID	3	[{"method": "EFECTIVO", "amount": 38, "displayAmount": 500, "type": null, "id": 1774104132455, "received": 500, "cambio": 462}]	23	23	20
590	V2002	45	2026-03-21 14:42:32.774772	PAID	4	[{"method": "EFECTIVO", "amount": 45, "displayAmount": 45, "type": null, "id": 1774621635186, "received": 45, "cambio": 0}]	71	15	20
235	V9100	26	2026-03-19 23:33:38.027639	PAID	4	[{"method": "EFECTIVO", "amount": 26, "received": 26, "cambio": 0, "displayAmount": 26, "type": null, "id": 1774107570396}]	23	9	20
241	V6052	73	2026-03-19 23:41:20.704971	PAID	4	[{"method": "EFECTIVO", "amount": 73, "received": 200, "cambio": 127, "displayAmount": 200, "type": null, "id": 1773963696786}]	18	8	2
248	V1604	44	2026-03-19 23:50:14.597095	PAID	5	[{"method": "EFECTIVO", "amount": 44, "received": 50, "cambio": 6, "displayAmount": 50, "type": null, "id": 1773964305530}]	18	18	2
249	V3452	23	2026-03-19 23:51:13.897832	PAID	5	[{"method": "EFECTIVO", "amount": 23, "received": 23, "cambio": 0, "displayAmount": 23, "type": null, "id": 1773964339333}]	18	18	2
251	V9987	120	2026-03-19 23:56:11.885275	PAID	6	[{"method": "EFECTIVO", "amount": 120, "received": 500, "cambio": 380, "displayAmount": 500, "type": null, "id": 1773964590630}]	18	4	2
253	V2979	101	2026-03-19 23:58:43.509095	PAID	4	[{"method": "EFECTIVO", "amount": 101, "received": 500, "cambio": 399, "displayAmount": 500, "type": null, "id": 1773964747006}]	18	8	2
254	V9717	76	2026-03-19 23:59:10.436477	PAID	5	[{"method": "EFECTIVO", "amount": 76, "received": 100, "cambio": 24, "displayAmount": 100, "type": null, "id": 1773964780221}]	18	10	2
367	V7593	60	2026-03-21 01:30:44.546824	PAID	3	[{"method": "EFECTIVO", "amount": 60, "displayAmount": 60, "type": null, "id": 1774057121155, "received": 60, "cambio": 0}]	21	4	20
385	V1584	87	2026-03-21 01:53:53.503715	PAID	6	[{"method": "EFECTIVO", "amount": 87, "displayAmount": 200, "type": null, "id": 1774058055264, "received": 200, "cambio": 113}]	21	9	20
387	V5832	30	2026-03-21 01:55:33.52313	PAID	5	[{"method": "EFECTIVO", "amount": 30, "displayAmount": 30, "type": null, "id": 1774624624435, "received": 30, "cambio": 0}]	71	15	20
500	V7353	9	2026-03-21 13:27:19.458468	PAID	4	[{"method": "EFECTIVO", "amount": 9, "displayAmount": 9, "type": null, "id": 1774099659519, "received": 9, "cambio": 0}]	23	10	20
388	V7135	123	2026-03-21 01:56:00.29517	PAID	6	[{"method": "EFECTIVO", "amount": 123, "received": 500, "cambio": 377, "displayAmount": 500, "type": null, "id": 1774211895372}]	27	21	3
389	V8073	159	2026-03-21 01:57:37.240668	PAID	5	[{"method": "EFECTIVO", "amount": 159, "displayAmount": 200, "type": null, "id": 1774058286028, "received": 200, "cambio": 41}]	21	21	20
390	V4113	33	2026-03-21 01:57:43.201459	PAID	6	[{"method": "EFECTIVO", "amount": 33, "displayAmount": 50, "type": null, "id": 1774058319505, "received": 50, "cambio": 17}]	21	9	20
394	V9215	17	2026-03-21 01:59:58.169116	PAID	5	[{"method": "EFECTIVO", "amount": 17, "displayAmount": 100, "type": null, "id": 1774058444330, "received": 100, "cambio": 83}]	21	18	20
395	V1955	35	2026-03-21 02:00:00.238408	PAID	6	[{"method": "EFECTIVO", "amount": 35, "displayAmount": 40, "type": null, "id": 1774058476635, "received": 40, "cambio": 5}]	21	9	20
398	V1019	230	2026-03-21 02:04:29.693197	PAID	4	[{"method": "EFECTIVO", "amount": 230, "displayAmount": 300, "type": null, "id": 1774058689257, "received": 300, "cambio": 70}]	21	4	20
402	V4243	56	2026-03-21 02:06:34.513302	PAID	5	[{"method": "EFECTIVO", "amount": 56, "displayAmount": 70, "type": null, "id": 1774058852396, "received": 70, "cambio": 14}]	21	18	20
484	V8994	125	2026-03-21 13:00:39.443056	PAID	3	[{"method": "EFECTIVO", "amount": 125, "displayAmount": 140, "type": null, "id": 1774098075994, "received": 140, "cambio": 15}]	23	9	20
397	V4795	23	2026-03-21 02:03:30.652397	PAID	5	[{"method": "EFECTIVO", "amount": 23, "received": 23, "cambio": 0, "displayAmount": 23, "type": null, "id": 1774098186091}]	23	18	20
488	V6584	56	2026-03-21 13:03:59.437873	PAID	5	[{"method": "EFECTIVO", "amount": 56, "displayAmount": 60, "type": null, "id": 1774098274461, "received": 60, "cambio": 4}]	23	9	20
2245	V2165	81	2026-03-26 02:34:03.703164	PAID	5	[{"method": "EFECTIVO", "amount": 81, "received": 100, "cambio": 19, "displayAmount": 100, "type": null, "id": 1774492465206}]	35	18	3
493	V7102	155	2026-03-21 13:12:22.816477	PAID	3	[{"method": "EFECTIVO", "amount": 155, "displayAmount": 505, "type": null, "id": 1774098767221, "received": 505, "cambio": 350}]	23	22	20
492	V4649	90	2026-03-21 13:08:55.342658	PAID	5	[{"method": "EFECTIVO", "amount": 90, "displayAmount": 90, "type": null, "id": 1774099012547, "received": 90, "cambio": 0}]	23	23	20
496	V7399	78	2026-03-21 13:20:30.641583	PAID	3	[{"method": "EFECTIVO", "amount": 78, "displayAmount": 500, "type": null, "id": 1774099245931, "received": 500, "cambio": 422}]	23	22	20
497	V8578	29	2026-03-21 13:21:28.222324	PAID	3	[{"method": "EFECTIVO", "amount": 29, "displayAmount": 29, "type": null, "id": 1774099303923, "received": 29, "cambio": 0}]	23	22	20
502	V6729	74	2026-03-21 13:29:09.744525	PAID	4	[{"method": "EFECTIVO", "amount": 74, "displayAmount": 200, "type": null, "id": 1774099761381, "received": 200, "cambio": 126}]	23	10	20
503	V7332	50	2026-03-21 13:30:01.756345	PAID	3	[{"method": "EFECTIVO", "amount": 50, "displayAmount": 200, "type": null, "id": 1774099813541, "received": 200, "cambio": 150}]	23	22	20
508	V7608	69	2026-03-21 13:34:53.436361	PAID	3	[{"method": "EFECTIVO", "amount": 69, "displayAmount": 100, "type": null, "id": 1774100108969, "received": 100, "cambio": 31}]	23	22	20
515	V2564	68	2026-03-21 13:39:11.554612	PAID	4	[{"method": "EFECTIVO", "amount": 68, "received": 200, "cambio": 132, "displayAmount": 200, "type": null, "id": 1774312875398}]	28	9	20
516	V5659	148	2026-03-21 13:39:30.404019	PAID	5	[{"method": "EFECTIVO", "amount": 148, "displayAmount": 200, "type": null, "id": 1774100394916, "received": 200, "cambio": 52}]	23	10	20
519	V2379	27	2026-03-21 13:43:00.431214	PAID	5	[{"method": "EFECTIVO", "amount": 27, "received": 27, "cambio": 0, "displayAmount": 27, "type": null, "id": 1774320338210}]	28	18	20
521	V2511	18	2026-03-21 13:44:48.750535	PAID	3	[{"method": "EFECTIVO", "amount": 18, "displayAmount": 20, "type": null, "id": 1774100698303, "received": 20, "cambio": 2}]	23	22	20
525	V9417	53	2026-03-21 13:47:39.236418	PAID	3	[{"method": "EFECTIVO", "amount": 53, "displayAmount": 53, "type": null, "id": 1774100885005, "received": 53, "cambio": 0}]	23	22	20
577	V7321	308	2026-03-21 14:34:44.482948	PAID	5	[{"method": "EFECTIVO", "amount": 308, "received": 508, "cambio": 200, "displayAmount": 508, "type": null, "id": 1774103723803}]	23	9	20
579	V7158	93	2026-03-21 14:37:19.593095	PAID	4	[{"method": "EFECTIVO", "amount": 93, "displayAmount": 500, "type": null, "id": 1774103847003, "received": 500, "cambio": 407}]	23	10	20
237	V4688	11	2026-03-19 23:37:02.924427	PAID	5	[{"method": "EFECTIVO", "amount": 11, "received": 100, "cambio": 89, "displayAmount": 100, "type": null, "id": 1774318797851}]	28	18	20
239	V7464	50	2026-03-19 23:41:01.645589	PAID	5	[{"method": "EFECTIVO", "amount": 50, "received": 50, "cambio": 0, "displayAmount": 50, "type": null, "id": 1773963730952}]	18	18	2
240	V7109	35	2026-03-19 23:41:15.117775	PAID	1	[{"method": "EFECTIVO", "amount": 35, "received": 100, "cambio": 65, "displayAmount": 100, "type": null, "id": 1773963755928}]	18	4	2
242	V6531	25	2026-03-19 23:41:55.839118	PAID	5	[{"method": "EFECTIVO", "amount": 25, "received": 50, "cambio": 25, "displayAmount": 50, "type": null, "id": 1773963838979}]	18	18	2
244	V9074	60	2026-03-19 23:44:31.806711	PAID	4	[{"method": "EFECTIVO", "amount": 60, "received": 200, "cambio": 140, "displayAmount": 200, "type": null, "id": 1773963885423}]	18	8	2
243	V7159	74	2026-03-19 23:44:18.829514	PAID	5	[{"method": "EFECTIVO", "amount": 74, "received": 100, "cambio": 26, "displayAmount": 100, "type": null, "id": 1773963927151}]	18	18	2
217	V4755	26	2026-03-19 22:43:34.504701	PAID	5	[{"method": "EFECTIVO", "amount": 26, "received": 26, "cambio": 0, "displayAmount": 26, "type": null, "id": 1773963960467}]	18	18	2
250	V8107	93	2026-03-19 23:53:11.513049	PAID	4	[{"method": "EFECTIVO", "amount": 93, "received": 200, "cambio": 107, "displayAmount": 200, "type": null, "id": 1773964434791}]	18	8	2
252	V1588	73	2026-03-19 23:57:37.231541	PAID	6	[{"method": "EFECTIVO", "amount": 73, "received": 100, "cambio": 27, "displayAmount": 100, "type": null, "id": 1773964687994}]	18	4	2
255	V4294	23	2026-03-19 23:59:41.933389	PAID	1	[{"method": "EFECTIVO", "amount": 23, "received": 23, "cambio": 0, "displayAmount": 23, "type": null, "id": 1773964822597}]	18	18	2
257	V6821	94	2026-03-19 23:59:48.50132	PAID	6	[{"method": "EFECTIVO", "amount": 94, "received": 100, "cambio": 6, "displayAmount": 100, "type": null, "id": 1773964836291}]	18	4	2
258	V9295	43	2026-03-20 00:01:05.465123	PAID	4	[{"method": "EFECTIVO", "amount": 43, "received": 100, "cambio": 57, "displayAmount": 100, "type": null, "id": 1773964875468}]	18	8	2
259	V6615	93	2026-03-20 00:01:17.589184	PAID	5	[{"method": "EFECTIVO", "amount": 93, "received": 100, "cambio": 7, "displayAmount": 100, "type": null, "id": 1773964910860}]	18	10	2
260	V1721	26	2026-03-20 00:01:36.983057	PAID	5	[{"method": "EFECTIVO", "amount": 26, "received": 100, "cambio": 74, "displayAmount": 100, "type": null, "id": 1773964938330}]	18	10	2
262	V6464	90	2026-03-20 00:04:54.379285	PAID	3	[{"method": "EFECTIVO", "amount": 90, "received": 100, "cambio": 10, "displayAmount": 100, "type": null, "id": 1773965104829}]	18	8	2
264	V5443	258	2026-03-20 00:06:22.676289	PAID	1	[{"method": "EFECTIVO", "amount": 258, "received": 260, "cambio": 2, "displayAmount": 260, "type": null, "id": 1773965200436}]	18	18	2
263	V1066	58	2026-03-20 00:05:56.796553	PAID	6	[{"method": "EFECTIVO", "amount": 58, "received": 60, "cambio": 2, "displayAmount": 60, "type": null, "id": 1774403329248}]	30	8	3
265	V8987	92	2026-03-20 00:07:31.084886	PAID	3	[{"method": "EFECTIVO", "amount": 92, "received": 100, "cambio": 8, "displayAmount": 100, "type": null, "id": 1773965304940}]	18	8	2
266	V1170	26	2026-03-20 00:12:12.297751	PAID	5	[{"method": "EFECTIVO", "amount": 26, "received": 26, "cambio": 0, "displayAmount": 26, "type": null, "id": 1774396746036}]	29	4	20
269	V1522	115	2026-03-20 00:13:33.714722	PAID	5	[{"method": "EFECTIVO", "amount": 115, "displayAmount": 115, "type": null, "id": 1774448135911, "received": 115, "cambio": 0}]	31	16	20
268	V7065	73	2026-03-20 00:13:23.501378	PAID	4	[{"method": "EFECTIVO", "amount": 73, "received": 73, "cambio": 0, "displayAmount": 73, "type": null, "id": 1773965639962}]	18	9	2
275	V1837	18	2026-03-20 00:18:44.035636	PAID	4	[{"method": "EFECTIVO", "amount": 18, "displayAmount": 18, "type": null, "id": 1774621626637, "received": 18, "cambio": 0}]	71	17	20
270	V6593	88	2026-03-20 00:15:07.382509	PAID	6	[{"method": "EFECTIVO", "amount": 88, "received": 100, "cambio": 12, "displayAmount": 100, "type": null, "id": 1773965723930}]	18	8	2
271	V1928	139	2026-03-20 00:15:43.535363	PAID	1	[{"method": "EFECTIVO", "amount": 139, "received": 150, "cambio": 11, "displayAmount": 150, "type": null, "id": 1773965761185}]	18	18	2
272	V5575	108	2026-03-20 00:16:14.468416	PAID	5	[{"method": "EFECTIVO", "amount": 108, "received": 200, "cambio": 92, "displayAmount": 200, "type": null, "id": 1773965800755}]	18	4	2
273	V2904	14	2026-03-20 00:17:17.093934	PAID	5	[{"method": "EFECTIVO", "amount": 14, "received": 50, "cambio": 36, "displayAmount": 50, "type": null, "id": 1773965870373}]	18	4	2
274	V1027	99	2026-03-20 00:18:27.157959	PAID	3	[{"method": "EFECTIVO", "amount": 99, "received": 100, "cambio": 1, "displayAmount": 100, "type": null, "id": 1773965931455}]	18	9	2
261	V4152	130	2026-03-20 00:03:24.893354	PAID	1	[{"method": "TARJETA", "amount": 130, "received": 130, "cambio": 0, "displayAmount": 130, "type": "DEBITO", "id": 1773966080554}]	18	18	2
276	V6400	69	2026-03-20 00:21:44.419273	PAID	4	[{"method": "EFECTIVO", "amount": 69, "received": 100, "cambio": 31, "displayAmount": 100, "type": null, "id": 1773966118876}]	18	18	2
277	V1309	132	2026-03-20 00:24:10.643833	PAID	4	[{"method": "EFECTIVO", "amount": 132, "received": 150, "cambio": 18, "displayAmount": 150, "type": null, "id": 1773966358602}]	18	18	2
278	V8037	195	2026-03-20 00:24:51.753297	PAID	5	[{"method": "EFECTIVO", "amount": 195, "received": 200, "cambio": 5, "displayAmount": 200, "type": null, "id": 1773966388513}]	18	8	2
279	V4103	68	2026-03-20 00:26:47.389098	PAID	4	[{"method": "EFECTIVO", "amount": 68, "received": 100, "cambio": 32, "displayAmount": 100, "type": null, "id": 1773966433817}]	18	18	2
280	V7961	29	2026-03-20 00:27:15.338197	PAID	5	[{"method": "EFECTIVO", "amount": 29, "received": 50, "cambio": 21, "displayAmount": 50, "type": null, "id": 1773966503029}]	18	8	2
281	V1527	90	2026-03-20 00:28:58.334387	PAID	4	[{"method": "EFECTIVO", "amount": 90, "received": 90, "cambio": 0, "displayAmount": 90, "type": null, "id": 1774402348114}]	30	13	3
282	V3656	56	2026-03-20 00:31:12.747418	PAID	3	[{"method": "EFECTIVO", "amount": 56, "received": 200, "cambio": 144, "displayAmount": 200, "type": null, "id": 1773966693252}]	18	18	2
267	V8482	12	2026-03-20 00:13:13.742785	PAID	6	[{"method": "EFECTIVO", "amount": 12, "displayAmount": 12, "type": null, "id": 1774374610897, "received": 12, "cambio": 0}]	29	16	20
286	V8487	121	2026-03-20 13:04:09.074377	PAID	5	[{"method": "EFECTIVO", "amount": 121, "displayAmount": 121, "type": null, "id": 1774052643330, "received": 121, "cambio": 0}]	21	14	20
284	V8024	49	2026-03-20 12:52:32.743725	PAID	4	[{"method": "EFECTIVO", "amount": 49, "displayAmount": 49, "type": null, "id": 1774052906565, "received": 49, "cambio": 0}]	21	15	20
290	V2363	38	2026-03-20 13:07:21.240527	PAID	3	[{"method": "EFECTIVO", "amount": 38, "displayAmount": 38, "type": null, "id": 1774052391827, "received": 38, "cambio": 0}]	21	14	20
297	V8381	33	2026-03-20 13:15:32.460259	PAID	3	[{"method": "EFECTIVO", "amount": 33, "received": 33, "cambio": 0, "displayAmount": 33, "type": null, "id": 1774052501645}]	21	14	20
295	V9205	112	2026-03-20 13:10:33.983703	PAID	3	[{"method": "EFECTIVO", "amount": 112, "displayAmount": 112, "type": null, "id": 1774052515234, "received": 112, "cambio": 0}]	21	14	20
288	V1398	18	2026-03-20 13:06:25.93319	PAID	5	[{"method": "EFECTIVO", "amount": 18, "displayAmount": 18, "type": null, "id": 1774052801732, "received": 18, "cambio": 0}]	21	14	20
296	V9693	59	2026-03-20 13:15:03.170613	PAID	4	[{"method": "EFECTIVO", "amount": 59, "displayAmount": 100, "type": null, "id": 1774451421945, "received": 100, "cambio": 41}]	31	16	20
408	V4428	293	2026-03-21 02:10:46.905908	PAID	5	[{"method": "EFECTIVO", "amount": 293, "displayAmount": 300, "type": null, "id": 1774059086297, "received": 300, "cambio": 7}]	21	18	20
411	V3360	76	2026-03-21 02:12:43.115576	PAID	4	[{"method": "EFECTIVO", "amount": 76, "displayAmount": 100, "type": null, "id": 1774059194152, "received": 100, "cambio": 24}]	21	4	20
413	V8088	143	2026-03-21 02:14:47.392101	PAID	4	[{"method": "EFECTIVO", "amount": 143, "displayAmount": 253, "type": null, "id": 1774059320652, "received": 253, "cambio": 110}]	21	4	20
414	V8201	47	2026-03-21 02:16:12.668938	PAID	4	[{"method": "EFECTIVO", "amount": 47, "received": 50, "cambio": 3, "displayAmount": 50, "type": null, "id": 1774315292362}]	28	4	20
420	V2849	116	2026-03-21 02:21:43.535596	PAID	4	[{"method": "EFECTIVO", "amount": 116, "displayAmount": 200, "type": null, "id": 1774059726618, "received": 200, "cambio": 84}]	21	4	20
421	V5247	62	2026-03-21 02:22:17.39484	PAID	3	[{"method": "EFECTIVO", "amount": 62, "received": 100, "cambio": 38, "displayAmount": 100, "type": null, "id": 1774488944083}]	35	8	3
429	V6389	75	2026-03-21 02:29:12.722794	PAID	5	[{"method": "EFECTIVO", "amount": 75, "displayAmount": 100, "type": null, "id": 1774060176610, "received": 100, "cambio": 25}]	21	18	20
438	V7087	126	2026-03-21 02:37:52.812079	PAID	4	[{"method": "EFECTIVO", "amount": 126, "displayAmount": 130, "type": null, "id": 1774060754672, "received": 130, "cambio": 4}]	21	8	20
442	V2645	82	2026-03-21 02:39:08.039386	PAID	3	[{"method": "EFECTIVO", "amount": 82, "displayAmount": 200, "type": null, "id": 1774060803639, "received": 200, "cambio": 118}]	21	21	20
445	V3563	35	2026-03-21 02:41:14.935931	PAID	4	[{"method": "EFECTIVO", "amount": 35, "received": 35, "cambio": 0, "displayAmount": 35, "type": null, "id": 1774192649253}]	27	22	3
509	V2787	44	2026-03-21 13:35:29.588294	PAID	5	[{"method": "EFECTIVO", "amount": 44, "displayAmount": 200, "type": null, "id": 1774100141362, "received": 200, "cambio": 156}]	23	10	20
418	V2517	17	2026-03-21 02:19:06.457286	PAID	4	[{"method": "EFECTIVO", "amount": 17, "received": 20, "cambio": 3, "displayAmount": 20, "type": null, "id": 1774229206948}]	27	28	3
485	V3965	35	2026-03-21 13:01:00.63798	PAID	5	[{"method": "EFECTIVO", "amount": 35, "received": 35, "cambio": 0, "displayAmount": 35, "type": null, "id": 1774192502680}]	27	10	3
486	V3183	20	2026-03-21 13:01:43.358462	PAID	3	[{"method": "EFECTIVO", "amount": 20, "displayAmount": 20, "type": null, "id": 1774098157649, "received": 20, "cambio": 0}]	23	9	20
490	V3516	63	2026-03-21 13:06:49.153526	PAID	3	[{"method": "EFECTIVO", "amount": 63, "received": 63, "cambio": 0, "displayAmount": 63, "type": null, "id": 1774571970505}]	70	13	1
494	V9868	27	2026-03-21 13:15:10.796661	PAID	3	[{"method": "EFECTIVO", "amount": 27, "displayAmount": 27, "type": null, "id": 1774098927838, "received": 27, "cambio": 0}]	23	22	20
86	V3945	11	2026-03-19 00:05:45.117401	PAID	6	[{"method": "EFECTIVO", "amount": 11, "displayAmount": 11, "type": null, "id": 1774098952470, "received": 11, "cambio": 0}]	23	22	20
495	V4506	65	2026-03-21 13:19:05.146005	PAID	3	[{"method": "EFECTIVO", "amount": 65, "displayAmount": 70, "type": null, "id": 1774099155574, "received": 70, "cambio": 5}]	23	22	20
501	V1467	85	2026-03-21 13:28:00.325046	PAID	3	[{"method": "EFECTIVO", "amount": 85, "displayAmount": 100, "type": null, "id": 1774099689625, "received": 100, "cambio": 15}]	23	22	20
504	V3325	54	2026-03-21 13:30:26.635694	PAID	4	[{"method": "EFECTIVO", "amount": 54, "displayAmount": 100, "type": null, "id": 1774099843620, "received": 100, "cambio": 46}]	23	10	20
506	V2278	30	2026-03-21 13:31:17.519297	PAID	5	[{"method": "EFECTIVO", "amount": 30, "displayAmount": 200, "type": null, "id": 1774099911898, "received": 200, "cambio": 170}]	23	9	20
513	V6012	76	2026-03-21 13:36:56.561607	PAID	3	[{"method": "EFECTIVO", "amount": 76, "displayAmount": 100, "type": null, "id": 1774100233855, "received": 100, "cambio": 24}]	23	22	20
512	V2331	38	2026-03-21 13:36:52.175312	PAID	6	[{"method": "EFECTIVO", "amount": 38, "displayAmount": 100, "type": null, "id": 1774100258377, "received": 100, "cambio": 62}]	23	23	20
514	V2913	75	2026-03-21 13:38:51.877988	PAID	3	[{"method": "EFECTIVO", "amount": 75, "received": 100, "cambio": 25, "displayAmount": 100, "type": null, "id": 1774489742419}]	35	24	3
518	V5746	54	2026-03-21 13:41:43.055392	PAID	3	[{"method": "EFECTIVO", "amount": 54, "displayAmount": 55, "type": null, "id": 1774100520412, "received": 55, "cambio": 1}]	23	22	20
520	V6598	23	2026-03-21 13:43:53.150311	PAID	3	[{"method": "EFECTIVO", "amount": 23, "received": 100, "cambio": 77, "displayAmount": 100, "type": null, "id": 1774450734076}]	31	16	20
522	V7900	102	2026-03-21 13:45:30.631507	PAID	5	[{"method": "EFECTIVO", "amount": 102, "displayAmount": 120, "type": null, "id": 1774100778398, "received": 120, "cambio": 18}]	23	10	20
524	V2333	20	2026-03-21 13:46:06.609709	PAID	4	[{"method": "EFECTIVO", "amount": 20, "received": 20, "cambio": 0, "displayAmount": 20, "type": null, "id": 1774100832068}]	23	9	20
578	V3355	50	2026-03-21 14:34:48.301248	PAID	3	[{"method": "EFECTIVO", "amount": 50, "displayAmount": 500, "type": null, "id": 1774619510511, "received": 500, "cambio": 450}]	71	15	20
582	V3858	18	2026-03-21 14:38:23.77833	PAID	3	[{"method": "EFECTIVO", "amount": 18, "displayAmount": 18, "type": null, "id": 1774103923965, "received": 18, "cambio": 0}]	23	23	20
592	V1952	103	2026-03-21 14:43:14.706697	PAID	3	[{"method": "EFECTIVO", "amount": 103, "received": 103, "cambio": 0, "displayAmount": 103, "type": null, "id": 1774575065237}]	70	24	1
593	V9318	73	2026-03-21 14:43:42.330289	PAID	5	[{"method": "EFECTIVO", "amount": 73, "displayAmount": 200, "type": null, "id": 1774104272498, "received": 200, "cambio": 127}]	23	22	20
299	V4714	123	2026-03-21 00:01:34.940814	PAID	3	[{"method": "EFECTIVO", "amount": 123, "displayAmount": 223, "type": null, "id": 1774051346209, "received": 223, "cambio": 100}]	20	4	1
300	V5096	75	2026-03-21 00:03:19.162113	PAID	4	[{"method": "EFECTIVO", "amount": 75, "displayAmount": 90, "type": null, "id": 1774051420939, "received": 90, "cambio": 15}]	20	15	1
301	V9454	108	2026-03-21 00:05:03.589913	PAID	5	[{"method": "EFECTIVO", "amount": 108, "displayAmount": 500, "type": null, "id": 1774051558496, "received": 500, "cambio": 392}]	20	18	1
302	V6398	83	2026-03-21 00:06:13.145403	PAID	5	[{"method": "EFECTIVO", "amount": 83, "received": 100, "cambio": 17, "displayAmount": 100, "type": null, "id": 1774491927181}]	35	24	3
304	V2444	131	2026-03-21 00:07:24.477487	PAID	4	[{"method": "TARJETA", "amount": 131, "displayAmount": 131, "type": "DEBITO", "id": 1774051718628}]	20	15	1
305	V6360	48	2026-03-21 00:08:04.373071	PAID	5	[{"method": "EFECTIVO", "amount": 48, "displayAmount": 50, "type": null, "id": 1774051765026, "received": 50, "cambio": 2}]	20	18	1
306	V5339	78	2026-03-21 00:08:24.483294	PAID	3	[{"method": "EFECTIVO", "amount": 78, "received": 500, "cambio": 422, "displayAmount": 500, "type": null, "id": 1774576297119}]	70	4	1
307	V3728	94	2026-03-21 00:09:40.778271	PAID	4	[{"method": "EFECTIVO", "amount": 94, "displayAmount": 95, "type": null, "id": 1774051874381, "received": 95, "cambio": 1}]	20	15	1
308	V1021	71	2026-03-21 00:11:10.982563	PAID	4	[{"method": "EFECTIVO", "amount": 71, "displayAmount": 501, "type": null, "id": 1774051916524, "received": 501, "cambio": 430}]	20	15	1
309	V4454	107	2026-03-21 00:11:36.609566	PAID	5	[{"method": "EFECTIVO", "amount": 107, "displayAmount": 110, "type": null, "id": 1774051964736, "received": 110, "cambio": 3}]	20	18	1
310	V3383	44	2026-03-21 00:12:17.785103	PAID	4	[{"method": "EFECTIVO", "amount": 44, "displayAmount": 100, "type": null, "id": 1774051999317, "received": 100, "cambio": 56}]	20	15	1
311	V6514	47	2026-03-21 00:13:39.320312	PAID	3	[{"method": "TARJETA", "amount": 47, "received": 47, "cambio": 0, "displayAmount": 47, "type": "DEBITO", "id": 1774052066551}]	20	18	1
313	V6236	46	2026-03-21 00:17:50.415544	PAID	5	[{"method": "EFECTIVO", "amount": 46, "displayAmount": 47, "type": null, "id": 1774101684006, "received": 47, "cambio": 1}]	23	22	20
314	V8110	46	2026-03-21 00:18:59.41009	PAID	5	[{"method": "EFECTIVO", "amount": 46, "displayAmount": 100, "type": null, "id": 1774052357676, "received": 100, "cambio": 54}]	21	18	20
292	V4386	17	2026-03-20 13:07:52.795009	PAID	3	[{"method": "EFECTIVO", "amount": 17, "displayAmount": 17, "type": null, "id": 1774052405817, "received": 17, "cambio": 0}]	21	14	20
294	V7392	87	2026-03-20 13:09:12.508226	PAID	3	[{"method": "EFECTIVO", "amount": 87, "displayAmount": 87, "type": null, "id": 1774052418202, "received": 87, "cambio": 0}]	21	14	20
315	V7969	28	2026-03-21 00:20:59.481415	PAID	5	[{"method": "EFECTIVO", "amount": 28, "received": 28, "cambio": 0, "displayAmount": 28, "type": null, "id": 1774558793692}]	69	24	20
285	V4864	29	2026-03-20 13:02:13.783053	PAID	5	[{"method": "EFECTIVO", "amount": 29, "displayAmount": 29, "type": null, "id": 1774052537796, "received": 29, "cambio": 0}]	21	14	20
287	V7630	35	2026-03-20 13:05:33.524936	PAID	5	[{"method": "EFECTIVO", "amount": 35, "received": 35, "cambio": 0, "displayAmount": 35, "type": null, "id": 1774052549022}]	21	14	20
303	V6212	65	2026-03-21 00:07:19.080004	PAID	5	[{"method": "EFECTIVO", "amount": 65, "received": 65, "cambio": 0, "displayAmount": 65, "type": null, "id": 1774052631616}]	21	18	20
317	V5590	52	2026-03-21 00:24:06.831227	PAID	5	[{"method": "EFECTIVO", "amount": 52, "displayAmount": 52, "type": null, "id": 1774052683770, "received": 52, "cambio": 0}]	21	21	20
316	V6704	83	2026-03-21 00:22:39.818132	PAID	5	[{"method": "EFECTIVO", "amount": 83, "received": 83, "cambio": 0, "displayAmount": 83, "type": null, "id": 1774052696566}]	21	18	20
318	V6859	235	2026-03-21 00:24:58.926805	PAID	5	[{"method": "EFECTIVO", "amount": 235, "received": 235, "cambio": 0, "displayAmount": 235, "type": null, "id": 1774573990243}]	70	8	1
319	V6703	80	2026-03-21 00:25:19.440449	PAID	4	[{"method": "EFECTIVO", "amount": 80, "displayAmount": 100, "type": null, "id": 1774052760863, "received": 100, "cambio": 20}]	21	18	20
289	V1812	38	2026-03-20 13:06:35.558177	PAID	4	[{"method": "EFECTIVO", "amount": 38, "displayAmount": 38, "type": null, "id": 1774052823296, "received": 38, "cambio": 0}]	21	15	20
256	V1199	27	2026-03-19 23:59:44.207074	PAID	4	[{"method": "EFECTIVO", "amount": 27, "displayAmount": 27, "type": null, "id": 1774052841124, "received": 27, "cambio": 0}]	21	8	20
293	V5740	52	2026-03-20 13:09:06.008166	PAID	4	[{"method": "EFECTIVO", "amount": 52, "displayAmount": 52, "type": null, "id": 1774052851378, "received": 52, "cambio": 0}]	21	15	20
298	V8698	42	2026-03-20 13:16:26.078763	PAID	4	[{"method": "EFECTIVO", "amount": 42, "displayAmount": 42, "type": null, "id": 1774052894177, "received": 42, "cambio": 0}]	21	15	20
329	V2435	198	2026-03-21 00:44:30.215301	PAID	2	[{"method": "EFECTIVO", "amount": 198, "displayAmount": 500, "type": null, "id": 1774053861799, "received": 500, "cambio": 302}]	21	20	\N
312	V3173	99	2026-03-21 00:15:59.010617	PAID	5	[{"method": "EFECTIVO", "amount": 99, "displayAmount": 99, "type": null, "id": 1774052954758, "received": 99, "cambio": 0}]	21	18	20
320	V2173	261	2026-03-21 00:29:08.295799	PAID	4	[{"method": "EFECTIVO", "amount": 261, "displayAmount": 400, "type": null, "id": 1774052975327, "received": 400, "cambio": 139}]	21	18	20
321	V7918	84	2026-03-21 00:29:19.121176	PAID	6	[{"method": "EFECTIVO", "amount": 84, "displayAmount": 100, "type": null, "id": 1774053007852, "received": 100, "cambio": 16}]	21	4	20
322	V6633	76	2026-03-21 00:30:06.061931	PAID	5	[{"method": "EFECTIVO", "amount": 76, "displayAmount": 200, "type": null, "id": 1774053041833, "received": 200, "cambio": 124}]	21	21	20
323	V3418	30	2026-03-21 00:30:12.90566	PAID	4	[{"method": "EFECTIVO", "amount": 30, "displayAmount": 200, "type": null, "id": 1774053104707, "received": 200, "cambio": 170}]	21	18	20
324	V2719	52	2026-03-21 00:32:47.417655	PAID	5	[{"method": "EFECTIVO", "amount": 52, "displayAmount": 100, "type": null, "id": 1774281092396, "received": 100, "cambio": 48}]	28	20	20
325	V5681	101	2026-03-21 00:35:29.695418	PAID	3	[{"method": "EFECTIVO", "amount": 101, "displayAmount": 501, "type": null, "id": 1774053345671, "received": 501, "cambio": 400}]	21	21	20
283	V5156	62	2026-03-20 00:32:59.805476	PAID	5	[{"method": "EFECTIVO", "amount": 62, "displayAmount": 100, "type": null, "id": 1774059994479, "received": 100, "cambio": 38}]	21	8	20
327	V6416	70	2026-03-21 00:37:43.681715	PAID	5	[{"method": "EFECTIVO", "amount": 70, "received": 100, "cambio": 30, "displayAmount": 100, "type": null, "id": 1774489816202}]	35	8	3
328	V4416	58	2026-03-21 00:38:58.242996	PAID	5	[{"method": "EFECTIVO", "amount": 58, "displayAmount": 100, "type": null, "id": 1774062628595, "received": 100, "cambio": 42}]	21	4	20
2246	V2611	51	2026-03-26 02:35:29.934784	PAID	5	[{"method": "EFECTIVO", "amount": 51, "received": 100, "cambio": 49, "displayAmount": 100, "type": null, "id": 1774492549042}]	35	18	3
337	V7220	113	2026-03-21 00:56:48.295286	PAID	4	[{"method": "TARJETA", "amount": 113, "received": 113, "cambio": 0, "displayAmount": 113, "type": "DEBITO", "id": 1774054773286}]	21	18	20
338	V7352	50	2026-03-21 00:59:31.61516	PAID	3	[{"method": "EFECTIVO", "amount": 50, "displayAmount": 100, "type": null, "id": 1774054839166, "received": 100, "cambio": 50}]	21	4	20
341	V5727	26	2026-03-21 01:00:33.712468	PAID	3	[{"method": "EFECTIVO", "amount": 26, "displayAmount": 56, "type": null, "id": 1774054972217, "received": 56, "cambio": 30}]	21	4	20
343	V7269	230	2026-03-21 01:02:18.992113	PAID	3	[{"method": "EFECTIVO", "amount": 230, "displayAmount": 230, "type": null, "id": 1774055017870, "received": 230, "cambio": 0}]	21	4	20
342	V4421	66	2026-03-21 01:02:09.567626	PAID	5	[{"method": "EFECTIVO", "amount": 66, "displayAmount": 70, "type": null, "id": 1774055057524, "received": 70, "cambio": 4}]	21	21	20
345	V9811	29	2026-03-21 01:03:36.627693	PAID	3	[{"method": "EFECTIVO", "amount": 29, "displayAmount": 200, "type": null, "id": 1774055129397, "received": 200, "cambio": 171}]	21	4	20
349	V4823	52	2026-03-21 01:06:28.377679	PAID	5	[{"method": "EFECTIVO", "amount": 52, "displayAmount": 52, "type": null, "id": 1774360823321, "received": 52, "cambio": 0}]	29	16	20
350	V2329	119	2026-03-21 01:09:36.629602	PAID	5	[{"method": "EFECTIVO", "amount": 119, "displayAmount": 200, "type": null, "id": 1774055398653, "received": 200, "cambio": 81}]	21	18	20
353	V8790	115	2026-03-21 01:11:35.869101	PAID	4	[{"method": "EFECTIVO", "amount": 115, "displayAmount": 200, "type": null, "id": 1774055597925, "received": 200, "cambio": 85}]	21	4	20
409	V8175	92	2026-03-21 02:11:17.201616	PAID	4	[{"method": "EFECTIVO", "amount": 92, "displayAmount": 100, "type": null, "id": 1774059120520, "received": 100, "cambio": 8}]	21	4	20
410	V1977	60	2026-03-21 02:12:33.971799	PAID	3	[{"method": "EFECTIVO", "amount": 60, "displayAmount": 100, "type": null, "id": 1774059165650, "received": 100, "cambio": 40}]	21	21	20
412	V3564	101	2026-03-21 02:13:31.557014	PAID	5	[{"method": "EFECTIVO", "amount": 101, "displayAmount": 200, "type": null, "id": 1774059235467, "received": 200, "cambio": 99}]	21	18	20
415	V1914	47	2026-03-21 02:16:59.219128	PAID	4	[{"method": "EFECTIVO", "amount": 47, "displayAmount": 50, "type": null, "id": 1774059444863, "received": 50, "cambio": 3}]	21	4	20
416	V1196	97	2026-03-21 02:17:57.165472	PAID	4	[{"method": "EFECTIVO", "amount": 97, "received": 97, "cambio": 0, "displayAmount": 97, "type": null, "id": 1774210843868}]	27	25	3
417	V8811	77	2026-03-21 02:18:03.503674	PAID	5	[{"method": "EFECTIVO", "amount": 77, "received": 200, "cambio": 123, "displayAmount": 200, "type": null, "id": 1774315041291}]	28	4	20
422	V2171	40	2026-03-21 02:22:29.976693	PAID	3	[{"method": "EFECTIVO", "amount": 40, "received": 200, "cambio": 160, "displayAmount": 200, "type": null, "id": 1774318215217}]	28	18	20
423	V7685	65	2026-03-21 02:22:57.39752	PAID	4	[{"method": "EFECTIVO", "amount": 65, "displayAmount": 500, "type": null, "id": 1774059817452, "received": 500, "cambio": 435}]	21	4	20
424	V4546	40	2026-03-21 02:24:04.590767	PAID	4	[{"method": "EFECTIVO", "amount": 40, "displayAmount": 200, "type": null, "id": 1774059863990, "received": 200, "cambio": 160}]	21	4	20
425	V7818	50	2026-03-21 02:24:23.176653	PAID	5	[{"method": "EFECTIVO", "amount": 50, "displayAmount": 50, "type": null, "id": 1774539140028, "received": 50, "cambio": 0}]	69	15	20
427	V6730	143	2026-03-21 02:27:53.711257	PAID	5	[{"method": "EFECTIVO", "amount": 143, "displayAmount": 143, "type": null, "id": 1774060103503, "received": 143, "cambio": 0}]	21	18	20
226	V4194	214	2026-03-19 23:04:43.632346	PAID	5	[{"method": "EFECTIVO", "amount": 214, "displayAmount": 215, "type": null, "id": 1774060215865, "received": 215, "cambio": 1}]	21	4	20
431	V7544	66	2026-03-21 02:30:25.764799	PAID	5	[{"method": "EFECTIVO", "amount": 66, "displayAmount": 66, "type": null, "id": 1774060310010, "received": 66, "cambio": 0}]	21	18	20
437	V2613	20	2026-03-21 02:37:48.222632	PAID	3	[{"method": "EFECTIVO", "amount": 20, "received": 20, "cambio": 0, "displayAmount": 20, "type": null, "id": 1774391456438}]	29	9	20
440	V6384	96	2026-03-21 02:38:50.324617	PAID	5	[{"method": "EFECTIVO", "amount": 96, "displayAmount": 100, "type": null, "id": 1774060779129, "received": 100, "cambio": 4}]	21	18	20
441	V4946	61	2026-03-21 02:38:57.678115	PAID	4	[{"method": "EFECTIVO", "amount": 61, "displayAmount": 65, "type": null, "id": 1774362805471, "received": 65, "cambio": 4}]	29	14	20
439	V1971	112	2026-03-21 02:38:41.297792	PAID	6	[{"method": "EFECTIVO", "amount": 112, "received": 112, "cambio": 0, "displayAmount": 112, "type": null, "id": 1774489655993}]	35	9	3
446	V4834	92	2026-03-21 02:41:53.392855	PAID	6	[{"method": "EFECTIVO", "amount": 92, "displayAmount": 500, "type": null, "id": 1774060997532, "received": 500, "cambio": 408}]	21	4	20
449	V9864	206	2026-03-21 02:43:24.657097	PAID	3	[{"method": "TARJETA", "amount": 206, "displayAmount": 206, "type": "DEBITO", "id": 1774061097313}]	21	9	20
444	V9574	26	2026-03-21 02:40:00.22544	PAID	6	[{"method": "EFECTIVO", "amount": 26, "displayAmount": 100, "type": null, "id": 1774634580607, "received": 100, "cambio": 74}]	71	20	20
172	V9947	114	2026-03-19 15:29:31.231553	PAID	3	[{"method": "EFECTIVO", "amount": 114, "received": 500, "cambio": 386, "displayAmount": 500, "type": null, "id": 1774219254900}]	27	25	3
346	V6483	77	2026-03-21 01:05:00.113342	PAID	2	[{"method": "EFECTIVO", "amount": 77, "displayAmount": 500, "type": null, "id": 1774621316834, "received": 500, "cambio": 423}]	71	15	20
407	V1773	95	2026-03-21 02:09:46.554605	PAID	3	[{"method": "EFECTIVO", "amount": 95, "received": 100, "cambio": 5, "displayAmount": 100, "type": null, "id": 1774543715017}]	69	15	20
419	V6506	137	2026-03-21 02:19:46.820553	PAID	4	[{"method": "EFECTIVO", "amount": 137, "received": 500, "cambio": 363, "displayAmount": 500, "type": null, "id": 1774485548994}]	35	18	3
2	V5545	80	2026-03-13 19:43:02.549459	PAID	1	[{"method": "EFECTIVO", "amount": 80, "received": 100, "cambio": 20, "displayAmount": 100, "type": null, "id": 1774489309748}]	35	18	3
326	V5389	56	2026-03-21 00:37:24.059677	PAID	3	[{"method": "EFECTIVO", "amount": 56, "displayAmount": 106, "type": null, "id": 1774053475311, "received": 106, "cambio": 50}]	21	21	20
331	V3000	258	2026-03-21 00:47:46.868327	PAID	5	[{"method": "EFECTIVO", "amount": 258, "displayAmount": 308, "type": null, "id": 1774054090499, "received": 308, "cambio": 50}]	21	18	20
335	V9087	69	2026-03-21 00:51:43.850322	PAID	4	[{"method": "EFECTIVO", "amount": 69, "displayAmount": 100, "type": null, "id": 1774054342160, "received": 100, "cambio": 31}]	21	18	20
336	V9631	156	2026-03-21 00:56:37.621109	PAID	3	[{"method": "TARJETA", "amount": 156, "displayAmount": 156, "type": "DEBITO", "id": 1774054630778}]	21	4	20
339	V6623	57	2026-03-21 00:59:33.837568	PAID	4	[{"method": "EFECTIVO", "amount": 57, "displayAmount": 100, "type": null, "id": 1774054867901, "received": 100, "cambio": 43}]	21	18	20
344	V9156	23	2026-03-21 01:03:33.301887	PAID	4	[{"method": "EFECTIVO", "amount": 23, "displayAmount": 23, "type": null, "id": 1774449314755, "received": 23, "cambio": 0}]	31	16	20
348	V2347	23	2026-03-21 01:05:35.482785	PAID	5	[{"method": "EFECTIVO", "amount": 23, "displayAmount": 203, "type": null, "id": 1774055218224, "received": 203, "cambio": 180}]	21	21	20
355	V6130	38	2026-03-21 01:12:26.107699	PAID	5	[{"method": "EFECTIVO", "amount": 38, "displayAmount": 50, "type": null, "id": 1774055631000, "received": 50, "cambio": 12}]	21	18	20
354	V4508	86	2026-03-21 01:12:25.028955	PAID	4	[{"method": "EFECTIVO", "amount": 86, "received": 200, "cambio": 114, "displayAmount": 200, "type": null, "id": 1774577556965}]	70	13	1
356	V6687	139	2026-03-21 01:14:18.774834	PAID	3	[{"method": "EFECTIVO", "amount": 139, "displayAmount": 140, "type": null, "id": 1774055686455, "received": 140, "cambio": 1}]	21	4	20
334	V4377	24	2026-03-21 00:51:40.058511	PAID	5	[{"method": "EFECTIVO", "amount": 24, "displayAmount": 24, "type": null, "id": 1774057022950, "received": 24, "cambio": 0}]	21	20	20
426	V9462	17	2026-03-21 02:24:38.385665	PAID	4	[{"method": "EFECTIVO", "amount": 17, "displayAmount": 100, "type": null, "id": 1774059927394, "received": 100, "cambio": 83}]	21	4	20
428	V1391	89	2026-03-21 02:28:33.226612	PAID	3	[{"method": "EFECTIVO", "amount": 89, "displayAmount": 100, "type": null, "id": 1774133009290, "received": 100, "cambio": 11}]	23	20	20
430	V2361	78	2026-03-21 02:29:53.829328	PAID	6	[{"method": "EFECTIVO", "amount": 78, "displayAmount": 100, "type": null, "id": 1774060259109, "received": 100, "cambio": 22}]	21	8	20
432	V6114	162	2026-03-21 02:33:38.923485	PAID	5	[{"method": "EFECTIVO", "amount": 162, "displayAmount": 162, "type": null, "id": 1774060448423, "received": 162, "cambio": 0}]	21	18	20
433	V6050	57	2026-03-21 02:35:07.349625	PAID	4	[{"method": "EFECTIVO", "amount": 57, "displayAmount": 100, "type": null, "id": 1774060527862, "received": 100, "cambio": 43}]	21	8	20
434	V6734	53	2026-03-21 02:35:53.783722	PAID	5	[{"method": "EFECTIVO", "amount": 53, "displayAmount": 200, "type": null, "id": 1774060566717, "received": 200, "cambio": 147}]	21	18	20
435	V8326	106	2026-03-21 02:37:15.06489	PAID	6	[{"method": "EFECTIVO", "amount": 106, "displayAmount": 210, "type": null, "id": 1774060697740, "received": 210, "cambio": 104}]	21	4	20
443	V7860	37	2026-03-21 02:39:39.316451	PAID	5	[{"method": "EFECTIVO", "amount": 37, "received": 100, "cambio": 63, "displayAmount": 100, "type": null, "id": 1774230469165}]	27	25	3
448	V1735	31	2026-03-21 02:43:12.670852	PAID	4	[{"method": "EFECTIVO", "amount": 31, "displayAmount": 31, "type": null, "id": 1774632717010, "received": 31, "cambio": 0}]	71	17	20
447	V5008	25	2026-03-21 02:42:53.912248	PAID	6	[{"method": "EFECTIVO", "amount": 25, "displayAmount": 25, "type": null, "id": 1774098976949, "received": 25, "cambio": 0}]	23	4	20
526	V2732	8	2026-03-21 13:48:22.534856	PAID	5	[{"method": "EFECTIVO", "amount": 8, "displayAmount": 8, "type": null, "id": 1774100953289, "received": 8, "cambio": 0}]	23	9	20
528	V1327	77	2026-03-21 13:49:59.58821	PAID	5	[{"method": "EFECTIVO", "amount": 77, "displayAmount": 100, "type": null, "id": 1774101037608, "received": 100, "cambio": 23}]	23	9	20
531	V5616	23	2026-03-21 13:51:34.85221	PAID	5	[{"method": "EFECTIVO", "amount": 23, "displayAmount": 100, "type": null, "id": 1774101108862, "received": 100, "cambio": 77}]	23	9	20
535	V5425	39	2026-03-21 13:57:23.788419	PAID	5	[{"method": "EFECTIVO", "amount": 39, "displayAmount": 50, "type": null, "id": 1774101461133, "received": 50, "cambio": 11}]	23	10	20
536	V4425	41	2026-03-21 13:58:30.740829	PAID	5	[{"method": "EFECTIVO", "amount": 41, "displayAmount": 501, "type": null, "id": 1774101526652, "received": 501, "cambio": 460}]	23	10	20
538	V1005	74	2026-03-21 13:59:33.235667	PAID	5	[{"method": "EFECTIVO", "amount": 74, "displayAmount": 100, "type": null, "id": 1774101618631, "received": 100, "cambio": 26}]	23	10	20
540	V1622	32	2026-03-21 14:01:45.464627	PAID	3	[{"method": "EFECTIVO", "amount": 32, "received": 32, "cambio": 0, "displayAmount": 32, "type": null, "id": 1774192285029}]	27	10	3
543	V7162	36	2026-03-21 14:05:19.699171	PAID	3	[{"method": "EFECTIVO", "amount": 36, "displayAmount": 50, "type": null, "id": 1774101941996, "received": 50, "cambio": 14}]	23	22	20
544	V7659	38	2026-03-21 14:06:14.497952	PAID	3	[{"method": "EFECTIVO", "amount": 38, "displayAmount": 40, "type": null, "id": 1774102034322, "received": 40, "cambio": 2}]	23	22	20
558	V9203	24	2026-03-21 14:18:13.26134	PAID	3	[{"method": "EFECTIVO", "amount": 24, "displayAmount": 25, "type": null, "id": 1774102705145, "received": 25, "cambio": 1}]	23	22	20
560	V9477	55	2026-03-21 14:19:54.87424	PAID	3	[{"method": "EFECTIVO", "amount": 55, "displayAmount": 100, "type": null, "id": 1774147508795, "received": 100, "cambio": 45}]	23	25	20
562	V7459	6	2026-03-21 14:20:56.671392	PAID	3	[{"method": "EFECTIVO", "amount": 6, "displayAmount": 6, "type": null, "id": 1774102893522, "received": 6, "cambio": 0}]	23	22	20
563	V4063	44	2026-03-21 14:21:31.815132	PAID	5	[{"method": "EFECTIVO", "amount": 44, "received": 50, "cambio": 6, "displayAmount": 50, "type": null, "id": 1774572373983}]	70	13	1
565	V1602	78	2026-03-21 14:23:23.972011	PAID	5	[{"method": "EFECTIVO", "amount": 78, "received": 78, "cambio": 0, "displayAmount": 78, "type": null, "id": 1774148051791}]	23	13	20
539	V7543	41	2026-03-21 13:59:48.765985	PAID	3	[{"method": "EFECTIVO", "amount": 41, "received": 41, "cambio": 0, "displayAmount": 41, "type": null, "id": 1774111650529}]	23	22	20
436	V5468	69	2026-03-21 02:37:47.337784	PAID	2	[{"method": "EFECTIVO", "amount": 69, "received": 200, "cambio": 131, "displayAmount": 200, "type": null, "id": 1774402802418}]	30	24	3
330	V4902	77	2026-03-21 00:45:03.805798	PAID	3	[{"method": "EFECTIVO", "amount": 77, "received": 200, "cambio": 123, "displayAmount": 200, "type": null, "id": 1774053918253}]	21	21	20
333	V7357	99	2026-03-21 00:48:10.859217	PAID	3	[{"method": "EFECTIVO", "amount": 99, "displayAmount": 100, "type": null, "id": 1774054124792, "received": 100, "cambio": 1}]	21	21	20
340	V5531	49	2026-03-21 01:00:10.370298	PAID	5	[{"method": "EFECTIVO", "amount": 49, "displayAmount": 100, "type": null, "id": 1774054915650, "received": 100, "cambio": 51}]	21	21	20
347	V7668	155	2026-03-21 01:05:04.074059	PAID	5	[{"method": "EFECTIVO", "amount": 155, "displayAmount": 200, "type": null, "id": 1774055188590, "received": 200, "cambio": 45}]	21	21	20
351	V8185	195	2026-03-21 01:11:13.726237	PAID	3	[{"method": "EFECTIVO", "amount": 195, "displayAmount": 500, "type": null, "id": 1774055490206, "received": 500, "cambio": 305}]	21	21	20
352	V2460	48	2026-03-21 01:11:18.707625	PAID	5	[{"method": "EFECTIVO", "amount": 48, "displayAmount": 500, "type": null, "id": 1774055553429, "received": 500, "cambio": 452}]	21	18	20
450	V6755	144	2026-03-21 02:44:07.871641	PAID	6	[{"method": "EFECTIVO", "amount": 144, "received": 500, "cambio": 356, "displayAmount": 500, "type": null, "id": 1774317625561}]	28	9	20
454	V7833	88	2026-03-21 02:49:34.940341	PAID	6	[{"method": "EFECTIVO", "amount": 88, "displayAmount": 100, "type": null, "id": 1774061403286, "received": 100, "cambio": 12}]	21	4	20
455	V6207	174	2026-03-21 02:49:40.872245	PAID	5	[{"method": "EFECTIVO", "amount": 174, "displayAmount": 200, "type": null, "id": 1774061461452, "received": 200, "cambio": 26}]	21	18	20
2247	V4403	78	2026-03-26 02:36:55.693908	PAID	5	[{"method": "EFECTIVO", "amount": 78, "received": 78, "cambio": 0, "displayAmount": 78, "type": null, "id": 1774492635321}]	35	18	3
458	V8804	29	2026-03-21 02:53:38.909668	PAID	6	[{"method": "EFECTIVO", "amount": 29, "displayAmount": 29, "type": null, "id": 1774061653938, "received": 29, "cambio": 0}]	21	4	20
461	V5024	124	2026-03-21 02:57:38.600791	PAID	3	[{"method": "EFECTIVO", "amount": 124, "displayAmount": 124, "type": null, "id": 1774061907819, "received": 124, "cambio": 0}]	21	4	20
462	V5511	65	2026-03-21 02:58:37.140138	PAID	5	[{"method": "EFECTIVO", "amount": 65, "displayAmount": 100, "type": null, "id": 1774061937288, "received": 100, "cambio": 35}]	21	18	20
464	V8827	161	2026-03-21 03:03:51.146466	PAID	3	[{"method": "EFECTIVO", "amount": 161, "displayAmount": 200, "type": null, "id": 1774062241753, "received": 200, "cambio": 39}]	21	4	20
470	V9346	88	2026-03-21 03:08:12.87297	PAID	5	[{"method": "EFECTIVO", "amount": 88, "displayAmount": 500, "type": null, "id": 1774408552613, "received": 500, "cambio": 412}]	30	8	3
472	V2223	57	2026-03-21 03:09:11.991275	PAID	4	[{"method": "EFECTIVO", "amount": 57, "displayAmount": 100, "type": null, "id": 1774062599724, "received": 100, "cambio": 43}]	21	21	20
473	V9905	90	2026-03-21 03:10:15.907224	PAID	5	[{"method": "EFECTIVO", "amount": 90, "displayAmount": 200, "type": null, "id": 1774062682698, "received": 200, "cambio": 110}]	21	18	20
478	V6433	31	2026-03-21 03:15:01.574236	PAID	5	[{"method": "EFECTIVO", "amount": 31, "displayAmount": 50, "type": null, "id": 1774062923424, "received": 50, "cambio": 19}]	21	18	20
479	V2916	94	2026-03-21 03:18:43.924567	PAID	3	[{"method": "TARJETA", "amount": 94, "displayAmount": 94, "type": "DEBITO", "id": 1774063168719}]	21	4	20
332	V1193	99	2026-03-21 00:47:58.330862	PAID	3	[{"method": "EFECTIVO", "amount": 99, "displayAmount": 99, "type": null, "id": 1774099044865, "received": 99, "cambio": 0}]	23	21	20
527	V4801	32	2026-03-21 13:48:28.189668	PAID	3	[{"method": "EFECTIVO", "amount": 32, "displayAmount": 32, "type": null, "id": 1774100968855, "received": 32, "cambio": 0}]	23	22	20
529	V2562	26	2026-03-21 13:50:01.663243	PAID	3	[{"method": "EFECTIVO", "amount": 26, "received": 50, "cambio": 24, "displayAmount": 50, "type": null, "id": 1774312801601}]	28	18	20
530	V4344	187	2026-03-21 13:50:33.298253	PAID	4	[{"method": "EFECTIVO", "amount": 187, "displayAmount": 200, "type": null, "id": 1774101065508, "received": 200, "cambio": 13}]	23	10	20
532	V4277	106	2026-03-21 13:52:11.293576	PAID	3	[{"method": "EFECTIVO", "amount": 106, "displayAmount": 500, "type": null, "id": 1774101145735, "received": 500, "cambio": 394}]	23	22	20
534	V7638	50	2026-03-21 13:57:08.307631	PAID	3	[{"method": "EFECTIVO", "amount": 50, "displayAmount": 50, "type": null, "id": 1774139380722, "received": 50, "cambio": 0}]	23	13	20
537	V9149	24	2026-03-21 13:59:12.527319	PAID	3	[{"method": "EFECTIVO", "amount": 24, "displayAmount": 24, "type": null, "id": 1774101579784, "received": 24, "cambio": 0}]	23	22	20
542	V1767	59	2026-03-21 14:04:12.842876	PAID	3	[{"method": "EFECTIVO", "amount": 59, "displayAmount": 60, "type": null, "id": 1774101869058, "received": 60, "cambio": 1}]	23	22	20
545	V9262	49	2026-03-21 14:06:30.983688	PAID	5	[{"method": "EFECTIVO", "amount": 49, "displayAmount": 50, "type": null, "id": 1774102091070, "received": 50, "cambio": 1}]	23	10	20
551	V8657	38	2026-03-21 14:11:35.284575	PAID	5	[{"method": "EFECTIVO", "amount": 38, "displayAmount": 38, "type": null, "id": 1774102312184, "received": 38, "cambio": 0}]	23	10	20
552	V2515	74	2026-03-21 14:11:58.413313	PAID	3	[{"method": "EFECTIVO", "amount": 74, "displayAmount": 200, "type": null, "id": 1774102329736, "received": 200, "cambio": 126}]	23	22	20
556	V4620	34	2026-03-21 14:14:12.472855	PAID	4	[{"method": "EFECTIVO", "amount": 34, "displayAmount": 200, "type": null, "id": 1774102498739, "received": 200, "cambio": 166}]	23	9	20
559	V9365	99	2026-03-21 14:19:29.346474	PAID	5	[{"method": "TARJETA", "amount": 99, "displayAmount": 99, "type": "DEBITO", "id": 1774102799179}]	23	10	20
564	V2386	98	2026-03-21 14:22:51.763985	PAID	5	[{"method": "EFECTIVO", "amount": 98, "received": 100, "cambio": 2, "displayAmount": 100, "type": null, "id": 1774575980160}]	70	13	1
567	V3335	65	2026-03-21 14:26:49.817025	PAID	5	[{"method": "EFECTIVO", "amount": 65, "received": 100, "cambio": 35, "displayAmount": 100, "type": null, "id": 1774576795880}]	70	13	1
570	V1374	161	2026-03-21 14:28:09.123151	PAID	5	[{"method": "EFECTIVO", "amount": 161, "displayAmount": 500, "type": null, "id": 1774144739019, "received": 500, "cambio": 339}]	23	13	20
571	V5061	28	2026-03-21 14:30:06.209015	PAID	4	[{"method": "EFECTIVO", "amount": 28, "displayAmount": 58, "type": null, "id": 1774364664683, "received": 58, "cambio": 30}]	29	16	20
452	V8704	32	2026-03-21 02:46:16.199691	PAID	6	[{"method": "EFECTIVO", "amount": 32, "displayAmount": 50, "type": null, "id": 1774293188648, "received": 50, "cambio": 18}]	28	20	20
595	V8658	62	2026-03-21 14:45:11.765849	PAID	3	[{"method": "EFECTIVO", "amount": 62, "displayAmount": 62, "type": null, "id": 1774104345952, "received": 62, "cambio": 0}]	23	23	20
596	V4739	58	2026-03-21 14:45:37.908321	PAID	5	[{"method": "EFECTIVO", "amount": 58, "displayAmount": 60, "type": null, "id": 1774104387979, "received": 60, "cambio": 2}]	23	22	20
598	V7828	165	2026-03-21 14:46:39.691805	PAID	6	[{"method": "EFECTIVO", "amount": 165, "displayAmount": 500, "type": null, "id": 1774104432345, "received": 500, "cambio": 335}]	23	9	20
601	V1252	21	2026-03-21 14:49:04.612151	PAID	3	[{"method": "EFECTIVO", "amount": 21, "displayAmount": 21, "type": null, "id": 1774104558537, "received": 21, "cambio": 0}]	23	9	20
603	V2127	61	2026-03-21 14:50:44.127665	PAID	4	[{"method": "EFECTIVO", "amount": 61, "displayAmount": 100, "type": null, "id": 1774104714104, "received": 100, "cambio": 39}]	23	23	20
245	V2304	45	2026-03-19 23:49:08.962632	PAID	5	[{"method": "EFECTIVO", "amount": 45, "displayAmount": 45, "type": null, "id": 1774104799790, "received": 45, "cambio": 0}]	23	22	20
606	V5540	33	2026-03-21 14:52:23.826035	PAID	5	[{"method": "EFECTIVO", "amount": 33, "displayAmount": 50, "type": null, "id": 1774104823731, "received": 50, "cambio": 17}]	23	22	20
609	V6839	70	2026-03-21 14:54:27.607237	PAID	5	[{"method": "EFECTIVO", "amount": 70, "displayAmount": 100, "type": null, "id": 1774104898140, "received": 100, "cambio": 30}]	23	22	20
610	V5754	38	2026-03-21 14:54:30.778529	PAID	3	[{"method": "EFECTIVO", "amount": 38, "displayAmount": 100, "type": null, "id": 1774104929403, "received": 100, "cambio": 62}]	23	9	20
612	V1081	157	2026-03-21 14:55:37.451955	PAID	3	[{"method": "EFECTIVO", "amount": 157, "displayAmount": 200, "type": null, "id": 1774534287393, "received": 200, "cambio": 43}]	69	15	20
623	V8092	67	2026-03-21 15:02:24.510521	PAID	3	[{"method": "EFECTIVO", "amount": 67, "displayAmount": 500, "type": null, "id": 1774105391907, "received": 500, "cambio": 433}]	23	9	20
624	V9983	73	2026-03-21 15:03:30.684815	PAID	4	[{"method": "EFECTIVO", "amount": 73, "displayAmount": 500, "type": null, "id": 1774105445853, "received": 500, "cambio": 427}]	23	10	20
625	V7064	36	2026-03-21 15:04:21.515006	PAID	4	[{"method": "EFECTIVO", "amount": 36, "displayAmount": 40, "type": null, "id": 1774105499109, "received": 40, "cambio": 4}]	23	10	20
627	V6308	34	2026-03-21 15:04:42.948944	PAID	5	[{"method": "EFECTIVO", "amount": 34, "displayAmount": 34, "type": null, "id": 1774105521562, "received": 34, "cambio": 0}]	23	22	20
605	V1543	24	2026-03-21 14:51:14.66572	PAID	4	[{"method": "EFECTIVO", "amount": 24, "received": 24, "cambio": 0, "displayAmount": 24, "type": null, "id": 1774111515529}]	23	23	20
918	V2078	94	2026-03-22 03:25:12.354865	PAID	3	[{"method": "EFECTIVO", "amount": 94, "received": 94, "cambio": 0, "displayAmount": 94, "type": null, "id": 1774149923461}]	23	13	20
599	V4477	24	2026-03-21 14:47:27.2823	PAID	5	[{"method": "EFECTIVO", "amount": 24, "displayAmount": 24, "type": null, "id": 1774143343092, "received": 24, "cambio": 0}]	23	27	20
1146	V3527	65	2026-03-22 22:58:33.080537	PAID	5	[{"method": "EFECTIVO", "amount": 65, "received": 100, "cambio": 35, "displayAmount": 100, "type": null, "id": 1774220325962}]	27	25	3
1151	V2588	140	2026-03-22 23:18:31.676142	PAID	4	[{"method": "EFECTIVO", "amount": 140, "displayAmount": 150, "type": null, "id": 1774532951139, "received": 150, "cambio": 10}]	69	15	20
1155	V7547	32	2026-03-22 23:32:14.278726	PAID	5	[{"method": "EFECTIVO", "amount": 32, "received": 32, "cambio": 0, "displayAmount": 32, "type": null, "id": 1774222364051}]	27	25	3
1162	V6643	84	2026-03-22 23:42:20.431829	PAID	5	[{"method": "EFECTIVO", "amount": 84, "received": 84, "cambio": 0, "displayAmount": 84, "type": null, "id": 1774222947587}]	27	31	3
1165	V6728	26	2026-03-22 23:48:45.389883	PAID	5	[{"method": "EFECTIVO", "amount": 26, "received": 26, "cambio": 0, "displayAmount": 26, "type": null, "id": 1774572603633}]	70	9	1
1169	V3470	38	2026-03-22 23:53:01.995254	PAID	3	[{"method": "EFECTIVO", "amount": 38, "received": 38, "cambio": 0, "displayAmount": 38, "type": null, "id": 1774223634708}]	27	33	3
1113	V3457	90	2026-03-22 21:45:37.007696	PAID	3	[{"method": "EFECTIVO", "amount": 90, "received": 500, "cambio": 410, "displayAmount": 500, "type": null, "id": 1774223649121}]	27	25	3
1171	V4093	93	2026-03-22 23:54:57.316243	PAID	4	[{"method": "EFECTIVO", "amount": 93, "received": 508, "cambio": 415, "displayAmount": 508, "type": null, "id": 1774223712466}]	27	25	3
879	V1216	105	2026-03-22 02:22:11.891698	PAID	3	[{"method": "EFECTIVO", "amount": 105, "received": 105, "cambio": 0, "displayAmount": 105, "type": null, "id": 1774224133254}]	27	25	3
1181	V3134	79	2026-03-23 00:19:06.978506	PAID	5	[{"method": "EFECTIVO", "amount": 79, "received": 79, "cambio": 0, "displayAmount": 79, "type": null, "id": 1774225168840}]	27	25	3
1186	V5479	29	2026-03-23 00:30:37.942823	PAID	3	[{"method": "EFECTIVO", "amount": 29, "received": 29, "cambio": 0, "displayAmount": 29, "type": null, "id": 1774225880709}]	27	25	3
1190	V2407	145	2026-03-23 00:41:02.416684	PAID	1	[{"method": "EFECTIVO", "amount": 145, "received": 145, "cambio": 0, "displayAmount": 145, "type": null, "id": 1774226506095}]	27	26	3
1193	V9362	474	2026-03-23 00:51:06.110412	PAID	3	[{"method": "EFECTIVO", "amount": 474, "received": 500, "cambio": 26, "displayAmount": 500, "type": null, "id": 1774227078667}]	27	28	3
1194	V8586	38	2026-03-23 00:51:57.300839	PAID	1	[{"method": "EFECTIVO", "amount": 38, "received": 38, "cambio": 0, "displayAmount": 38, "type": null, "id": 1774227138710}]	27	26	3
1195	V4849	23	2026-03-23 00:52:14.676342	PAID	3	[{"method": "EFECTIVO", "amount": 23, "received": 23, "cambio": 0, "displayAmount": 23, "type": null, "id": 1774227151056}]	27	33	3
1236	V8121	36	2026-03-23 01:33:00.566498	PAID	6	[{"method": "EFECTIVO", "amount": 36, "received": 100, "cambio": 64, "displayAmount": 100, "type": null, "id": 1774229696755}]	27	25	3
1237	V5348	17	2026-03-23 01:34:33.126431	PAID	1	[{"method": "EFECTIVO", "amount": 17, "received": 17, "cambio": 0, "displayAmount": 17, "type": null, "id": 1774406140313}]	30	4	3
1152	V3072	84	2026-03-22 23:21:42.325214	PAID	2	[{"method": "EFECTIVO", "amount": 84, "displayAmount": 100, "type": null, "id": 1774297245810, "received": 100, "cambio": 16}]	28	4	20
594	V2667	35	2026-03-21 14:45:00.482172	PAID	5	[{"method": "EFECTIVO", "amount": 35, "received": 50, "cambio": 15, "displayAmount": 50, "type": null, "id": 1774299915531}]	28	4	20
1229	V4684	56	2026-03-23 01:29:14.090496	PAID	1	[{"method": "EFECTIVO", "amount": 56, "received": 56, "cambio": 0, "displayAmount": 56, "type": null, "id": 1774316867168}]	28	18	20
597	V4474	57	2026-03-21 14:46:14.47755	PAID	3	[{"method": "EFECTIVO", "amount": 57, "displayAmount": 70, "type": null, "id": 1774104410950, "received": 70, "cambio": 13}]	23	23	20
600	V6404	71	2026-03-21 14:48:10.936834	PAID	3	[{"method": "EFECTIVO", "amount": 71, "received": 200, "cambio": 129, "displayAmount": 200, "type": null, "id": 1774405731186}]	30	8	3
604	V3352	53	2026-03-21 14:50:54.21749	PAID	3	[{"method": "EFECTIVO", "amount": 53, "displayAmount": 60, "type": null, "id": 1774104755904, "received": 60, "cambio": 7}]	23	9	20
608	V9803	38	2026-03-21 14:53:13.856734	PAID	4	[{"method": "EFECTIVO", "amount": 38, "displayAmount": 200, "type": null, "id": 1774104851108, "received": 200, "cambio": 162}]	23	23	20
613	V8472	97	2026-03-21 14:56:12.675742	PAID	5	[{"method": "EFECTIVO", "amount": 97, "displayAmount": 200, "type": null, "id": 1774104982514, "received": 200, "cambio": 103}]	23	22	20
602	V9797	49	2026-03-21 14:50:31.628733	PAID	5	[{"method": "EFECTIVO", "amount": 49, "received": 49, "cambio": 0, "displayAmount": 49, "type": null, "id": 1774107822570}]	23	9	20
920	V8561	55	2026-03-22 13:17:23.662243	PAID	5	[{"method": "EFECTIVO", "amount": 55, "received": 55, "cambio": 0, "displayAmount": 55, "type": null, "id": 1774185463889}]	26	23	3
922	V2142	100	2026-03-22 13:18:37.347118	PAID	3	[{"method": "EFECTIVO", "amount": 100, "received": 100, "cambio": 0, "displayAmount": 100, "type": null, "id": 1774185528554}]	26	10	3
960	V1722	93	2026-03-22 14:31:10.703851	PAID	3	[{"method": "EFECTIVO", "amount": 93, "received": 200, "cambio": 107, "displayAmount": 200, "type": null, "id": 1774189933010}]	26	22	3
607	V8749	36	2026-03-21 14:53:11.139293	PAID	3	[{"method": "EFECTIVO", "amount": 36, "received": 36, "cambio": 0, "displayAmount": 36, "type": null, "id": 1774185559655}]	26	21	3
925	V3894	103	2026-03-22 13:34:13.111586	PAID	3	[{"method": "EFECTIVO", "amount": 103, "received": 200, "cambio": 97, "displayAmount": 200, "type": null, "id": 1774186465541}]	26	3	3
927	V8780	86	2026-03-22 13:48:50.57263	PAID	3	[{"method": "EFECTIVO", "amount": 86, "received": 200, "cambio": 114, "displayAmount": 200, "type": null, "id": 1774187342520}]	26	10	3
928	V4191	50	2026-03-22 13:55:09.124073	PAID	3	[{"method": "EFECTIVO", "amount": 50, "received": 50, "cambio": 0, "displayAmount": 50, "type": null, "id": 1774187718561}]	26	10	3
929	V2966	70	2026-03-22 13:56:56.024428	PAID	5	[{"method": "EFECTIVO", "amount": 70, "received": 70, "cambio": 0, "displayAmount": 70, "type": null, "id": 1774187831128}]	26	22	3
930	V9430	14	2026-03-22 13:58:42.410874	PAID	3	[{"method": "EFECTIVO", "amount": 14, "received": 100, "cambio": 86, "displayAmount": 100, "type": null, "id": 1774187940723}]	26	22	3
932	V6676	131	2026-03-22 14:03:10.501046	PAID	3	[{"method": "EFECTIVO", "amount": 131, "received": 131, "cambio": 0, "displayAmount": 131, "type": null, "id": 1774188201818}]	26	22	3
935	V4650	23	2026-03-22 14:09:18.736395	PAID	3	[{"method": "EFECTIVO", "amount": 23, "received": 23, "cambio": 0, "displayAmount": 23, "type": null, "id": 1774188573700}]	26	22	3
936	V6625	39	2026-03-22 14:11:36.929121	PAID	5	[{"method": "EFECTIVO", "amount": 39, "received": 39, "cambio": 0, "displayAmount": 39, "type": null, "id": 1774188710754}]	26	10	3
940	V9496	176	2026-03-22 14:14:15.88783	PAID	3	[{"method": "EFECTIVO", "amount": 176, "received": 200, "cambio": 24, "displayAmount": 200, "type": null, "id": 1774188889115}]	26	22	3
944	V2502	39	2026-03-22 14:20:16.79227	PAID	3	[{"method": "EFECTIVO", "amount": 39, "received": 500, "cambio": 461, "displayAmount": 500, "type": null, "id": 1774189232310}]	26	22	3
2244	V1317	35	2026-03-26 02:32:34.520203	PAID	3	[{"method": "EFECTIVO", "amount": 35, "received": 35, "cambio": 0, "displayAmount": 35, "type": null, "id": 1774492658584}]	35	24	3
952	V1532	71	2026-03-22 14:27:13.988621	PAID	5	[{"method": "EFECTIVO", "amount": 71, "received": 200, "cambio": 129, "displayAmount": 200, "type": null, "id": 1774189648100}]	26	10	3
984	V1296	68	2026-03-22 14:48:19.620196	PAID	3	[{"method": "EFECTIVO", "amount": 68, "displayAmount": 80, "type": null, "id": 1774631845950, "received": 80, "cambio": 12}]	71	20	20
955	V1978	56	2026-03-22 14:28:05.451866	PAID	4	[{"method": "EFECTIVO", "amount": 56, "received": 100, "cambio": 44, "displayAmount": 100, "type": null, "id": 1774189705551}]	26	23	3
954	V9445	23	2026-03-22 14:28:00.125068	PAID	3	[{"method": "EFECTIVO", "amount": 23, "received": 23, "cambio": 0, "displayAmount": 23, "type": null, "id": 1774316141358}]	28	9	20
957	V5910	37	2026-03-22 14:29:16.852096	PAID	3	[{"method": "TARJETA", "amount": 37, "received": 37, "cambio": 0, "displayAmount": 37, "type": "DEBITO", "id": 1774189840801}]	26	22	3
958	V8641	96	2026-03-22 14:29:43.829302	PAID	6	[{"method": "EFECTIVO", "amount": 96, "received": 100, "cambio": 4, "displayAmount": 100, "type": null, "id": 1774189859420}]	26	3	3
963	V8169	74	2026-03-22 14:33:03.83209	PAID	4	[{"method": "EFECTIVO", "amount": 74, "received": 500, "cambio": 426, "displayAmount": 500, "type": null, "id": 1774189992067}]	26	23	3
974	V4768	125	2026-03-22 14:39:38.542966	PAID	3	[{"method": "EFECTIVO", "amount": 125, "received": 125, "cambio": 0, "displayAmount": 125, "type": null, "id": 1774192348027}]	27	22	3
970	V4333	90	2026-03-22 14:36:08.322252	PAID	3	[{"method": "EFECTIVO", "amount": 90, "received": 100, "cambio": 10, "displayAmount": 100, "type": null, "id": 1774478083424}]	35	4	3
989	V6855	78	2026-03-22 14:52:56.450395	PAID	3	[{"method": "EFECTIVO", "amount": 78, "received": 78, "cambio": 0, "displayAmount": 78, "type": null, "id": 1774192459105}]	27	22	3
994	V6901	47	2026-03-22 15:03:03.663748	PAID	3	[{"method": "EFECTIVO", "amount": 47, "received": 47, "cambio": 0, "displayAmount": 47, "type": null, "id": 1774192476203}]	27	22	3
1188	V1626	81	2026-03-23 00:33:42.689487	PAID	3	[{"method": "EFECTIVO", "amount": 81, "received": 81, "cambio": 0, "displayAmount": 81, "type": null, "id": 1774226031753}]	27	25	3
998	V8509	25	2026-03-22 15:05:08.074407	PAID	4	[{"method": "EFECTIVO", "amount": 25, "received": 52, "cambio": 27, "displayAmount": 52, "type": null, "id": 1774192583478}]	27	10	3
980	V9242	59	2026-03-22 14:44:49.606909	PAID	4	[{"method": "EFECTIVO", "amount": 59, "received": 59, "cambio": 0, "displayAmount": 59, "type": null, "id": 1774192617478}]	27	23	3
985	V2021	9	2026-03-22 14:48:21.196997	PAID	5	[{"method": "EFECTIVO", "amount": 9, "received": 333, "cambio": 324, "displayAmount": 333, "type": null, "id": 1774192669466}]	27	10	3
615	V1147	157	2026-03-21 14:57:15.087253	PAID	4	[{"method": "EFECTIVO", "amount": 157, "displayAmount": 500, "type": null, "id": 1774449920012, "received": 500, "cambio": 343}]	31	15	20
614	V8189	51	2026-03-21 14:57:06.431034	PAID	3	[{"method": "EFECTIVO", "amount": 51, "displayAmount": 500, "type": null, "id": 1774105073782, "received": 500, "cambio": 449}]	23	9	20
616	V7862	38	2026-03-21 14:58:14.165784	PAID	3	[{"method": "EFECTIVO", "amount": 38, "displayAmount": 50, "type": null, "id": 1774105127267, "received": 50, "cambio": 12}]	23	9	20
617	V3119	46	2026-03-21 14:59:31.764428	PAID	3	[{"method": "EFECTIVO", "amount": 46, "displayAmount": 200, "type": null, "id": 1774105191281, "received": 200, "cambio": 154}]	23	9	20
618	V4947	102	2026-03-21 14:59:55.994608	PAID	4	[{"method": "EFECTIVO", "amount": 102, "received": 102, "cambio": 0, "displayAmount": 102, "type": null, "id": 1774207920304}]	27	21	3
620	V4992	74	2026-03-21 15:00:43.929422	PAID	5	[{"method": "EFECTIVO", "amount": 74, "displayAmount": 200, "type": null, "id": 1774105254403, "received": 200, "cambio": 126}]	23	22	20
621	V1008	41	2026-03-21 15:01:01.788753	PAID	3	[{"method": "EFECTIVO", "amount": 41, "displayAmount": 200, "type": null, "id": 1774105280776, "received": 200, "cambio": 159}]	23	9	20
622	V5171	67	2026-03-21 15:02:04.192941	PAID	4	[{"method": "EFECTIVO", "amount": 67, "displayAmount": 200, "type": null, "id": 1774105340616, "received": 200, "cambio": 133}]	23	10	20
626	V7705	107	2026-03-21 15:04:39.716671	PAID	3	[{"method": "EFECTIVO", "amount": 107, "displayAmount": 200, "type": null, "id": 1774105540700, "received": 200, "cambio": 93}]	23	9	20
619	V9940	5	2026-03-21 15:00:12.80904	PAID	3	[{"method": "EFECTIVO", "amount": 5, "displayAmount": 5, "type": null, "id": 1774107855522, "received": 5, "cambio": 0}]	23	9	20
921	V3761	42	2026-03-22 13:18:23.707873	PAID	4	[{"method": "EFECTIVO", "amount": 42, "received": 42, "cambio": 0, "displayAmount": 42, "type": null, "id": 1774185516742}]	26	21	3
924	V2948	40	2026-03-22 13:24:25.101719	PAID	3	[{"method": "EFECTIVO", "amount": 40, "received": 40, "cambio": 0, "displayAmount": 40, "type": null, "id": 1774185875234}]	26	10	3
923	V8502	65	2026-03-22 13:18:43.711601	PAID	5	[{"method": "EFECTIVO", "amount": 65, "received": 65, "cambio": 0, "displayAmount": 65, "type": null, "id": 1774186457373}]	26	23	3
933	V4442	104	2026-03-22 14:05:26.410115	PAID	5	[{"method": "EFECTIVO", "amount": 104, "received": 104, "cambio": 0, "displayAmount": 104, "type": null, "id": 1774188354531}]	26	10	3
934	V3445	67	2026-03-22 14:06:34.039129	PAID	3	[{"method": "EFECTIVO", "amount": 67, "received": 200, "cambio": 133, "displayAmount": 200, "type": null, "id": 1774188409368}]	26	22	3
938	V5944	39	2026-03-22 14:12:28.990085	PAID	5	[{"method": "EFECTIVO", "amount": 39, "received": 40, "cambio": 1, "displayAmount": 40, "type": null, "id": 1774188765862}]	26	10	3
942	V4125	31	2026-03-22 14:15:16.936731	PAID	3	[{"method": "EFECTIVO", "amount": 31, "received": 100, "cambio": 69, "displayAmount": 100, "type": null, "id": 1774578787230}]	70	4	1
941	V9106	60	2026-03-22 14:14:56.469469	PAID	5	[{"method": "EFECTIVO", "amount": 60, "received": 60, "cambio": 0, "displayAmount": 60, "type": null, "id": 1774188952228}]	26	10	3
946	V9421	33	2026-03-22 14:23:04.232533	PAID	3	[{"method": "EFECTIVO", "amount": 33, "received": 200, "cambio": 167, "displayAmount": 200, "type": null, "id": 1774189395355}]	26	22	3
947	V5841	50	2026-03-22 14:24:04.74399	PAID	3	[{"method": "EFECTIVO", "amount": 50, "received": 50, "cambio": 0, "displayAmount": 50, "type": null, "id": 1774189453952}]	26	22	3
948	V1104	68	2026-03-22 14:24:18.926973	PAID	5	[{"method": "EFECTIVO", "amount": 68, "received": 200, "cambio": 132, "displayAmount": 200, "type": null, "id": 1774189484394}]	26	10	3
956	V7072	102	2026-03-22 14:29:10.539407	PAID	5	[{"method": "EFECTIVO", "amount": 102, "received": 102, "cambio": 0, "displayAmount": 102, "type": null, "id": 1774189883111}]	26	10	3
964	V6567	101	2026-03-22 14:33:38.064132	PAID	3	[{"method": "EFECTIVO", "amount": 101, "received": 101, "cambio": 0, "displayAmount": 101, "type": null, "id": 1774190065399}]	26	22	3
966	V2490	58	2026-03-22 14:34:28.663816	PAID	5	[{"method": "EFECTIVO", "amount": 58, "received": 500, "cambio": 442, "displayAmount": 500, "type": null, "id": 1774190116409}]	26	10	3
969	V9869	94	2026-03-22 14:35:48.932274	PAID	4	[{"method": "EFECTIVO", "amount": 94, "received": 500, "cambio": 406, "displayAmount": 500, "type": null, "id": 1774190160871}]	26	23	3
968	V9129	104	2026-03-22 14:35:41.444039	PAID	6	[{"method": "EFECTIVO", "amount": 104, "received": 200, "cambio": 96, "displayAmount": 200, "type": null, "id": 1774190188600}]	26	21	3
2248	V9296	98	2026-03-26 02:37:28.34494	PAID	3	[{"method": "EFECTIVO", "amount": 98, "received": 100, "cambio": 2, "displayAmount": 100, "type": null, "id": 1774492664185}]	35	24	3
611	V1975	45	2026-03-21 14:55:14.411857	PAID	4	[{"method": "EFECTIVO", "amount": 45, "received": 100, "cambio": 55, "displayAmount": 100, "type": null, "id": 1774492576864}]	35	24	3
982	V8990	98	2026-03-22 14:47:48.094722	PAID	3	[{"method": "EFECTIVO", "amount": 98, "received": 98, "cambio": 0, "displayAmount": 98, "type": null, "id": 1774192207301}]	27	22	3
967	V6369	76	2026-03-22 14:35:27.223417	PAID	3	[{"method": "EFECTIVO", "amount": 76, "received": 76, "cambio": 0, "displayAmount": 76, "type": null, "id": 1774192290285}]	27	22	3
991	V7674	35	2026-03-22 14:55:36.3773	PAID	3	[{"method": "EFECTIVO", "amount": 35, "received": 35, "cambio": 0, "displayAmount": 35, "type": null, "id": 1774192464426}]	27	10	3
992	V2087	34	2026-03-22 14:58:18.143375	PAID	3	[{"method": "EFECTIVO", "amount": 34, "received": 34, "cambio": 0, "displayAmount": 34, "type": null, "id": 1774192471551}]	27	22	3
996	V6689	52	2026-03-22 15:03:46.605842	PAID	6	[{"method": "EFECTIVO", "amount": 52, "received": 52, "cambio": 0, "displayAmount": 52, "type": null, "id": 1774192492536}]	27	1	3
983	V8134	65	2026-03-22 14:47:49.505581	PAID	5	[{"method": "EFECTIVO", "amount": 65, "received": 65, "cambio": 0, "displayAmount": 65, "type": null, "id": 1774192497530}]	27	10	3
1192	V8577	89	2026-03-23 00:48:46.022677	PAID	1	[{"method": "EFECTIVO", "amount": 89, "displayAmount": 89, "type": null, "id": 1774374665036, "received": 89, "cambio": 0}]	29	20	20
1241	V5618	67	2026-03-23 01:41:22.52133	PAID	3	[{"method": "EFECTIVO", "amount": 67, "received": 100, "cambio": 33, "displayAmount": 100, "type": null, "id": 1774230118550}]	27	33	3
629	V5461	48	2026-03-21 15:07:01.720253	PAID	5	[{"method": "EFECTIVO", "amount": 48, "displayAmount": 50, "type": null, "id": 1774105643934, "received": 50, "cambio": 2}]	23	22	20
630	V7035	23	2026-03-21 15:07:41.008087	PAID	5	[{"method": "EFECTIVO", "amount": 23, "displayAmount": 23, "type": null, "id": 1774105716716, "received": 23, "cambio": 0}]	23	22	20
639	V4552	20	2026-03-21 15:19:40.468689	PAID	5	[{"method": "EFECTIVO", "amount": 20, "displayAmount": 100, "type": null, "id": 1774106431222, "received": 100, "cambio": 80}]	23	9	20
641	V1529	60	2026-03-21 15:23:08.129888	PAID	2	[{"method": "EFECTIVO", "amount": 60, "displayAmount": 70, "type": null, "id": 1774106586813, "received": 70, "cambio": 10}]	23	20	\N
642	V9941	67	2026-03-21 15:24:22.345364	PAID	5	[{"method": "EFECTIVO", "amount": 67, "displayAmount": 100, "type": null, "id": 1774106673969, "received": 100, "cambio": 33}]	23	9	20
646	V8031	29	2026-03-21 15:27:20.021189	PAID	5	[{"method": "EFECTIVO", "amount": 29, "displayAmount": 50, "type": null, "id": 1774106856431, "received": 50, "cambio": 21}]	23	9	20
653	V9418	35	2026-03-21 15:33:06.788349	PAID	4	[{"method": "EFECTIVO", "amount": 35, "displayAmount": 35, "type": null, "id": 1774107276452, "received": 35, "cambio": 0}]	23	10	20
655	V6117	31	2026-03-21 15:34:46.805889	PAID	4	[{"method": "EFECTIVO", "amount": 31, "received": 31, "cambio": 0, "displayAmount": 31, "type": null, "id": 1774574534466}]	70	24	1
658	V2206	22	2026-03-21 15:38:48.531536	PAID	3	[{"method": "EFECTIVO", "amount": 22, "displayAmount": 22, "type": null, "id": 1774450228018, "received": 22, "cambio": 0}]	31	16	20
665	V9666	62	2026-03-21 15:53:51.022127	PAID	3	[{"method": "EFECTIVO", "amount": 62, "displayAmount": 62, "type": null, "id": 1774108452498, "received": 62, "cambio": 0}]	23	20	20
666	V3219	52	2026-03-21 15:54:51.303455	PAID	3	[{"method": "EFECTIVO", "amount": 52, "displayAmount": 200, "type": null, "id": 1774535415771, "received": 200, "cambio": 148}]	69	14	20
677	V4109	26	2026-03-21 16:12:48.182754	PAID	3	[{"method": "EFECTIVO", "amount": 26, "received": 26, "cambio": 0, "displayAmount": 26, "type": null, "id": 1774111480044}]	23	22	20
634	V7995	47	2026-03-21 15:15:52.685127	PAID	5	[{"method": "EFECTIVO", "amount": 47, "received": 47, "cambio": 0, "displayAmount": 47, "type": null, "id": 1774111501386}]	23	22	20
672	V8591	44	2026-03-21 16:05:59.403631	PAID	5	[{"method": "EFECTIVO", "amount": 44, "received": 44, "cambio": 0, "displayAmount": 44, "type": null, "id": 1774111507505}]	23	22	20
635	V7305	104	2026-03-21 15:17:18.638758	PAID	4	[{"method": "EFECTIVO", "amount": 104, "received": 104, "cambio": 0, "displayAmount": 104, "type": null, "id": 1774111523153}]	23	10	20
632	V1102	52	2026-03-21 15:13:28.353174	PAID	5	[{"method": "EFECTIVO", "amount": 52, "received": 52, "cambio": 0, "displayAmount": 52, "type": null, "id": 1774111528675}]	23	22	20
679	V2819	52	2026-03-21 16:13:44.370747	PAID	4	[{"method": "EFECTIVO", "amount": 52, "received": 52, "cambio": 0, "displayAmount": 52, "type": null, "id": 1774111563392}]	23	9	20
681	V8891	57	2026-03-21 16:17:10.710613	PAID	4	[{"method": "EFECTIVO", "amount": 57, "received": 57, "cambio": 0, "displayAmount": 57, "type": null, "id": 1774111571083}]	23	9	20
926	V9706	215	2026-03-22 13:43:05.06083	PAID	5	[{"method": "EFECTIVO", "amount": 215, "received": 300, "cambio": 85, "displayAmount": 300, "type": null, "id": 1774217611166}]	27	28	3
931	V4401	60	2026-03-22 14:01:31.509226	PAID	5	[{"method": "EFECTIVO", "amount": 60, "received": 60, "cambio": 0, "displayAmount": 60, "type": null, "id": 1774188131679}]	26	10	3
937	V9642	110	2026-03-22 14:11:52.66434	PAID	3	[{"method": "EFECTIVO", "amount": 110, "received": 110, "cambio": 0, "displayAmount": 110, "type": null, "id": 1774188733026}]	26	22	3
939	V4139	50	2026-03-22 14:13:23.103258	PAID	5	[{"method": "EFECTIVO", "amount": 50, "received": 50, "cambio": 0, "displayAmount": 50, "type": null, "id": 1774188817028}]	26	10	3
945	V1073	71	2026-03-22 14:20:35.327748	PAID	5	[{"method": "EFECTIVO", "amount": 71, "received": 71, "cambio": 0, "displayAmount": 71, "type": null, "id": 1774575898135}]	70	13	1
949	V3212	58	2026-03-22 14:25:14.638235	PAID	5	[{"method": "EFECTIVO", "amount": 58, "received": 58, "cambio": 0, "displayAmount": 58, "type": null, "id": 1774233077036}]	27	25	3
951	V6119	69	2026-03-22 14:26:36.744361	PAID	3	[{"method": "EFECTIVO", "amount": 69, "received": 200, "cambio": 131, "displayAmount": 200, "type": null, "id": 1774189609809}]	26	22	3
959	V7299	150	2026-03-22 14:30:44.329088	PAID	5	[{"method": "EFECTIVO", "amount": 150, "received": 150, "cambio": 0, "displayAmount": 150, "type": null, "id": 1774580816021}]	70	24	1
962	V9450	77	2026-03-22 14:33:02.85221	PAID	5	[{"method": "EFECTIVO", "amount": 77, "received": 500, "cambio": 423, "displayAmount": 500, "type": null, "id": 1774190028039}]	26	10	3
965	V3281	62	2026-03-22 14:34:25.144465	PAID	4	[{"method": "EFECTIVO", "amount": 62, "received": 100, "cambio": 38, "displayAmount": 100, "type": null, "id": 1774190088551}]	26	23	3
979	V9245	89	2026-03-22 14:42:59.451021	PAID	3	[{"method": "EFECTIVO", "amount": 89, "received": 89, "cambio": 0, "displayAmount": 89, "type": null, "id": 1774192354398}]	27	22	3
973	V2273	79	2026-03-22 14:37:44.374183	PAID	5	[{"method": "EFECTIVO", "amount": 79, "received": 79, "cambio": 0, "displayAmount": 79, "type": null, "id": 1774192522751}]	27	10	3
997	V3546	68	2026-03-22 15:04:58.496921	PAID	3	[{"method": "EFECTIVO", "amount": 68, "received": 68, "cambio": 0, "displayAmount": 68, "type": null, "id": 1774192552822}]	27	22	3
993	V8648	62	2026-03-22 14:58:47.363765	PAID	5	[{"method": "EFECTIVO", "amount": 62, "received": 62, "cambio": 0, "displayAmount": 62, "type": null, "id": 1774192564801}]	27	10	3
961	V3204	275	2026-03-22 14:31:31.865729	PAID	4	[{"method": "EFECTIVO", "amount": 275, "received": 1000, "cambio": 725, "displayAmount": 1000, "type": null, "id": 1774192644430}]	27	23	3
990	V2861	48	2026-03-22 14:53:42.500006	PAID	5	[{"method": "EFECTIVO", "amount": 48, "received": 48, "cambio": 0, "displayAmount": 48, "type": null, "id": 1774192653934}]	27	10	3
975	V7419	97	2026-03-22 14:40:53.542435	PAID	5	[{"method": "EFECTIVO", "amount": 97, "received": 97, "cambio": 0, "displayAmount": 97, "type": null, "id": 1774192674287}]	27	10	3
628	V1804	99	2026-03-21 15:05:46.968333	PAID	4	[{"method": "EFECTIVO", "amount": 99, "received": 200, "cambio": 101, "displayAmount": 200, "type": null, "id": 1774226665556}]	27	26	3
1199	V8874	50	2026-03-23 00:58:12.513304	PAID	3	[{"method": "EFECTIVO", "amount": 50, "received": 50, "cambio": 0, "displayAmount": 50, "type": null, "id": 1774227521567}]	27	33	3
533	V1060	61	2026-03-21 13:53:54.126087	PAID	5	[{"method": "EFECTIVO", "amount": 61, "displayAmount": 61, "type": null, "id": 1774105702501, "received": 61, "cambio": 0}]	23	9	20
636	V3646	59	2026-03-21 15:17:45.714263	PAID	3	[{"method": "EFECTIVO", "amount": 59, "displayAmount": 200, "type": null, "id": 1774106368292, "received": 200, "cambio": 141}]	23	9	20
638	V8223	53	2026-03-21 15:19:17.177775	PAID	4	[{"method": "EFECTIVO", "amount": 53, "displayAmount": 100, "type": null, "id": 1774106401559, "received": 100, "cambio": 47}]	23	10	20
640	V1703	110	2026-03-21 15:22:38.984237	PAID	5	[{"method": "EFECTIVO", "amount": 110, "received": 110, "cambio": 0, "displayAmount": 110, "type": null, "id": 1774216733939}]	27	28	3
644	V8369	18	2026-03-21 15:26:21.028062	PAID	5	[{"method": "EFECTIVO", "amount": 18, "displayAmount": 20, "type": null, "id": 1774106794319, "received": 20, "cambio": 2}]	23	9	20
645	V6748	47	2026-03-21 15:26:35.843939	PAID	4	[{"method": "EFECTIVO", "amount": 47, "displayAmount": 47, "type": null, "id": 1774365057944, "received": 47, "cambio": 0}]	29	17	20
647	V5413	59	2026-03-21 15:29:11.360272	PAID	3	[{"method": "EFECTIVO", "amount": 59, "displayAmount": 100, "type": null, "id": 1774106967984, "received": 100, "cambio": 41}]	23	22	20
648	V3176	125	2026-03-21 15:29:39.903363	PAID	4	[{"method": "EFECTIVO", "amount": 125, "displayAmount": 200, "type": null, "id": 1774106996929, "received": 200, "cambio": 75}]	23	10	20
657	V9825	27	2026-03-21 15:37:36.913824	PAID	5	[{"method": "EFECTIVO", "amount": 27, "displayAmount": 50, "type": null, "id": 1774107499108, "received": 50, "cambio": 23}]	23	9	20
663	V1249	361	2026-03-21 15:46:44.708341	PAID	3	[{"method": "TARJETA", "amount": 361, "displayAmount": 361, "type": "DEBITO", "id": 1774108047115}]	23	9	20
670	V7434	34	2026-03-21 16:00:29.631929	PAID	3	[{"method": "EFECTIVO", "amount": 34, "displayAmount": 200, "type": null, "id": 1774533139763, "received": 200, "cambio": 166}]	69	17	20
673	V8340	62	2026-03-21 16:09:47.298468	PAID	5	[{"method": "EFECTIVO", "amount": 62, "received": 100, "cambio": 38, "displayAmount": 100, "type": null, "id": 1774109413323}]	23	22	20
676	V9612	61	2026-03-21 16:12:45.53722	PAID	4	[{"method": "EFECTIVO", "amount": 61, "received": 70, "cambio": 9, "displayAmount": 70, "type": null, "id": 1774109606969}]	23	9	20
682	V8738	52	2026-03-21 16:17:30.825378	PAID	3	[{"method": "EFECTIVO", "amount": 52, "received": 60, "cambio": 8, "displayAmount": 60, "type": null, "id": 1774109861396}]	23	22	20
683	V4200	71	2026-03-21 16:18:14.622644	PAID	4	[{"method": "EFECTIVO", "amount": 71, "received": 200, "cambio": 129, "displayAmount": 200, "type": null, "id": 1774109932910}]	23	9	20
684	V6082	36	2026-03-21 16:21:48.609675	PAID	4	[{"method": "EFECTIVO", "amount": 36, "received": 100, "cambio": 64, "displayAmount": 100, "type": null, "id": 1774110133767}]	23	9	20
631	V5998	61	2026-03-21 15:09:46.681216	PAID	5	[{"method": "EFECTIVO", "amount": 61, "received": 61, "cambio": 0, "displayAmount": 61, "type": null, "id": 1774111458003}]	23	22	20
637	V9719	23	2026-03-21 15:18:13.295251	PAID	4	[{"method": "EFECTIVO", "amount": 23, "received": 23, "cambio": 0, "displayAmount": 23, "type": null, "id": 1774111637736}]	23	10	20
669	V4971	43	2026-03-21 15:58:09.029134	PAID	3	[{"method": "EFECTIVO", "amount": 43, "received": 50, "cambio": 7, "displayAmount": 50, "type": null, "id": 1774189955451}]	26	10	3
674	V2730	49	2026-03-21 16:10:32.622885	PAID	4	[{"method": "EFECTIVO", "amount": 49, "displayAmount": 50, "type": null, "id": 1774135498529, "received": 50, "cambio": 1}]	23	24	20
1000	V5629	38	2026-03-22 15:12:52.85143	PAID	5	[{"method": "EFECTIVO", "amount": 38, "received": 50, "cambio": 12, "displayAmount": 50, "type": null, "id": 1774192394856}]	27	10	3
1001	V3932	46	2026-03-22 15:15:11.266362	PAID	5	[{"method": "EFECTIVO", "amount": 46, "displayAmount": 46, "type": null, "id": 1774364591712, "received": 46, "cambio": 0}]	29	17	20
1005	V1825	36	2026-03-22 15:19:11.369472	PAID	3	[{"method": "EFECTIVO", "amount": 36, "received": 36, "cambio": 0, "displayAmount": 36, "type": null, "id": 1774192780026}]	27	22	3
1008	V6819	23	2026-03-22 15:22:21.934003	PAID	6	[{"method": "EFECTIVO", "amount": 23, "received": 50, "cambio": 27, "displayAmount": 50, "type": null, "id": 1774192973740}]	27	1	3
1009	V5782	64	2026-03-22 15:22:54.004475	PAID	3	[{"method": "EFECTIVO", "amount": 64, "received": 100, "cambio": 36, "displayAmount": 100, "type": null, "id": 1774193016829}]	27	22	3
1011	V2857	56	2026-03-22 15:23:50.802868	PAID	3	[{"method": "EFECTIVO", "amount": 56, "received": 100, "cambio": 44, "displayAmount": 100, "type": null, "id": 1774193045530}]	27	22	3
102	V6244	49	2026-03-19 13:25:04.111805	PAID	5	[{"method": "EFECTIVO", "amount": 49, "received": 100, "cambio": 51, "displayAmount": 100, "type": null, "id": 1774193129161}]	27	1	3
1018	V4134	35	2026-03-22 15:28:53.956688	PAID	5	[{"method": "EFECTIVO", "amount": 35, "received": 35, "cambio": 0, "displayAmount": 35, "type": null, "id": 1774193370433}]	27	10	3
1023	V4055	67	2026-03-22 15:37:22.916654	PAID	4	[{"method": "EFECTIVO", "amount": 67, "received": 67, "cambio": 0, "displayAmount": 67, "type": null, "id": 1774227412319}]	27	28	3
72	V9267	211	2026-03-18 00:47:51.101498	PAID	6	[{"method": "EFECTIVO", "amount": 211, "received": 211, "cambio": 0, "displayAmount": 211, "type": null, "id": 1774193940701}]	27	22	3
1026	V4893	30	2026-03-22 15:41:04.159145	PAID	4	[{"method": "EFECTIVO", "amount": 30, "received": 50, "cambio": 20, "displayAmount": 50, "type": null, "id": 1774194094831}]	27	21	3
1027	V5402	184	2026-03-22 15:41:29.758434	PAID	3	[{"method": "EFECTIVO", "amount": 184, "received": 200, "cambio": 16, "displayAmount": 200, "type": null, "id": 1774194112398}]	27	22	3
1028	V2519	76	2026-03-22 15:42:00.775922	PAID	5	[{"method": "EFECTIVO", "amount": 76, "received": 500, "cambio": 424, "displayAmount": 500, "type": null, "id": 1774194141653}]	27	10	3
1031	V4306	66	2026-03-22 15:47:59.58374	PAID	3	[{"method": "EFECTIVO", "amount": 66, "received": 100, "cambio": 34, "displayAmount": 100, "type": null, "id": 1774194491418}]	27	22	3
1033	V7997	29	2026-03-22 15:49:33.115527	PAID	3	[{"method": "EFECTIVO", "amount": 29, "displayAmount": 50, "type": null, "id": 1774530486644, "received": 50, "cambio": 21}]	69	14	20
1022	V1770	87	2026-03-22 15:32:40.324161	PAID	3	[{"method": "EFECTIVO", "amount": 87, "displayAmount": 100, "type": null, "id": 1774408894439, "received": 100, "cambio": 13}]	30	8	3
643	V9290	95	2026-03-21 15:25:46.016396	PAID	5	[{"method": "EFECTIVO", "amount": 95, "displayAmount": 500, "type": null, "id": 1774106763796, "received": 500, "cambio": 405}]	23	9	20
649	V3306	32	2026-03-21 15:30:30.799397	PAID	4	[{"method": "EFECTIVO", "amount": 32, "displayAmount": 100, "type": null, "id": 1774107045336, "received": 100, "cambio": 68}]	23	10	20
650	V1754	77	2026-03-21 15:31:26.747126	PAID	3	[{"method": "EFECTIVO", "amount": 77, "displayAmount": 80, "type": null, "id": 1774627431952, "received": 80, "cambio": 3}]	71	15	20
651	V6270	62	2026-03-21 15:32:13.234546	PAID	4	[{"method": "EFECTIVO", "amount": 62, "displayAmount": 200, "type": null, "id": 1774107146155, "received": 200, "cambio": 138}]	23	10	20
652	V8530	41	2026-03-21 15:32:46.92536	PAID	3	[{"method": "EFECTIVO", "amount": 41, "displayAmount": 100, "type": null, "id": 1774107175275, "received": 100, "cambio": 59}]	23	22	20
654	V5267	102	2026-03-21 15:34:13.645534	PAID	3	[{"method": "EFECTIVO", "amount": 102, "received": 200, "cambio": 98, "displayAmount": 200, "type": null, "id": 1774490403525}]	35	24	3
659	V7739	71	2026-03-21 15:39:46.573914	PAID	3	[{"method": "EFECTIVO", "amount": 71, "displayAmount": 200, "type": null, "id": 1774107608826, "received": 200, "cambio": 129}]	23	10	20
660	V3170	107	2026-03-21 15:41:05.958745	PAID	5	[{"method": "EFECTIVO", "amount": 107, "displayAmount": 200, "type": null, "id": 1774107690073, "received": 200, "cambio": 93}]	23	9	20
661	V3209	39	2026-03-21 15:41:55.059666	PAID	3	[{"method": "EFECTIVO", "amount": 39, "displayAmount": 200, "type": null, "id": 1774107723384, "received": 200, "cambio": 161}]	23	10	20
662	V9644	65	2026-03-21 15:44:18.601627	PAID	3	[{"method": "EFECTIVO", "amount": 65, "displayAmount": 70, "type": null, "id": 1774107867643, "received": 70, "cambio": 5}]	23	10	20
664	V7185	88	2026-03-21 15:50:30.513971	PAID	3	[{"method": "EFECTIVO", "amount": 88, "displayAmount": 200, "type": null, "id": 1774108242259, "received": 200, "cambio": 112}]	23	20	20
667	V6213	35	2026-03-21 15:55:46.717462	PAID	3	[{"method": "TARJETA", "amount": 35, "displayAmount": 35, "type": "DEBITO", "id": 1774108572649}]	23	10	20
668	V1651	32	2026-03-21 15:56:35.848742	PAID	3	[{"method": "EFECTIVO", "amount": 32, "displayAmount": 32, "type": null, "id": 1774108602913, "received": 32, "cambio": 0}]	23	10	20
671	V2633	30	2026-03-21 16:04:52.090137	PAID	3	[{"method": "EFECTIVO", "amount": 30, "displayAmount": 100, "type": null, "id": 1774109101134, "received": 100, "cambio": 70}]	23	20	20
675	V9467	32	2026-03-21 16:10:58.499558	PAID	4	[{"method": "EFECTIVO", "amount": 32, "received": 32, "cambio": 0, "displayAmount": 32, "type": null, "id": 1774109475894}]	23	9	20
678	V3751	45	2026-03-21 16:12:54.165267	PAID	6	[{"method": "EFECTIVO", "amount": 45, "received": 100, "cambio": 55, "displayAmount": 100, "type": null, "id": 1774109637817}]	23	10	20
680	V3926	47	2026-03-21 16:15:05.528999	PAID	4	[{"method": "EFECTIVO", "amount": 47, "received": 50, "cambio": 3, "displayAmount": 50, "type": null, "id": 1774109726438}]	23	9	20
685	V7891	41	2026-03-21 16:26:33.979268	PAID	4	[{"method": "EFECTIVO", "amount": 41, "displayAmount": 41, "type": null, "id": 1774110436647, "received": 41, "cambio": 0}]	23	9	20
686	V7250	43	2026-03-21 16:33:27.905826	PAID	5	[{"method": "EFECTIVO", "amount": 43, "received": 43, "cambio": 0, "displayAmount": 43, "type": null, "id": 1774110941136}]	23	20	20
687	V5304	41	2026-03-21 16:36:57.746086	PAID	4	[{"method": "EFECTIVO", "amount": 41, "received": 100, "cambio": 59, "displayAmount": 100, "type": null, "id": 1774111044539}]	23	9	20
688	V6105	132	2026-03-21 16:39:58.642785	PAID	3	[{"method": "EFECTIVO", "amount": 132, "received": 140, "cambio": 8, "displayAmount": 140, "type": null, "id": 1774111229042}]	23	20	20
689	V5403	132	2026-03-21 16:41:39.030108	PAID	4	[{"method": "TARJETA", "amount": 132, "received": 132, "cambio": 0, "displayAmount": 132, "type": "DEBITO", "id": 1774111359923}]	23	9	20
695	V5886	139	2026-03-21 17:39:45.167356	PAID	3	[{"method": "EFECTIVO", "amount": 139, "received": 139, "cambio": 0, "displayAmount": 139, "type": null, "id": 1774213187707}]	27	21	3
633	V5711	23	2026-03-21 15:14:58.195181	PAID	5	[{"method": "EFECTIVO", "amount": 23, "received": 23, "cambio": 0, "displayAmount": 23, "type": null, "id": 1774111491972}]	23	22	20
656	V2714	65	2026-03-21 15:36:31.124538	PAID	4	[{"method": "EFECTIVO", "amount": 65, "received": 65, "cambio": 0, "displayAmount": 65, "type": null, "id": 1774111534985}]	23	10	20
691	V9964	31	2026-03-21 16:46:55.243297	PAID	3	[{"method": "EFECTIVO", "amount": 31, "received": 31, "cambio": 0, "displayAmount": 31, "type": null, "id": 1774111631243}]	23	20	20
690	V2007	32	2026-03-21 16:42:53.00818	PAID	3	[{"method": "EFECTIVO", "amount": 32, "received": 200, "cambio": 168, "displayAmount": 200, "type": null, "id": 1774111751832}]	23	20	20
692	V9981	59	2026-03-21 16:55:34.027847	PAID	3	[{"method": "EFECTIVO", "amount": 59, "displayAmount": 59, "type": null, "id": 1774374763799, "received": 59, "cambio": 0}]	29	16	20
693	V7780	32	2026-03-21 16:56:28.854665	PAID	3	[{"method": "EFECTIVO", "amount": 32, "received": 600, "cambio": 568, "displayAmount": 600, "type": null, "id": 1774112197676}]	23	20	20
694	V9495	60	2026-03-21 17:30:03.366758	PAID	3	[{"method": "EFECTIVO", "amount": 60, "received": 60, "cambio": 0, "displayAmount": 60, "type": null, "id": 1774316420228}]	28	8	20
696	V8794	20	2026-03-21 17:40:15.408064	PAID	4	[{"method": "EFECTIVO", "amount": 20, "received": 50, "cambio": 30, "displayAmount": 50, "type": null, "id": 1774114827874}]	23	9	20
697	V5006	30	2026-03-21 17:45:07.677945	PAID	4	[{"method": "EFECTIVO", "amount": 30, "received": 50, "cambio": 20, "displayAmount": 50, "type": null, "id": 1774115117668}]	23	9	20
698	V1782	47	2026-03-21 18:10:32.413001	PAID	3	[{"method": "EFECTIVO", "amount": 47, "displayAmount": 50, "type": null, "id": 1774143089250, "received": 50, "cambio": 3}]	23	24	20
699	V4275	52	2026-03-21 18:15:54.210211	PAID	3	[{"method": "EFECTIVO", "amount": 52, "received": 102, "cambio": 50, "displayAmount": 102, "type": null, "id": 1774116964418}]	23	20	20
700	V4188	54	2026-03-21 18:20:14.184522	PAID	2	[{"method": "EFECTIVO", "amount": 54, "received": 104, "cambio": 50, "displayAmount": 104, "type": null, "id": 1774117214766}]	23	20	\N
591	V7888	24	2026-03-21 14:42:37.23812	PAID	3	[{"method": "EFECTIVO", "amount": 24, "received": 24, "cambio": 0, "displayAmount": 24, "type": null, "id": 1774225007862}]	27	28	3
701	V8795	29	2026-03-21 18:27:03.554618	PAID	3	[{"method": "EFECTIVO", "amount": 29, "displayAmount": 29, "type": null, "id": 1774129020449, "received": 29, "cambio": 0}]	23	20	20
702	V5416	60	2026-03-21 18:33:09.848734	PAID	3	[{"method": "EFECTIVO", "amount": 60, "received": 200, "cambio": 140, "displayAmount": 200, "type": null, "id": 1774118000285}]	23	22	20
705	V6403	99	2026-03-21 18:55:55.19869	PAID	3	[{"method": "EFECTIVO", "amount": 99, "displayAmount": 200, "type": null, "id": 1774447881725, "received": 200, "cambio": 101}]	31	17	20
706	V7059	23	2026-03-21 19:39:56.928423	PAID	5	[{"method": "EFECTIVO", "amount": 23, "displayAmount": 100, "type": null, "id": 1774357186276, "received": 100, "cambio": 77}]	29	17	20
708	V4493	177	2026-03-21 19:42:00.337873	PAID	3	[{"method": "EFECTIVO", "amount": 177, "displayAmount": 200, "type": null, "id": 1774122155879, "received": 200, "cambio": 23}]	23	9	20
709	V2868	108	2026-03-21 19:55:43.691157	PAID	2	[{"method": "EFECTIVO", "amount": 108, "displayAmount": 200, "type": null, "id": 1774122942797, "received": 200, "cambio": 92}]	23	20	\N
710	V3759	99	2026-03-21 20:01:14.918611	PAID	4	[{"method": "EFECTIVO", "amount": 99, "received": 500, "cambio": 401, "displayAmount": 500, "type": null, "id": 1774123304885}]	23	9	20
711	V1908	202	2026-03-21 20:09:26.292759	PAID	4	[{"method": "EFECTIVO", "amount": 202, "displayAmount": 300, "type": null, "id": 1774123778285, "received": 300, "cambio": 98}]	23	9	20
725	V6299	50	2026-03-21 20:43:32.511344	PAID	6	[{"method": "EFECTIVO", "amount": 50, "displayAmount": 50, "type": null, "id": 1774125857800, "received": 50, "cambio": 0}]	23	24	20
728	V7333	50	2026-03-21 20:53:15.850118	PAID	6	[{"method": "EFECTIVO", "amount": 50, "displayAmount": 500, "type": null, "id": 1774126406297, "received": 500, "cambio": 450}]	23	27	20
731	V4439	128	2026-03-21 21:19:01.699531	PAID	2	[{"method": "EFECTIVO", "amount": 128, "displayAmount": 500, "type": null, "id": 1774127941424, "received": 500, "cambio": 372}]	23	20	\N
735	V6757	96	2026-03-21 21:29:12.331083	PAID	2	[{"method": "EFECTIVO", "amount": 96, "displayAmount": 100, "type": null, "id": 1774128549776, "received": 100, "cambio": 4}]	23	20	\N
717	V5917	224	2026-03-21 20:22:31.590952	PAID	4	[{"method": "EFECTIVO", "amount": 224, "displayAmount": 400, "type": null, "id": 1774128971636, "received": 400, "cambio": 176}]	23	25	20
721	V6071	47	2026-03-21 20:32:11.30157	PAID	4	[{"method": "EFECTIVO", "amount": 47, "received": 200, "cambio": 153, "displayAmount": 200, "type": null, "id": 1774317598410}]	28	24	20
718	V6450	130	2026-03-21 20:25:08.286626	PAID	6	[{"method": "EFECTIVO", "amount": 130, "displayAmount": 130, "type": null, "id": 1774129075940, "received": 130, "cambio": 0}]	23	9	20
719	V9112	848	2026-03-21 20:26:23.473704	PAID	4	[{"method": "EFECTIVO", "amount": 848, "displayAmount": 848, "type": null, "id": 1774129104132, "received": 848, "cambio": 0}]	23	26	20
737	V2339	214	2026-03-21 21:43:22.370107	PAID	3	[{"method": "EFECTIVO", "amount": 214, "displayAmount": 250, "type": null, "id": 1774129486430, "received": 250, "cambio": 36}]	23	27	20
976	V1090	32	2026-03-22 14:41:35.119905	PAID	6	[{"method": "EFECTIVO", "amount": 32, "received": 35, "cambio": 3, "displayAmount": 35, "type": null, "id": 1774192509723}]	27	21	3
953	V8409	12	2026-03-22 14:27:49.789755	PAID	6	[{"method": "EFECTIVO", "amount": 12, "received": 12, "cambio": 0, "displayAmount": 12, "type": null, "id": 1774192560306}]	27	3	3
987	V3186	91	2026-03-22 14:50:37.074671	PAID	5	[{"method": "EFECTIVO", "amount": 91, "received": 91, "cambio": 0, "displayAmount": 91, "type": null, "id": 1774192663643}]	27	10	3
1006	V7809	94	2026-03-22 15:20:02.365554	PAID	6	[{"method": "EFECTIVO", "amount": 94, "received": 94, "cambio": 0, "displayAmount": 94, "type": null, "id": 1774403510045}]	30	9	3
1007	V8192	124	2026-03-22 15:21:10.403932	PAID	5	[{"method": "EFECTIVO", "amount": 124, "displayAmount": 200, "type": null, "id": 1774639659502, "received": 200, "cambio": 76}]	71	20	20
1010	V1816	41	2026-03-22 15:22:54.595718	PAID	6	[{"method": "EFECTIVO", "amount": 41, "received": 41, "cambio": 0, "displayAmount": 41, "type": null, "id": 1774192996794}]	27	1	3
1012	V9986	74	2026-03-22 15:24:01.830581	PAID	5	[{"method": "EFECTIVO", "amount": 74, "received": 200, "cambio": 126, "displayAmount": 200, "type": null, "id": 1774193100303}]	27	10	3
1019	V2728	35	2026-03-22 15:29:54.710746	PAID	4	[{"method": "EFECTIVO", "amount": 35, "received": 35, "cambio": 0, "displayAmount": 35, "type": null, "id": 1774193435297}]	27	1	3
1020	V5839	29	2026-03-22 15:30:25.219609	PAID	5	[{"method": "EFECTIVO", "amount": 29, "received": 880, "cambio": 851, "displayAmount": 880, "type": null, "id": 1774193602539}]	27	10	3
1025	V2325	64	2026-03-22 15:39:36.543297	PAID	3	[{"method": "EFECTIVO", "amount": 64, "received": 64, "cambio": 0, "displayAmount": 64, "type": null, "id": 1774193990608}]	27	22	3
1024	V7704	26	2026-03-22 15:39:35.0413	PAID	5	[{"method": "EFECTIVO", "amount": 26, "received": 100, "cambio": 74, "displayAmount": 100, "type": null, "id": 1774194030184}]	27	10	3
1029	V5097	92	2026-03-22 15:44:01.667618	PAID	3	[{"method": "EFECTIVO", "amount": 92, "received": 100, "cambio": 8, "displayAmount": 100, "type": null, "id": 1774194254634}]	27	22	3
1032	V6361	30	2026-03-22 15:48:59.85355	PAID	4	[{"method": "EFECTIVO", "amount": 30, "received": 30, "cambio": 0, "displayAmount": 30, "type": null, "id": 1774194563475}]	27	21	3
1034	V5116	38	2026-03-22 15:50:30.395941	PAID	3	[{"method": "EFECTIVO", "amount": 38, "received": 200, "cambio": 162, "displayAmount": 200, "type": null, "id": 1774194644927}]	27	22	3
489	V5992	61	2026-03-21 13:04:46.12331	PAID	3	[{"method": "EFECTIVO", "amount": 61, "received": 100, "cambio": 39, "displayAmount": 100, "type": null, "id": 1774194807368}]	27	10	3
1200	V8884	84	2026-03-23 00:59:34.833437	PAID	4	[{"method": "EFECTIVO", "amount": 84, "received": 100, "cambio": 16, "displayAmount": 100, "type": null, "id": 1774227599745}]	27	28	3
2249	V4512	105	2026-03-26 02:39:04.410295	PAID	5	[{"method": "EFECTIVO", "amount": 105, "received": 205, "cambio": 100, "displayAmount": 205, "type": null, "id": 1774492759347}]	35	18	3
704	V2814	65	2026-03-21 18:48:08.585115	PAID	2	[{"method": "EFECTIVO", "amount": 65, "displayAmount": 100, "type": null, "id": 1774534567193, "received": 100, "cambio": 35}]	69	15	20
995	V4347	67	2026-03-22 15:03:46.387203	PAID	3	[{"method": "EFECTIVO", "amount": 67, "displayAmount": 67, "type": null, "id": 1774621718645, "received": 67, "cambio": 0}]	71	15	20
971	V4044	67	2026-03-22 14:36:50.101064	PAID	5	[{"method": "EFECTIVO", "amount": 67, "received": 100, "cambio": 33, "displayAmount": 100, "type": null, "id": 1774487123512}]	35	18	3
703	V4133	80	2026-03-21 18:44:36.407012	PAID	3	[{"method": "EFECTIVO", "amount": 80, "received": 200, "cambio": 120, "displayAmount": 200, "type": null, "id": 1774118695246}]	23	22	20
720	V3591	161	2026-03-21 20:30:19.076026	PAID	6	[{"method": "EFECTIVO", "amount": 161, "received": 500, "cambio": 339, "displayAmount": 500, "type": null, "id": 1774487574877}]	35	24	3
726	V2480	181	2026-03-21 20:47:04.020466	PAID	6	[{"method": "EFECTIVO", "amount": 181, "displayAmount": 200, "type": null, "id": 1774126036786, "received": 200, "cambio": 19}]	23	27	20
730	V3948	77	2026-03-21 21:15:21.503628	PAID	6	[{"method": "EFECTIVO", "amount": 77, "displayAmount": 100, "type": null, "id": 1774127744621, "received": 100, "cambio": 23}]	23	24	20
732	V3205	71	2026-03-21 21:25:19.586388	PAID	2	[{"method": "TARJETA", "amount": 71, "displayAmount": 71, "type": "DEBITO", "id": 1774128319912}]	23	20	\N
736	V8429	102	2026-03-21 21:33:36.927767	PAID	6	[{"method": "EFECTIVO", "amount": 102, "displayAmount": 500, "type": null, "id": 1774128844009, "received": 500, "cambio": 398}]	23	24	20
722	V8294	54	2026-03-21 20:32:39.29488	PAID	4	[{"method": "EFECTIVO", "amount": 54, "displayAmount": 54, "type": null, "id": 1774129039523, "received": 54, "cambio": 0}]	23	27	20
715	V2510	316	2026-03-21 20:18:42.597618	PAID	6	[{"method": "EFECTIVO", "amount": 316, "displayAmount": 316, "type": null, "id": 1774129054280, "received": 316, "cambio": 0}]	23	24	20
716	V3102	75	2026-03-21 20:21:08.056109	PAID	6	[{"method": "EFECTIVO", "amount": 75, "displayAmount": 75, "type": null, "id": 1774129065383, "received": 75, "cambio": 0}]	23	9	20
1002	V2034	38	2026-03-22 15:16:06.43877	PAID	6	[{"method": "EFECTIVO", "amount": 38, "received": 358, "cambio": 320, "displayAmount": 358, "type": null, "id": 1774192577720}]	27	1	3
988	V3238	53	2026-03-22 14:50:37.804905	PAID	4	[{"method": "EFECTIVO", "amount": 53, "received": 53, "cambio": 0, "displayAmount": 53, "type": null, "id": 1774192590134}]	27	23	3
986	V3580	181	2026-03-22 14:48:54.519768	PAID	4	[{"method": "EFECTIVO", "amount": 181, "received": 181, "cambio": 0, "displayAmount": 181, "type": null, "id": 1774192610757}]	27	23	3
977	V9231	53	2026-03-22 14:42:02.441	PAID	4	[{"method": "EFECTIVO", "amount": 53, "received": 100, "cambio": 47, "displayAmount": 100, "type": null, "id": 1774192623517}]	27	23	3
1013	V8352	35	2026-03-22 15:24:03.859212	PAID	6	[{"method": "EFECTIVO", "amount": 35, "displayAmount": 35, "type": null, "id": 1774374619488, "received": 35, "cambio": 0}]	29	16	20
1014	V9143	32	2026-03-22 15:24:56.500093	PAID	3	[{"method": "EFECTIVO", "amount": 32, "received": 500, "cambio": 468, "displayAmount": 500, "type": null, "id": 1774193154154}]	27	22	3
1016	V8537	121	2026-03-22 15:27:43.593895	PAID	5	[{"method": "EFECTIVO", "amount": 121, "received": 200, "cambio": 79, "displayAmount": 200, "type": null, "id": 1774577899078}]	70	4	1
1017	V1205	102	2026-03-22 15:28:18.923283	PAID	3	[{"method": "EFECTIVO", "amount": 102, "received": 102, "cambio": 0, "displayAmount": 102, "type": null, "id": 1774193342888}]	27	22	3
1004	V9957	54	2026-03-22 15:18:38.746999	PAID	5	[{"method": "EFECTIVO", "amount": 54, "displayAmount": 54, "type": null, "id": 1774536419823, "received": 54, "cambio": 0}]	69	14	20
1015	V6816	78	2026-03-22 15:26:45.672426	PAID	6	[{"method": "EFECTIVO", "amount": 78, "received": 78, "cambio": 0, "displayAmount": 78, "type": null, "id": 1774193607668}]	27	1	3
1030	V9313	40	2026-03-22 15:46:30.301072	PAID	3	[{"method": "EFECTIVO", "amount": 40, "received": 200, "cambio": 160, "displayAmount": 200, "type": null, "id": 1774194400645}]	27	22	3
1035	V3075	78	2026-03-22 15:52:48.42949	PAID	3	[{"method": "EFECTIVO", "amount": 78, "received": 100, "cambio": 22, "displayAmount": 100, "type": null, "id": 1774194782963}]	27	22	3
1036	V2901	60	2026-03-22 16:00:07.018522	PAID	3	[{"method": "EFECTIVO", "amount": 60, "received": 500, "cambio": 440, "displayAmount": 500, "type": null, "id": 1774195216144}]	27	22	3
1039	V9018	56	2026-03-22 16:05:27.258581	PAID	3	[{"method": "EFECTIVO", "amount": 56, "received": 70, "cambio": 14, "displayAmount": 70, "type": null, "id": 1774195535439}]	27	22	3
1042	V8165	22	2026-03-22 16:07:22.120398	PAID	3	[{"method": "EFECTIVO", "amount": 22, "received": 200, "cambio": 178, "displayAmount": 200, "type": null, "id": 1774195664428}]	27	22	3
1047	V7479	25	2026-03-22 16:12:23.030546	PAID	3	[{"method": "EFECTIVO", "amount": 25, "received": 25, "cambio": 0, "displayAmount": 25, "type": null, "id": 1774195952516}]	27	22	3
1049	V1755	56	2026-03-22 16:19:11.986574	PAID	5	[{"method": "EFECTIVO", "amount": 56, "received": 56, "cambio": 0, "displayAmount": 56, "type": null, "id": 1774196592454}]	27	23	3
1051	V5549	23	2026-03-22 16:29:23.142688	PAID	4	[{"method": "EFECTIVO", "amount": 23, "received": 23, "cambio": 0, "displayAmount": 23, "type": null, "id": 1774196998479}]	27	23	3
1202	V4371	46	2026-03-23 01:01:22.837015	PAID	4	[{"method": "EFECTIVO", "amount": 46, "received": 46, "cambio": 0, "displayAmount": 46, "type": null, "id": 1774227728800}]	27	28	3
1045	V1936	85	2026-03-22 16:11:28.498338	PAID	3	[{"method": "EFECTIVO", "amount": 85, "received": 100, "cambio": 15, "displayAmount": 100, "type": null, "id": 1774203618302}]	27	22	3
1201	V7400	72	2026-03-23 01:00:29.828186	PAID	5	[{"method": "EFECTIVO", "amount": 72, "received": 200, "cambio": 128, "displayAmount": 200, "type": null, "id": 1774227651792}]	27	25	3
1204	V3729	32	2026-03-23 01:01:49.26204	PAID	1	[{"method": "EFECTIVO", "amount": 32, "received": 32, "cambio": 0, "displayAmount": 32, "type": null, "id": 1774227757248}]	27	26	3
1205	V9410	32	2026-03-23 01:02:29.042779	PAID	4	[{"method": "EFECTIVO", "amount": 32, "received": 32, "cambio": 0, "displayAmount": 32, "type": null, "id": 1774227779342}]	27	28	3
1206	V5251	92	2026-03-23 01:02:44.066805	PAID	5	[{"method": "EFECTIVO", "amount": 92, "received": 92, "cambio": 0, "displayAmount": 92, "type": null, "id": 1774227787411}]	27	25	3
1209	V1889	62	2026-03-23 01:04:23.54532	PAID	3	[{"method": "EFECTIVO", "amount": 62, "received": 62, "cambio": 0, "displayAmount": 62, "type": null, "id": 1774227980786}]	27	33	3
1211	V8208	17	2026-03-23 01:05:00.606538	PAID	4	[{"method": "EFECTIVO", "amount": 17, "received": 17, "cambio": 0, "displayAmount": 17, "type": null, "id": 1774228019861}]	27	28	3
734	V8892	133	2026-03-21 21:27:46.333965	PAID	2	[{"method": "EFECTIVO", "amount": 133, "received": 133, "cambio": 0, "displayAmount": 133, "type": null, "id": 1774228154429}]	27	25	3
1021	V9855	49	2026-03-22 15:32:24.259642	PAID	5	[{"method": "EFECTIVO", "amount": 49, "displayAmount": 49, "type": null, "id": 1774536458312, "received": 49, "cambio": 0}]	69	17	20
707	V1784	62	2026-03-21 19:41:45.514892	PAID	5	[{"method": "EFECTIVO", "amount": 62, "displayAmount": 500, "type": null, "id": 1774122116662, "received": 500, "cambio": 438}]	23	20	20
723	V8517	148	2026-03-21 20:35:04.477866	PAID	6	[{"method": "EFECTIVO", "amount": 148, "received": 148, "cambio": 0, "displayAmount": 148, "type": null, "id": 1774487851807}]	35	18	3
724	V9240	112	2026-03-21 20:43:26.809111	PAID	4	[{"method": "TARJETA", "amount": 112, "displayAmount": 112, "type": "DEBITO", "id": 1774125816866}]	23	20	20
727	V1045	142	2026-03-21 20:52:31.882008	PAID	6	[{"method": "EFECTIVO", "amount": 142, "displayAmount": 200, "type": null, "id": 1774126363562, "received": 200, "cambio": 58}]	23	27	20
729	V4568	60	2026-03-21 20:53:26.134678	PAID	5	[{"method": "TARJETA", "amount": 60, "displayAmount": 60, "type": "DEBITO", "id": 1774126512921}]	23	24	20
733	V5069	180	2026-03-21 21:26:42.122605	PAID	2	[{"method": "EFECTIVO", "amount": 180, "displayAmount": 500, "type": null, "id": 1774128392452, "received": 500, "cambio": 320}]	23	20	\N
713	V5148	38	2026-03-21 20:15:09.604327	PAID	5	[{"method": "EFECTIVO", "amount": 38, "displayAmount": 38, "type": null, "id": 1774128985820, "received": 38, "cambio": 0}]	23	20	20
714	V6877	32	2026-03-21 20:18:03.399122	PAID	6	[{"method": "EFECTIVO", "amount": 32, "displayAmount": 32, "type": null, "id": 1774129085185, "received": 32, "cambio": 0}]	23	24	20
739	V9052	34	2026-03-21 21:51:59.634773	PAID	5	[{"method": "EFECTIVO", "amount": 34, "received": 34, "cambio": 0, "displayAmount": 34, "type": null, "id": 1774317686273}]	28	9	20
740	V1474	132	2026-03-21 21:52:55.863195	PAID	3	[{"method": "EFECTIVO", "amount": 132, "received": 200, "cambio": 68, "displayAmount": 200, "type": null, "id": 1774309035649}]	28	18	20
741	V7825	94	2026-03-21 21:57:30.18104	PAID	5	[{"method": "EFECTIVO", "amount": 94, "received": 100, "cambio": 6, "displayAmount": 100, "type": null, "id": 1774385902240}]	29	8	20
742	V1119	127	2026-03-21 21:59:22.665386	PAID	4	[{"method": "EFECTIVO", "amount": 127, "received": 200, "cambio": 73, "displayAmount": 200, "type": null, "id": 1774313719251}]	28	4	20
743	V3028	52	2026-03-21 22:02:15.193371	PAID	3	[{"method": "EFECTIVO", "amount": 52, "displayAmount": 100, "type": null, "id": 1774130544555, "received": 100, "cambio": 48}]	23	13	20
744	V6153	58	2026-03-21 22:03:40.568593	PAID	4	[{"method": "EFECTIVO", "amount": 58, "displayAmount": 100, "type": null, "id": 1774130694089, "received": 100, "cambio": 42}]	23	27	20
746	V6778	77	2026-03-21 22:14:50.990154	PAID	5	[{"method": "EFECTIVO", "amount": 77, "displayAmount": 200, "type": null, "id": 1774131302952, "received": 200, "cambio": 123}]	23	20	20
747	V7473	417	2026-03-21 22:16:50.159801	PAID	3	[{"method": "EFECTIVO", "amount": 417, "displayAmount": 500, "type": null, "id": 1774131481661, "received": 500, "cambio": 83}]	23	13	20
748	V5581	65	2026-03-21 22:19:02.777325	PAID	2	[{"method": "EFECTIVO", "amount": 65, "displayAmount": 100, "type": null, "id": 1774131536915, "received": 100, "cambio": 35}]	23	20	\N
752	V9064	61	2026-03-21 22:25:25.477395	PAID	4	[{"method": "EFECTIVO", "amount": 61, "received": 300, "cambio": 239, "displayAmount": 300, "type": null, "id": 1774575223005}]	70	4	1
750	V1554	117	2026-03-21 22:22:55.954178	PAID	5	[{"method": "EFECTIVO", "amount": 117, "displayAmount": 117, "type": null, "id": 1774132461128, "received": 117, "cambio": 0}]	23	13	20
754	V3154	34	2026-03-21 22:32:43.67546	PAID	5	[{"method": "EFECTIVO", "amount": 34, "received": 34, "cambio": 0, "displayAmount": 34, "type": null, "id": 1774132521022}]	23	13	20
753	V3897	260	2026-03-21 22:31:00.029118	PAID	3	[{"method": "EFECTIVO", "amount": 260, "received": 260, "cambio": 0, "displayAmount": 260, "type": null, "id": 1774132531952}]	23	13	20
749	V8949	37	2026-03-21 22:19:56.874419	PAID	3	[{"method": "EFECTIVO", "amount": 37, "displayAmount": 37, "type": null, "id": 1774132545808, "received": 37, "cambio": 0}]	23	24	20
745	V3069	30	2026-03-21 22:06:43.915988	PAID	3	[{"method": "EFECTIVO", "amount": 30, "displayAmount": 30, "type": null, "id": 1774132563010, "received": 30, "cambio": 0}]	23	13	20
755	V6227	149	2026-03-21 22:36:33.476569	PAID	2	[{"method": "EFECTIVO", "amount": 149, "displayAmount": 200, "type": null, "id": 1774132592796, "received": 200, "cambio": 51}]	23	20	\N
756	V2243	90	2026-03-21 22:36:54.424055	PAID	3	[{"method": "EFECTIVO", "amount": 90, "displayAmount": 100, "type": null, "id": 1774132635506, "received": 100, "cambio": 10}]	23	13	20
758	V8953	18	2026-03-21 22:46:51.664459	PAID	2	[{"method": "EFECTIVO", "amount": 18, "displayAmount": 100, "type": null, "id": 1774133202489, "received": 100, "cambio": 82}]	23	20	\N
759	V8258	127	2026-03-21 22:50:26.032953	PAID	5	[{"method": "EFECTIVO", "amount": 127, "received": 127, "cambio": 0, "displayAmount": 127, "type": null, "id": 1774233539321}]	27	33	3
760	V4051	34	2026-03-21 22:52:59.964823	PAID	2	[{"method": "EFECTIVO", "amount": 34, "displayAmount": 200, "type": null, "id": 1774133516613, "received": 200, "cambio": 166}]	23	20	\N
761	V6292	120	2026-03-21 23:00:30.873767	PAID	3	[{"method": "EFECTIVO", "amount": 120, "displayAmount": 120, "type": null, "id": 1774134052499, "received": 120, "cambio": 0}]	23	13	20
762	V3712	65	2026-03-21 23:02:23.29084	PAID	3	[{"method": "EFECTIVO", "amount": 65, "displayAmount": 100, "type": null, "id": 1774134169669, "received": 100, "cambio": 35}]	23	13	20
763	V4445	256	2026-03-21 23:05:09.419188	PAID	3	[{"method": "EFECTIVO", "amount": 256, "displayAmount": 256, "type": null, "id": 1774134327742, "received": 256, "cambio": 0}]	23	13	20
764	V7168	78	2026-03-21 23:05:36.124132	PAID	5	[{"method": "EFECTIVO", "amount": 78, "displayAmount": 100, "type": null, "id": 1774134346267, "received": 100, "cambio": 22}]	23	20	20
765	V4920	115	2026-03-21 23:06:25.214494	PAID	4	[{"method": "EFECTIVO", "amount": 115, "displayAmount": 115, "type": null, "id": 1774134398511, "received": 115, "cambio": 0}]	23	27	20
766	V5463	39	2026-03-21 23:07:18.762807	PAID	6	[{"method": "EFECTIVO", "amount": 39, "received": 200, "cambio": 161, "displayAmount": 200, "type": null, "id": 1774574273678}]	70	13	1
751	V6802	28	2026-03-21 22:23:39.916752	PAID	2	[{"method": "EFECTIVO", "amount": 28, "displayAmount": 28, "type": null, "id": 1774448619451, "received": 28, "cambio": 0}]	31	16	20
738	V6245	69	2026-03-21 21:47:17.10266	PAID	2	[{"method": "EFECTIVO", "amount": 69, "received": 100, "cambio": 31, "displayAmount": 100, "type": null, "id": 1774479350271}]	35	18	3
757	V9394	29	2026-03-21 22:38:14.697773	PAID	3	[{"method": "EFECTIVO", "amount": 29, "received": 999, "cambio": 970, "displayAmount": 999, "type": null, "id": 1774148819119}]	23	13	20
769	V9259	74	2026-03-21 23:16:22.725981	PAID	5	[{"method": "EFECTIVO", "amount": 74, "displayAmount": 500, "type": null, "id": 1774135001969, "received": 500, "cambio": 426}]	23	20	20
771	V1836	60	2026-03-21 23:19:58.796788	PAID	5	[{"method": "EFECTIVO", "amount": 60, "displayAmount": 100, "type": null, "id": 1774135206472, "received": 100, "cambio": 40}]	23	13	20
772	V8873	91	2026-03-21 23:26:20.464707	PAID	4	[{"method": "EFECTIVO", "amount": 91, "displayAmount": 200, "type": null, "id": 1774135620619, "received": 200, "cambio": 109}]	23	25	20
773	V8330	56	2026-03-21 23:29:42.9621	PAID	4	[{"method": "EFECTIVO", "amount": 56, "displayAmount": 200, "type": null, "id": 1774135808625, "received": 200, "cambio": 144}]	23	25	20
776	V6127	82	2026-03-21 23:32:30.134862	PAID	3	[{"method": "EFECTIVO", "amount": 82, "displayAmount": 100, "type": null, "id": 1774135961128, "received": 100, "cambio": 18}]	23	13	20
777	V9446	205	2026-03-21 23:36:14.333213	PAID	4	[{"method": "EFECTIVO", "amount": 205, "displayAmount": 210, "type": null, "id": 1774136221562, "received": 210, "cambio": 5}]	23	25	20
778	V1123	99	2026-03-21 23:38:08.287415	PAID	2	[{"method": "EFECTIVO", "amount": 99, "displayAmount": 100, "type": null, "id": 1774136287120, "received": 100, "cambio": 1}]	23	20	\N
779	V3970	77	2026-03-21 23:38:22.066069	PAID	1	[{"method": "EFECTIVO", "amount": 77, "displayAmount": 200, "type": null, "id": 1774136324191, "received": 200, "cambio": 123}]	23	24	20
782	V1332	113	2026-03-21 23:42:44.702845	PAID	6	[{"method": "EFECTIVO", "amount": 113, "received": 113, "cambio": 0, "displayAmount": 113, "type": null, "id": 1774136591590}]	23	26	20
784	V4889	66	2026-03-21 23:46:26.063014	PAID	3	[{"method": "EFECTIVO", "amount": 66, "displayAmount": 100, "type": null, "id": 1774136798064, "received": 100, "cambio": 34}]	23	13	20
785	V1549	54	2026-03-21 23:47:09.954588	PAID	4	[{"method": "EFECTIVO", "amount": 54, "displayAmount": 55, "type": null, "id": 1774136856623, "received": 55, "cambio": 1}]	23	25	20
786	V6714	92	2026-03-21 23:51:17.997937	PAID	3	[{"method": "EFECTIVO", "amount": 92, "displayAmount": 100, "type": null, "id": 1774137092425, "received": 100, "cambio": 8}]	23	13	20
791	V5246	89	2026-03-22 00:00:19.85799	PAID	5	[{"method": "EFECTIVO", "amount": 89, "displayAmount": 90, "type": null, "id": 1774137677294, "received": 90, "cambio": 1}]	23	27	20
793	V4895	107	2026-03-22 00:03:25.102636	PAID	3	[{"method": "EFECTIVO", "amount": 107, "displayAmount": 107, "type": null, "id": 1774137837620, "received": 107, "cambio": 0}]	23	25	20
790	V6426	32	2026-03-21 23:56:40.270285	PAID	3	[{"method": "EFECTIVO", "amount": 32, "received": 966, "cambio": 934, "displayAmount": 966, "type": null, "id": 1774148812636}]	23	13	20
1037	V4589	54	2026-03-22 16:00:50.125295	PAID	4	[{"method": "EFECTIVO", "amount": 54, "received": 54, "cambio": 0, "displayAmount": 54, "type": null, "id": 1774195290304}]	27	21	3
1038	V6515	70	2026-03-22 16:01:33.932267	PAID	3	[{"method": "EFECTIVO", "amount": 70, "received": 70, "cambio": 0, "displayAmount": 70, "type": null, "id": 1774195309322}]	27	22	3
1040	V6702	46	2026-03-22 16:05:59.221847	PAID	5	[{"method": "EFECTIVO", "amount": 46, "received": 46, "cambio": 0, "displayAmount": 46, "type": null, "id": 1774195582510}]	27	10	3
1041	V3040	30	2026-03-22 16:06:45.399285	PAID	3	[{"method": "EFECTIVO", "amount": 30, "received": 30, "cambio": 0, "displayAmount": 30, "type": null, "id": 1774195616362}]	27	22	3
1043	V1452	53	2026-03-22 16:07:31.817189	PAID	5	[{"method": "EFECTIVO", "amount": 53, "received": 100, "cambio": 47, "displayAmount": 100, "type": null, "id": 1774195673268}]	27	10	3
1044	V4916	126	2026-03-22 16:10:15.000666	PAID	3	[{"method": "EFECTIVO", "amount": 126, "received": 200, "cambio": 74, "displayAmount": 200, "type": null, "id": 1774195823018}]	27	22	3
1046	V2923	34	2026-03-22 16:11:58.080588	PAID	5	[{"method": "EFECTIVO", "amount": 34, "displayAmount": 34, "type": null, "id": 1774278031254, "received": 34, "cambio": 0}]	28	20	20
1048	V2397	52	2026-03-22 16:13:22.802544	PAID	5	[{"method": "EFECTIVO", "amount": 52, "received": 100, "cambio": 48, "displayAmount": 100, "type": null, "id": 1774196017046}]	27	23	3
1050	V2821	8	2026-03-22 16:26:05.799743	PAID	2	[{"method": "EFECTIVO", "amount": 8, "received": 8, "cambio": 0, "displayAmount": 8, "type": null, "id": 1774196766730}]	27	3	\N
1203	V4715	30	2026-03-23 01:01:29.279113	PAID	5	[{"method": "EFECTIVO", "amount": 30, "received": 30, "cambio": 0, "displayAmount": 30, "type": null, "id": 1774227719542}]	27	25	3
1207	V6548	85	2026-03-23 01:04:15.505848	PAID	1	[{"method": "EFECTIVO", "amount": 85, "received": 85, "cambio": 0, "displayAmount": 85, "type": null, "id": 1774227926000}]	27	26	3
1212	V3414	267	2026-03-23 01:06:32.614797	PAID	1	[{"method": "EFECTIVO", "amount": 267, "received": 400, "cambio": 133, "displayAmount": 400, "type": null, "id": 1774228073213}]	27	26	3
1210	V1281	47	2026-03-23 01:04:31.502103	PAID	4	[{"method": "EFECTIVO", "amount": 47, "received": 47, "cambio": 0, "displayAmount": 47, "type": null, "id": 1774228176123}]	27	28	3
1226	V7552	46	2026-03-23 01:26:39.964767	PAID	6	[{"method": "EFECTIVO", "amount": 46, "received": 100, "cambio": 54, "displayAmount": 100, "type": null, "id": 1774229275606}]	27	25	3
1223	V4180	64	2026-03-23 01:24:53.783229	PAID	1	[{"method": "EFECTIVO", "amount": 64, "received": 100, "cambio": 36, "displayAmount": 100, "type": null, "id": 1774229158650}]	27	28	3
1225	V4790	26	2026-03-23 01:26:00.591033	PAID	3	[{"method": "EFECTIVO", "amount": 26, "received": 30, "cambio": 4, "displayAmount": 30, "type": null, "id": 1774490117009}]	35	8	3
1227	V8123	23	2026-03-23 01:26:47.551115	PAID	1	[{"method": "EFECTIVO", "amount": 23, "received": 500, "cambio": 477, "displayAmount": 500, "type": null, "id": 1774229304484}]	27	28	3
1230	V1849	125	2026-03-23 01:29:16.460218	PAID	6	[{"method": "EFECTIVO", "amount": 125, "received": 200, "cambio": 75, "displayAmount": 200, "type": null, "id": 1774229413291}]	27	25	3
1233	V9266	17	2026-03-23 01:31:01.041685	PAID	3	[{"method": "EFECTIVO", "amount": 17, "received": 17, "cambio": 0, "displayAmount": 17, "type": null, "id": 1774229599406}]	27	33	3
1240	V4970	23	2026-03-23 01:38:59.050441	PAID	5	[{"method": "EFECTIVO", "amount": 23, "received": 23, "cambio": 0, "displayAmount": 23, "type": null, "id": 1774231485760}]	27	28	3
774	V7208	79	2026-03-21 23:30:25.154945	PAID	5	[{"method": "EFECTIVO", "amount": 79, "received": 100, "cambio": 21, "displayAmount": 100, "type": null, "id": 1774306354467}]	28	4	20
767	V2907	63	2026-03-21 23:10:41.631993	PAID	3	[{"method": "EFECTIVO", "amount": 63, "received": 100, "cambio": 37, "displayAmount": 100, "type": null, "id": 1774487632186}]	35	24	3
770	V2188	55	2026-03-21 23:18:39.563814	PAID	3	[{"method": "EFECTIVO", "amount": 55, "displayAmount": 100, "type": null, "id": 1774135127209, "received": 100, "cambio": 45}]	23	13	20
775	V1650	70	2026-03-21 23:31:15.400217	PAID	1	[{"method": "EFECTIVO", "amount": 70, "received": 70, "cambio": 0, "displayAmount": 70, "type": null, "id": 1774228118959}]	27	33	3
780	V9463	126	2026-03-21 23:40:01.149624	PAID	6	[{"method": "EFECTIVO", "amount": 126, "displayAmount": 140, "type": null, "id": 1774136467082, "received": 140, "cambio": 14}]	23	26	20
781	V7838	32	2026-03-21 23:42:30.700312	PAID	1	[{"method": "EFECTIVO", "amount": 32, "displayAmount": 32, "type": null, "id": 1774136564315, "received": 32, "cambio": 0}]	23	24	20
783	V4664	120	2026-03-21 23:45:39.442731	PAID	2	[{"method": "EFECTIVO", "amount": 120, "displayAmount": 120, "type": null, "id": 1774136735789, "received": 120, "cambio": 0}]	23	20	\N
787	V9820	26	2026-03-21 23:52:30.967415	PAID	3	[{"method": "EFECTIVO", "amount": 26, "received": 50, "cambio": 24, "displayAmount": 50, "type": null, "id": 1774488809278}]	35	24	3
788	V4285	115	2026-03-21 23:55:06.523755	PAID	3	[{"method": "EFECTIVO", "amount": 115, "displayAmount": 220, "type": null, "id": 1774137328044, "received": 220, "cambio": 105}]	23	13	20
796	V9939	18	2026-03-22 00:06:16.227252	PAID	2	[{"method": "EFECTIVO", "amount": 18, "displayAmount": 18, "type": null, "id": 1774137975567, "received": 18, "cambio": 0}]	23	20	\N
795	V9466	151	2026-03-22 00:05:51.919551	PAID	5	[{"method": "EFECTIVO", "amount": 151, "displayAmount": 201, "type": null, "id": 1774137996787, "received": 201, "cambio": 50}]	23	27	20
798	V2774	202	2026-03-22 00:07:07.48566	PAID	3	[{"method": "EFECTIVO", "amount": 202, "displayAmount": 502, "type": null, "id": 1774138056816, "received": 502, "cambio": 300}]	23	25	20
1052	V2032	49	2026-03-22 16:30:22.418255	PAID	3	[{"method": "EFECTIVO", "amount": 49, "received": 49, "cambio": 0, "displayAmount": 49, "type": null, "id": 1774197035267}]	27	22	3
1056	V8225	58	2026-03-22 16:35:35.149271	PAID	3	[{"method": "EFECTIVO", "amount": 58, "displayAmount": 70, "type": null, "id": 1774358720314, "received": 70, "cambio": 12}]	29	17	20
1055	V6286	32	2026-03-22 16:32:46.410549	PAID	3	[{"method": "EFECTIVO", "amount": 32, "received": 32, "cambio": 0, "displayAmount": 32, "type": null, "id": 1774197371099}]	27	22	3
1058	V1693	69	2026-03-22 16:39:58.517491	PAID	2	[{"method": "EFECTIVO", "amount": 69, "received": 200, "cambio": 131, "displayAmount": 200, "type": null, "id": 1774197599395}]	27	3	\N
1062	V3590	249	2026-03-22 17:06:57.138166	PAID	3	[{"method": "EFECTIVO", "amount": 249, "received": 249, "cambio": 0, "displayAmount": 249, "type": null, "id": 1774199231630}]	27	21	3
1066	V3066	162	2026-03-22 17:51:20.813607	PAID	2	[{"method": "EFECTIVO", "amount": 162, "received": 200, "cambio": 38, "displayAmount": 200, "type": null, "id": 1774201882202}]	27	3	\N
2250	V2476	108	2026-03-26 02:40:41.517038	PAID	3	[{"method": "EFECTIVO", "amount": 108, "received": 108, "cambio": 0, "displayAmount": 108, "type": null, "id": 1774492853811}]	35	24	3
1071	V8481	346	2026-03-22 18:25:56.443994	PAID	2	[{"method": "EFECTIVO", "amount": 346, "received": 400, "cambio": 54, "displayAmount": 400, "type": null, "id": 1774203957339}]	27	3	\N
1076	V6663	130	2026-03-22 18:57:06.327411	PAID	3	[{"method": "EFECTIVO", "amount": 130, "received": 200, "cambio": 70, "displayAmount": 200, "type": null, "id": 1774205836571}]	27	10	3
1077	V2102	162	2026-03-22 19:04:57.337345	PAID	5	[{"method": "EFECTIVO", "amount": 162, "received": 200, "cambio": 38, "displayAmount": 200, "type": null, "id": 1774402644895}]	30	4	3
1079	V9728	203	2026-03-22 19:22:05.232679	PAID	2	[{"method": "EFECTIVO", "amount": 203, "received": 203, "cambio": 0, "displayAmount": 203, "type": null, "id": 1774207325993}]	27	3	\N
1084	V4182	402	2026-03-22 19:45:48.243589	PAID	2	[{"method": "EFECTIVO", "amount": 402, "received": 402, "cambio": 0, "displayAmount": 402, "type": null, "id": 1774208749952}]	27	3	\N
1087	V7173	116	2026-03-22 20:00:02.789354	PAID	2	[{"method": "EFECTIVO", "amount": 116, "received": 200, "cambio": 84, "displayAmount": 200, "type": null, "id": 1774209603903}]	27	3	\N
1097	V8122	183	2026-03-22 20:31:15.376484	PAID	5	[{"method": "EFECTIVO", "amount": 183, "received": 500, "cambio": 317, "displayAmount": 500, "type": null, "id": 1774211497500}]	27	25	3
999	V2131	136	2026-03-22 15:05:22.353674	PAID	6	[{"method": "EFECTIVO", "amount": 136, "received": 136, "cambio": 0, "displayAmount": 136, "type": null, "id": 1774213894312}]	27	21	3
1110	V9951	118	2026-03-22 21:39:13.799212	PAID	5	[{"method": "EFECTIVO", "amount": 118, "received": 518, "cambio": 400, "displayAmount": 518, "type": null, "id": 1774215574425}]	27	21	3
1111	V9749	137	2026-03-22 21:43:51.59973	PAID	6	[{"method": "EFECTIVO", "amount": 137, "received": 137, "cambio": 0, "displayAmount": 137, "type": null, "id": 1774215854241}]	27	25	3
1112	V1026	152	2026-03-22 21:45:26.019993	PAID	5	[{"method": "EFECTIVO", "amount": 152, "received": 152, "cambio": 0, "displayAmount": 152, "type": null, "id": 1774215936938}]	27	28	3
1115	V8784	73	2026-03-22 22:01:34.796046	PAID	5	[{"method": "EFECTIVO", "amount": 73, "received": 200, "cambio": 127, "displayAmount": 200, "type": null, "id": 1774216928213}]	27	28	3
1116	V3935	68	2026-03-22 22:06:03.968111	PAID	4	[{"method": "EFECTIVO", "amount": 68, "received": 200, "cambio": 132, "displayAmount": 200, "type": null, "id": 1774217228266}]	27	28	3
1120	V7358	50	2026-03-22 22:09:06.615987	PAID	3	[{"method": "EFECTIVO", "amount": 50, "received": 50, "cambio": 0, "displayAmount": 50, "type": null, "id": 1774217371743}]	27	28	3
1121	V3103	54	2026-03-22 22:10:29.106855	PAID	5	[{"method": "EFECTIVO", "amount": 54, "received": 54, "cambio": 0, "displayAmount": 54, "type": null, "id": 1774217464135}]	27	29	3
1125	V5716	60	2026-03-22 22:22:08.199058	PAID	3	[{"method": "EFECTIVO", "amount": 60, "received": 60, "cambio": 0, "displayAmount": 60, "type": null, "id": 1774219116237}]	27	29	3
1208	V6226	78	2026-03-23 01:04:18.516879	PAID	5	[{"method": "EFECTIVO", "amount": 78, "received": 78, "cambio": 0, "displayAmount": 78, "type": null, "id": 1774227887943}]	27	25	3
1069	V8830	81	2026-03-22 18:17:39.970836	PAID	3	[{"method": "EFECTIVO", "amount": 81, "displayAmount": 81, "type": null, "id": 1774465137145, "received": 81, "cambio": 0}]	31	20	20
1216	V3231	69	2026-03-23 01:16:47.99471	PAID	4	[{"method": "EFECTIVO", "amount": 69, "received": 500, "cambio": 431, "displayAmount": 500, "type": null, "id": 1774228634024}]	27	28	3
768	V4584	102	2026-03-21 23:14:21.122665	PAID	3	[{"method": "EFECTIVO", "amount": 102, "received": 200, "cambio": 98, "displayAmount": 200, "type": null, "id": 1774305510638}]	28	4	20
789	V2442	108	2026-03-21 23:55:42.124097	PAID	3	[{"method": "EFECTIVO", "amount": 108, "displayAmount": 500, "type": null, "id": 1774137354637, "received": 500, "cambio": 392}]	23	13	20
55	V6707	133	2026-03-17 22:31:16.053024	PAID	6	[{"method": "EFECTIVO", "amount": 133, "received": 150, "cambio": 17, "displayAmount": 150, "type": null, "id": 1774490576996}]	35	24	3
792	V6941	86	2026-03-22 00:02:51.695665	PAID	3	[{"method": "EFECTIVO", "amount": 86, "received": 86, "cambio": 0, "displayAmount": 86, "type": null, "id": 1774303705371}]	28	9	20
794	V7279	45	2026-03-22 00:03:31.711934	PAID	1	[{"method": "EFECTIVO", "amount": 45, "displayAmount": 45, "type": null, "id": 1774137854680, "received": 45, "cambio": 0}]	23	26	20
797	V1846	44	2026-03-22 00:06:24.993306	PAID	1	[{"method": "EFECTIVO", "amount": 44, "displayAmount": 44, "type": null, "id": 1774297655351, "received": 44, "cambio": 0}]	28	17	20
799	V9858	222	2026-03-22 00:08:11.20182	PAID	4	[{"method": "EFECTIVO", "amount": 222, "displayAmount": 300, "type": null, "id": 1774138108509, "received": 300, "cambio": 78}]	23	13	20
800	V4132	102	2026-03-22 00:08:59.408897	PAID	5	[{"method": "TARJETA", "amount": 102, "displayAmount": 102, "type": "DEBITO", "id": 1774361033515}]	29	16	20
801	V1386	36	2026-03-22 00:10:09.851179	PAID	2	[{"method": "EFECTIVO", "amount": 36, "displayAmount": 50, "type": null, "id": 1774138209146, "received": 50, "cambio": 14}]	23	20	\N
803	V6520	65	2026-03-22 00:14:04.416706	PAID	3	[{"method": "EFECTIVO", "amount": 65, "displayAmount": 100, "type": null, "id": 1774138456447, "received": 100, "cambio": 35}]	23	13	20
804	V1796	97	2026-03-22 00:14:40.363507	PAID	5	[{"method": "EFECTIVO", "amount": 97, "displayAmount": 97, "type": null, "id": 1774374393498, "received": 97, "cambio": 0}]	29	20	20
805	V4981	25	2026-03-22 00:15:27.6219	PAID	5	[{"method": "EFECTIVO", "amount": 25, "displayAmount": 25, "type": null, "id": 1774138555399, "received": 25, "cambio": 0}]	23	27	20
806	V8051	123	2026-03-22 00:17:48.902429	PAID	5	[{"method": "EFECTIVO", "amount": 123, "displayAmount": 123, "type": null, "id": 1774138715564, "received": 123, "cambio": 0}]	23	27	20
807	V8106	134	2026-03-22 00:21:37.981092	PAID	3	[{"method": "EFECTIVO", "amount": 134, "displayAmount": 200, "type": null, "id": 1774138912021, "received": 200, "cambio": 66}]	23	13	20
808	V9599	55	2026-03-22 00:23:48.893957	PAID	3	[{"method": "EFECTIVO", "amount": 55, "displayAmount": 200, "type": null, "id": 1774139036227, "received": 200, "cambio": 145}]	23	13	20
809	V9209	115	2026-03-22 00:24:42.897333	PAID	5	[{"method": "EFECTIVO", "amount": 115, "displayAmount": 115, "type": null, "id": 1774139108022, "received": 115, "cambio": 0}]	23	25	20
810	V5345	60	2026-03-22 00:25:37.111171	PAID	3	[{"method": "EFECTIVO", "amount": 60, "displayAmount": 100, "type": null, "id": 1774139146623, "received": 100, "cambio": 40}]	23	13	20
811	V6118	36	2026-03-22 00:28:35.17951	PAID	2	[{"method": "EFECTIVO", "amount": 36, "displayAmount": 40, "type": null, "id": 1774139314681, "received": 40, "cambio": 4}]	23	20	\N
812	V2780	48	2026-03-22 00:29:59.423228	PAID	2	[{"method": "EFECTIVO", "amount": 48, "displayAmount": 50, "type": null, "id": 1774139399059, "received": 50, "cambio": 2}]	23	20	\N
813	V2634	61	2026-03-22 00:32:04.627252	PAID	5	[{"method": "EFECTIVO", "amount": 61, "received": 100, "cambio": 39, "displayAmount": 100, "type": null, "id": 1774392238773}]	29	13	20
814	V2205	35	2026-03-22 00:33:54.688242	PAID	3	[{"method": "EFECTIVO", "amount": 35, "displayAmount": 100, "type": null, "id": 1774535094621, "received": 100, "cambio": 65}]	69	14	20
815	V9758	77	2026-03-22 00:36:06.698224	PAID	3	[{"method": "EFECTIVO", "amount": 77, "displayAmount": 77, "type": null, "id": 1774139777921, "received": 77, "cambio": 0}]	23	13	20
816	V4671	147	2026-03-22 00:38:48.826311	PAID	3	[{"method": "EFECTIVO", "amount": 147, "displayAmount": 150, "type": null, "id": 1774139955931, "received": 150, "cambio": 3}]	23	13	20
817	V6322	237	2026-03-22 00:39:01.725392	PAID	1	[{"method": "EFECTIVO", "amount": 237, "displayAmount": 500, "type": null, "id": 1774139996757, "received": 500, "cambio": 263}]	23	24	20
819	V2775	53	2026-03-22 00:44:40.760335	PAID	5	[{"method": "EFECTIVO", "amount": 53, "displayAmount": 55, "type": null, "id": 1774140299126, "received": 55, "cambio": 2}]	23	20	20
818	V8221	100	2026-03-22 00:44:36.962556	PAID	1	[{"method": "EFECTIVO", "amount": 100, "displayAmount": 100, "type": null, "id": 1774140347823, "received": 100, "cambio": 0}]	23	24	20
820	V2106	78	2026-03-22 00:45:52.462915	PAID	6	[{"method": "EFECTIVO", "amount": 78, "displayAmount": 500, "type": null, "id": 1774140378637, "received": 500, "cambio": 422}]	23	25	20
821	V2608	100	2026-03-22 00:47:33.91598	PAID	6	[{"method": "TARJETA", "amount": 100, "displayAmount": 100, "type": "DEBITO", "id": 1774140482875}]	23	25	20
822	V1679	44	2026-03-22 00:47:39.806945	PAID	4	[{"method": "EFECTIVO", "amount": 44, "received": 50, "cambio": 6, "displayAmount": 50, "type": null, "id": 1774395020159}]	29	9	20
823	V2123	2	2026-03-22 00:47:50.023579	PAID	3	[{"method": "EFECTIVO", "amount": 2, "displayAmount": 2, "type": null, "id": 1774632676502, "received": 2, "cambio": 0}]	71	17	20
824	V2810	29	2026-03-22 00:47:56.005664	PAID	1	[{"method": "EFECTIVO", "amount": 29, "displayAmount": 50, "type": null, "id": 1774140579307, "received": 50, "cambio": 21}]	23	26	20
825	V4268	96	2026-03-22 00:49:50.159789	PAID	3	[{"method": "EFECTIVO", "amount": 96, "displayAmount": 100, "type": null, "id": 1774140611128, "received": 100, "cambio": 4}]	23	24	20
827	V7385	147	2026-03-22 00:51:56.972482	PAID	3	[{"method": "EFECTIVO", "amount": 147, "displayAmount": 150, "type": null, "id": 1774140730373, "received": 150, "cambio": 3}]	23	13	20
826	V4033	151	2026-03-22 00:50:36.722675	PAID	6	[{"method": "EFECTIVO", "amount": 151, "displayAmount": 200, "type": null, "id": 1774140838866, "received": 200, "cambio": 49}]	23	25	20
828	V3985	97	2026-03-22 00:52:33.194806	PAID	5	[{"method": "EFECTIVO", "amount": 97, "displayAmount": 100, "type": null, "id": 1774140870083, "received": 100, "cambio": 3}]	23	27	20
831	V6349	125	2026-03-22 00:55:54.040203	PAID	3	[{"method": "TARJETA", "amount": 125, "displayAmount": 125, "type": "DEBITO", "id": 1774141008467}]	23	13	20
832	V7694	21	2026-03-22 00:57:06.349759	PAID	4	[{"method": "EFECTIVO", "amount": 21, "displayAmount": 50, "type": null, "id": 1774143799319, "received": 50, "cambio": 29}]	23	24	20
802	V3222	9	2026-03-22 00:13:27.051894	PAID	5	[{"method": "EFECTIVO", "amount": 9, "received": 666, "cambio": 657, "displayAmount": 666, "type": null, "id": 1774148799488}]	23	27	20
835	V6307	44	2026-03-22 00:59:03.162072	PAID	2	[{"method": "EFECTIVO", "amount": 44, "displayAmount": 500, "type": null, "id": 1774141142371, "received": 500, "cambio": 456}]	23	20	\N
836	V6662	65	2026-03-22 01:03:04.130294	PAID	3	[{"method": "EFECTIVO", "amount": 65, "displayAmount": 100, "type": null, "id": 1774141416993, "received": 100, "cambio": 35}]	23	13	20
840	V9743	156	2026-03-22 01:11:56.209266	PAID	5	[{"method": "EFECTIVO", "amount": 156, "received": 500, "cambio": 344, "displayAmount": 500, "type": null, "id": 1774141947743}]	23	27	20
841	V5231	26	2026-03-22 01:13:43.52251	PAID	5	[{"method": "EFECTIVO", "amount": 26, "displayAmount": 50, "type": null, "id": 1774142039342, "received": 50, "cambio": 24}]	23	27	20
844	V2344	40	2026-03-22 01:17:30.466281	PAID	5	[{"method": "EFECTIVO", "amount": 40, "displayAmount": 100, "type": null, "id": 1774142264760, "received": 100, "cambio": 60}]	23	27	20
850	V3417	203	2026-03-22 01:30:11.951787	PAID	5	[{"method": "EFECTIVO", "amount": 203, "displayAmount": 500, "type": null, "id": 1774143053733, "received": 500, "cambio": 297}]	23	27	20
853	V9040	178	2026-03-22 01:42:35.059252	PAID	5	[{"method": "EFECTIVO", "amount": 178, "displayAmount": 500, "type": null, "id": 1774143766029, "received": 500, "cambio": 322}]	23	27	20
855	V7738	128	2026-03-22 01:46:28.461846	PAID	3	[{"method": "TARJETA", "amount": 128, "displayAmount": 128, "type": "DEBITO", "id": 1774144022918}]	23	13	20
856	V2063	172	2026-03-22 01:48:26.834206	PAID	3	[{"method": "EFECTIVO", "amount": 172, "displayAmount": 500, "type": null, "id": 1774144117296, "received": 500, "cambio": 328}]	23	13	20
861	V1789	104	2026-03-22 01:58:40.234431	PAID	5	[{"method": "EFECTIVO", "amount": 104, "displayAmount": 200, "type": null, "id": 1774578143505, "received": 200, "cambio": 96}]	70	13	1
1104	V5638	175	2026-03-22 21:19:26.99479	PAID	2	[{"method": "EFECTIVO", "amount": 175, "received": 200, "cambio": 25, "displayAmount": 200, "type": null, "id": 1774214368738}]	27	3	\N
860	V2707	152	2026-03-22 01:54:43.581514	PAID	3	[{"method": "EFECTIVO", "amount": 152, "received": 200, "cambio": 48, "displayAmount": 200, "type": null, "id": 1774196973636}]	27	22	3
1053	V1106	44	2026-03-22 16:30:48.566228	PAID	4	[{"method": "EFECTIVO", "amount": 44, "received": 100, "cambio": 56, "displayAmount": 100, "type": null, "id": 1774197058529}]	27	23	3
1054	V6766	28	2026-03-22 16:31:56.048982	PAID	3	[{"method": "EFECTIVO", "amount": 28, "received": 28, "cambio": 0, "displayAmount": 28, "type": null, "id": 1774197157803}]	27	22	3
1060	V9651	87	2026-03-22 17:01:05.742003	PAID	4	[{"method": "EFECTIVO", "amount": 87, "received": 87, "cambio": 0, "displayAmount": 87, "type": null, "id": 1774198880943}]	27	23	3
1061	V7260	47	2026-03-22 17:04:11.562574	PAID	3	[{"method": "EFECTIVO", "amount": 47, "received": 60, "cambio": 13, "displayAmount": 60, "type": null, "id": 1774199060532}]	27	21	3
1070	V7721	76	2026-03-22 18:22:38.534927	PAID	5	[{"method": "EFECTIVO", "amount": 76, "received": 200, "cambio": 124, "displayAmount": 200, "type": null, "id": 1774203774381}]	27	21	3
1072	V1428	149	2026-03-22 18:43:11.960609	PAID	3	[{"method": "EFECTIVO", "amount": 149, "received": 200, "cambio": 51, "displayAmount": 200, "type": null, "id": 1774205020451}]	27	10	3
1078	V4406	148	2026-03-22 19:08:30.693127	PAID	5	[{"method": "EFECTIVO", "amount": 148, "received": 200, "cambio": 52, "displayAmount": 200, "type": null, "id": 1774206521853}]	27	21	3
1075	V9608	54	2026-03-22 18:56:25.2504	PAID	3	[{"method": "EFECTIVO", "amount": 54, "received": 54, "cambio": 0, "displayAmount": 54, "type": null, "id": 1774206556779}]	27	10	3
1080	V3791	136	2026-03-22 19:31:51.080685	PAID	2	[{"method": "EFECTIVO", "amount": 136, "received": 136, "cambio": 0, "displayAmount": 136, "type": null, "id": 1774207912819}]	27	3	\N
1082	V5003	146	2026-03-22 19:34:14.852523	PAID	5	[{"method": "EFECTIVO", "amount": 146, "received": 500, "cambio": 354, "displayAmount": 500, "type": null, "id": 1774208071623}]	27	21	3
1086	V5384	174	2026-03-22 19:58:37.801964	PAID	2	[{"method": "EFECTIVO", "amount": 174, "received": 174, "cambio": 0, "displayAmount": 174, "type": null, "id": 1774209519221}]	27	3	\N
1088	V2906	117	2026-03-22 20:01:13.817963	PAID	2	[{"method": "EFECTIVO", "amount": 117, "received": 200, "cambio": 83, "displayAmount": 200, "type": null, "id": 1774209675284}]	27	3	\N
1091	V7965	81	2026-03-22 20:07:30.695101	PAID	4	[{"method": "EFECTIVO", "amount": 81, "received": 500, "cambio": 419, "displayAmount": 500, "type": null, "id": 1774210372324}]	27	21	3
1095	V3993	48	2026-03-22 20:22:50.051453	PAID	5	[{"method": "EFECTIVO", "amount": 48, "received": 60, "cambio": 12, "displayAmount": 60, "type": null, "id": 1774210996413}]	27	25	3
1100	V7871	95	2026-03-22 20:42:43.351352	PAID	5	[{"method": "EFECTIVO", "amount": 95, "received": 100, "cambio": 5, "displayAmount": 100, "type": null, "id": 1774212315391}]	27	25	3
1101	V4533	178	2026-03-22 20:46:01.653316	PAID	4	[{"method": "EFECTIVO", "amount": 178, "received": 200, "cambio": 22, "displayAmount": 200, "type": null, "id": 1774212415490}]	27	21	3
1094	V5946	39	2026-03-22 20:20:55.346869	PAID	6	[{"method": "EFECTIVO", "amount": 39, "received": 39, "cambio": 0, "displayAmount": 39, "type": null, "id": 1774213205497}]	27	25	3
1098	V5872	11	2026-03-22 20:38:22.494627	PAID	4	[{"method": "EFECTIVO", "amount": 11, "received": 11, "cambio": 0, "displayAmount": 11, "type": null, "id": 1774451708397}]	31	16	20
1103	V4582	325	2026-03-22 21:15:08.54687	PAID	2	[{"method": "EFECTIVO", "amount": 325, "received": 500, "cambio": 175, "displayAmount": 500, "type": null, "id": 1774214109980}]	27	3	\N
1107	V2986	193	2026-03-22 21:26:16.113801	PAID	4	[{"method": "EFECTIVO", "amount": 193, "received": 500, "cambio": 307, "displayAmount": 500, "type": null, "id": 1774214803329}]	27	21	3
1108	V7784	218	2026-03-22 21:29:51.699228	PAID	5	[{"method": "EFECTIVO", "amount": 218, "received": 220, "cambio": 2, "displayAmount": 220, "type": null, "id": 1774215000871}]	27	21	3
1109	V2250	38	2026-03-22 21:34:52.324412	PAID	3	[{"method": "EFECTIVO", "amount": 38, "received": 38, "cambio": 0, "displayAmount": 38, "type": null, "id": 1774215302179}]	27	21	3
1213	V3472	30	2026-03-23 01:09:32.218863	PAID	3	[{"method": "EFECTIVO", "amount": 30, "received": 30, "cambio": 0, "displayAmount": 30, "type": null, "id": 1774228212034}]	27	33	3
2257	V5506	112	2026-03-26 03:06:51.159772	PAID	5	[{"method": "EFECTIVO", "amount": 112, "received": 500, "cambio": 388, "displayAmount": 500, "type": null, "id": 1774494510737}]	35	8	3
834	V4710	57	2026-03-22 00:58:50.396377	PAID	5	[{"method": "EFECTIVO", "amount": 57, "received": 57, "cambio": 0, "displayAmount": 57, "type": null, "id": 1774141185780}]	23	27	20
838	V8709	119	2026-03-22 01:07:42.25224	PAID	5	[{"method": "EFECTIVO", "amount": 119, "received": 500, "cambio": 381, "displayAmount": 500, "type": null, "id": 1774573279855}]	70	24	1
839	V9350	99	2026-03-22 01:11:45.398567	PAID	3	[{"method": "EFECTIVO", "amount": 99, "displayAmount": 500, "type": null, "id": 1774141918968, "received": 500, "cambio": 401}]	23	13	20
845	V4196	124	2026-03-22 01:20:15.087616	PAID	3	[{"method": "EFECTIVO", "amount": 124, "displayAmount": 200, "type": null, "id": 1774142458292, "received": 200, "cambio": 76}]	23	13	20
854	V8944	209	2026-03-22 01:44:05.39195	PAID	2	[{"method": "EFECTIVO", "amount": 209, "displayAmount": 500, "type": null, "id": 1774633498038, "received": 500, "cambio": 291}]	71	20	20
847	V5772	25	2026-03-22 01:22:47.496378	PAID	5	[{"method": "EFECTIVO", "amount": 25, "displayAmount": 25, "type": null, "id": 1774142582883, "received": 25, "cambio": 0}]	23	27	20
848	V8245	208	2026-03-22 01:25:35.213844	PAID	5	[{"method": "EFECTIVO", "amount": 208, "displayAmount": 208, "type": null, "id": 1774142764950, "received": 208, "cambio": 0}]	23	27	20
849	V8815	35	2026-03-22 01:29:34.40006	PAID	3	[{"method": "EFECTIVO", "amount": 35, "displayAmount": 35, "type": null, "id": 1774467576572, "received": 35, "cambio": 0}]	31	16	20
852	V4356	115	2026-03-22 01:39:24.186785	PAID	3	[{"method": "EFECTIVO", "amount": 115, "received": 150, "cambio": 35, "displayAmount": 150, "type": null, "id": 1774402110365}]	30	9	3
857	V4265	48	2026-03-22 01:50:44.019925	PAID	3	[{"method": "EFECTIVO", "amount": 48, "displayAmount": 200, "type": null, "id": 1774144252083, "received": 200, "cambio": 152}]	23	13	20
1057	V9071	26	2026-03-22 16:36:31.850185	PAID	3	[{"method": "EFECTIVO", "amount": 26, "received": 26, "cambio": 0, "displayAmount": 26, "type": null, "id": 1774197429062}]	27	10	3
1059	V5025	73	2026-03-22 17:00:40.975783	PAID	3	[{"method": "EFECTIVO", "amount": 73, "received": 73, "cambio": 0, "displayAmount": 73, "type": null, "id": 1774198851682}]	27	21	3
1064	V3862	43	2026-03-22 17:09:13.505504	PAID	5	[{"method": "EFECTIVO", "amount": 43, "received": 43, "cambio": 0, "displayAmount": 43, "type": null, "id": 1774199653323}]	27	21	3
1065	V5933	127	2026-03-22 17:48:45.628097	PAID	3	[{"method": "EFECTIVO", "amount": 127, "received": 200, "cambio": 73, "displayAmount": 200, "type": null, "id": 1774201734467}]	27	21	3
1068	V9164	78	2026-03-22 18:17:09.007581	PAID	5	[{"method": "EFECTIVO", "amount": 78, "received": 78, "cambio": 0, "displayAmount": 78, "type": null, "id": 1774203445470}]	27	21	3
1073	V6156	25	2026-03-22 18:43:28.2236	PAID	2	[{"method": "EFECTIVO", "amount": 25, "received": 25, "cambio": 0, "displayAmount": 25, "type": null, "id": 1774205009176}]	27	3	\N
1063	V6402	53	2026-03-22 17:07:48.416258	PAID	4	[{"method": "EFECTIVO", "amount": 53, "received": 53, "cambio": 0, "displayAmount": 53, "type": null, "id": 1774205318669}]	27	23	3
1074	V1851	135	2026-03-22 18:53:34.07519	PAID	2	[{"method": "EFECTIVO", "amount": 135, "received": 500, "cambio": 365, "displayAmount": 500, "type": null, "id": 1774205615650}]	27	3	\N
1081	V7021	189	2026-03-22 19:32:42.238661	PAID	2	[{"method": "EFECTIVO", "amount": 189, "received": 189, "cambio": 0, "displayAmount": 189, "type": null, "id": 1774207963612}]	27	3	\N
1083	V5002	72	2026-03-22 19:38:22.11689	PAID	5	[{"method": "EFECTIVO", "amount": 72, "received": 200, "cambio": 128, "displayAmount": 200, "type": null, "id": 1774579501812}]	70	24	1
1090	V4470	54	2026-03-22 20:05:22.019373	PAID	2	[{"method": "EFECTIVO", "amount": 54, "received": 54, "cambio": 0, "displayAmount": 54, "type": null, "id": 1774209923442}]	27	3	\N
1093	V6596	191	2026-03-22 20:17:09.939828	PAID	5	[{"method": "EFECTIVO", "amount": 191, "received": 200, "cambio": 9, "displayAmount": 200, "type": null, "id": 1774210794211}]	27	25	3
1099	V5829	90	2026-03-22 20:42:17.112687	PAID	3	[{"method": "EFECTIVO", "amount": 90, "received": 500, "cambio": 410, "displayAmount": 500, "type": null, "id": 1774212161035}]	27	21	3
1102	V2268	162	2026-03-22 20:52:38.567321	PAID	5	[{"method": "EFECTIVO", "amount": 162, "received": 200, "cambio": 38, "displayAmount": 200, "type": null, "id": 1774212791984}]	27	21	3
1089	V7089	12	2026-03-22 20:04:10.926973	PAID	5	[{"method": "EFECTIVO", "amount": 12, "received": 12, "cambio": 0, "displayAmount": 12, "type": null, "id": 1774213197097}]	27	21	3
1096	V1443	66	2026-03-22 20:26:25.911747	PAID	3	[{"method": "EFECTIVO", "amount": 66, "received": 66, "cambio": 0, "displayAmount": 66, "type": null, "id": 1774213865065}]	27	25	3
1105	V4778	200	2026-03-22 21:23:33.541041	PAID	3	[{"method": "EFECTIVO", "amount": 200, "received": 200, "cambio": 0, "displayAmount": 200, "type": null, "id": 1774214623199}]	27	21	3
1106	V4786	55	2026-03-22 21:24:03.690865	PAID	5	[{"method": "EFECTIVO", "amount": 55, "received": 55, "cambio": 0, "displayAmount": 55, "type": null, "id": 1774214795365}]	27	25	3
2252	V4661	126	2026-03-26 02:53:19.617542	PAID	3	[{"method": "EFECTIVO", "amount": 126, "received": 150, "cambio": 24, "displayAmount": 150, "type": null, "id": 1774493614772}]	35	18	3
1114	V8323	54	2026-03-22 21:45:53.375303	PAID	6	[{"method": "EFECTIVO", "amount": 54, "received": 500, "cambio": 446, "displayAmount": 500, "type": null, "id": 1774216030617}]	27	21	3
1117	V5835	277	2026-03-22 22:06:04.314884	PAID	5	[{"method": "EFECTIVO", "amount": 277, "received": 500, "cambio": 223, "displayAmount": 500, "type": null, "id": 1774217184537}]	27	25	3
1118	V1573	116	2026-03-22 22:07:19.402059	PAID	4	[{"method": "EFECTIVO", "amount": 116, "received": 200, "cambio": 84, "displayAmount": 200, "type": null, "id": 1774313869236}]	28	9	20
1119	V7576	32	2026-03-22 22:08:06.059177	PAID	4	[{"method": "EFECTIVO", "amount": 32, "received": 40, "cambio": 8, "displayAmount": 40, "type": null, "id": 1774217307960}]	27	28	3
1122	V8708	80	2026-03-22 22:12:01.072719	PAID	4	[{"method": "EFECTIVO", "amount": 80, "received": 200, "cambio": 120, "displayAmount": 200, "type": null, "id": 1774217548766}]	27	29	3
1085	V8900	31	2026-03-22 19:50:29.903671	PAID	2	[{"method": "EFECTIVO", "amount": 31, "received": 31, "cambio": 0, "displayAmount": 31, "type": null, "id": 1774306455360}]	28	18	20
1092	V6313	29	2026-03-22 20:10:34.546234	PAID	2	[{"method": "EFECTIVO", "amount": 29, "received": 29, "cambio": 0, "displayAmount": 29, "type": null, "id": 1774317943813}]	28	9	20
833	V4389	20	2026-03-22 00:58:49.186512	PAID	6	[{"method": "EFECTIVO", "amount": 20, "displayAmount": 20, "type": null, "id": 1774141209638, "received": 20, "cambio": 0}]	23	24	20
837	V6218	88	2026-03-22 01:06:50.663515	PAID	5	[{"method": "EFECTIVO", "amount": 88, "displayAmount": 100, "type": null, "id": 1774141619696, "received": 100, "cambio": 12}]	23	27	20
842	V9654	41	2026-03-22 01:14:39.739185	PAID	5	[{"method": "EFECTIVO", "amount": 41, "displayAmount": 50, "type": null, "id": 1774142092571, "received": 50, "cambio": 9}]	23	27	20
843	V2930	105	2026-03-22 01:16:32.998356	PAID	3	[{"method": "EFECTIVO", "amount": 105, "received": 110, "cambio": 5, "displayAmount": 110, "type": null, "id": 1774485897039}]	35	18	3
851	V8916	123	2026-03-22 01:34:20.59973	PAID	5	[{"method": "EFECTIVO", "amount": 123, "displayAmount": 200, "type": null, "id": 1774143274292, "received": 200, "cambio": 77}]	23	27	20
858	V4498	28	2026-03-22 01:52:16.980014	PAID	2	[{"method": "EFECTIVO", "amount": 28, "displayAmount": 50, "type": null, "id": 1774144331145, "received": 50, "cambio": 22}]	23	20	\N
2253	V8995	119	2026-03-26 02:53:43.943353	PAID	5	[{"method": "EFECTIVO", "amount": 119, "received": 200, "cambio": 81, "displayAmount": 200, "type": null, "id": 1774493645515}]	35	4	3
862	V5505	95	2026-03-22 02:01:50.606521	PAID	5	[{"method": "EFECTIVO", "amount": 95, "displayAmount": 100, "type": null, "id": 1774144946033, "received": 100, "cambio": 5}]	23	27	20
863	V7192	178	2026-03-22 02:03:21.567358	PAID	3	[{"method": "EFECTIVO", "amount": 178, "displayAmount": 1000, "type": null, "id": 1774145015919, "received": 1000, "cambio": 822}]	23	13	20
911	V6436	60	2026-03-22 03:10:37.58983	PAID	3	[{"method": "EFECTIVO", "amount": 60, "received": 500, "cambio": 440, "displayAmount": 500, "type": null, "id": 1774229777750}]	27	28	3
865	V1247	103	2026-03-22 02:06:05.59151	PAID	3	[{"method": "EFECTIVO", "amount": 103, "displayAmount": 103, "type": null, "id": 1774145222054, "received": 103, "cambio": 0}]	23	13	20
867	V5702	27	2026-03-22 02:06:52.442451	PAID	5	[{"method": "EFECTIVO", "amount": 27, "received": 27, "cambio": 0, "displayAmount": 27, "type": null, "id": 1774309425704}]	28	9	20
868	V8004	127	2026-03-22 02:07:00.892312	PAID	4	[{"method": "EFECTIVO", "amount": 127, "displayAmount": 130, "type": null, "id": 1774145325171, "received": 130, "cambio": 3}]	23	25	20
869	V2253	48	2026-03-22 02:07:10.941664	PAID	6	[{"method": "EFECTIVO", "amount": 48, "displayAmount": 100, "type": null, "id": 1774145353282, "received": 100, "cambio": 52}]	23	24	20
870	V5387	44	2026-03-22 02:12:25.952185	PAID	3	[{"method": "TARJETA", "amount": 44, "displayAmount": 44, "type": "DEBITO", "id": 1774145589721}]	23	13	20
871	V8522	181	2026-03-22 02:13:03.000352	PAID	5	[{"method": "EFECTIVO", "amount": 181, "displayAmount": 200, "type": null, "id": 1774145630410, "received": 200, "cambio": 19}]	23	27	20
872	V2770	29	2026-03-22 02:14:41.486474	PAID	3	[{"method": "EFECTIVO", "amount": 29, "displayAmount": 40, "type": null, "id": 1774145695047, "received": 40, "cambio": 11}]	23	13	20
873	V5397	58	2026-03-22 02:15:35.110698	PAID	5	[{"method": "EFECTIVO", "amount": 58, "displayAmount": 100, "type": null, "id": 1774145754036, "received": 100, "cambio": 42}]	23	27	20
874	V6190	94	2026-03-22 02:16:22.001657	PAID	3	[{"method": "EFECTIVO", "amount": 94, "displayAmount": 500, "type": null, "id": 1774145804668, "received": 500, "cambio": 406}]	23	13	20
882	V2525	70	2026-03-22 02:24:37.878692	PAID	4	[{"method": "EFECTIVO", "amount": 70, "received": 100, "cambio": 30, "displayAmount": 100, "type": null, "id": 1774302679350}]	28	9	20
876	V3291	79	2026-03-22 02:20:35.483588	PAID	3	[{"method": "EFECTIVO", "amount": 79, "received": 200, "cambio": 121, "displayAmount": 200, "type": null, "id": 1774568295498}]	70	13	1
877	V6575	43	2026-03-22 02:21:29.969455	PAID	5	[{"method": "EFECTIVO", "amount": 43, "displayAmount": 50, "type": null, "id": 1774146124037, "received": 50, "cambio": 7}]	23	27	20
878	V9617	35	2026-03-22 02:21:47.67206	PAID	4	[{"method": "EFECTIVO", "amount": 35, "displayAmount": 35, "type": null, "id": 1774146154743, "received": 35, "cambio": 0}]	23	24	20
883	V3713	57	2026-03-22 02:28:18.00246	PAID	3	[{"method": "EFECTIVO", "amount": 57, "displayAmount": 100, "type": null, "id": 1774371991575, "received": 100, "cambio": 43}]	29	17	20
881	V8721	25	2026-03-22 02:23:14.374786	PAID	3	[{"method": "EFECTIVO", "amount": 25, "displayAmount": 50, "type": null, "id": 1774146230862, "received": 50, "cambio": 25}]	23	13	20
880	V2074	51	2026-03-22 02:22:34.6779	PAID	5	[{"method": "EFECTIVO", "amount": 51, "displayAmount": 51, "type": null, "id": 1774146253384, "received": 51, "cambio": 0}]	23	27	20
829	V1704	35	2026-03-22 00:55:13.611275	PAID	6	[{"method": "EFECTIVO", "amount": 35, "displayAmount": 35, "type": null, "id": 1774449536027, "received": 35, "cambio": 0}]	31	16	20
891	V3869	37	2026-03-22 02:40:15.438093	PAID	5	[{"method": "EFECTIVO", "amount": 37, "received": 50, "cambio": 13, "displayAmount": 50, "type": null, "id": 1774620070549}]	71	17	20
884	V1658	82	2026-03-22 02:30:06.05266	PAID	4	[{"method": "EFECTIVO", "amount": 82, "displayAmount": 100, "type": null, "id": 1774146627966, "received": 100, "cambio": 18}]	23	24	20
885	V7376	11	2026-03-22 02:30:09.570315	PAID	3	[{"method": "EFECTIVO", "amount": 11, "displayAmount": 100, "type": null, "id": 1774146661344, "received": 100, "cambio": 89}]	23	13	20
886	V4721	33	2026-03-22 02:30:28.423588	PAID	5	[{"method": "EFECTIVO", "amount": 33, "displayAmount": 33, "type": null, "id": 1774146696284, "received": 33, "cambio": 0}]	23	27	20
887	V4114	78	2026-03-22 02:32:37.004738	PAID	3	[{"method": "EFECTIVO", "amount": 78, "displayAmount": 80, "type": null, "id": 1774146786602, "received": 80, "cambio": 2}]	23	13	20
889	V7128	134	2026-03-22 02:35:11.555555	PAID	2	[{"method": "EFECTIVO", "amount": 134, "displayAmount": 500, "type": null, "id": 1774146910542, "received": 500, "cambio": 366}]	23	20	\N
888	V3080	61	2026-03-22 02:33:34.752935	PAID	4	[{"method": "EFECTIVO", "amount": 61, "displayAmount": 200, "type": null, "id": 1774146944998, "received": 200, "cambio": 139}]	23	24	20
890	V8040	139	2026-03-22 02:38:56.001904	PAID	3	[{"method": "EFECTIVO", "amount": 139, "displayAmount": 200, "type": null, "id": 1774147145747, "received": 200, "cambio": 61}]	23	24	20
892	V2597	114	2026-03-22 02:41:09.376229	PAID	4	[{"method": "EFECTIVO", "amount": 114, "displayAmount": 215, "type": null, "id": 1774147291339, "received": 215, "cambio": 101}]	23	27	20
893	V5474	144	2026-03-22 02:42:02.630091	PAID	3	[{"method": "EFECTIVO", "amount": 144, "displayAmount": 144, "type": null, "id": 1774147349338, "received": 144, "cambio": 0}]	23	24	20
894	V7988	129	2026-03-22 02:42:43.3242	PAID	5	[{"method": "EFECTIVO", "amount": 129, "displayAmount": 130, "type": null, "id": 1774147392173, "received": 130, "cambio": 1}]	23	13	20
895	V7287	50	2026-03-22 02:43:11.142042	PAID	6	[{"method": "EFECTIVO", "amount": 50, "displayAmount": 500, "type": null, "id": 1774147418502, "received": 500, "cambio": 450}]	23	25	20
896	V3190	43	2026-03-22 02:43:46.504379	PAID	4	[{"method": "EFECTIVO", "amount": 43, "received": 50, "cambio": 7, "displayAmount": 50, "type": null, "id": 1774404827022}]	30	9	3
898	V1637	76	2026-03-22 02:45:47.573693	PAID	5	[{"method": "EFECTIVO", "amount": 76, "displayAmount": 76, "type": null, "id": 1774147602375, "received": 76, "cambio": 0}]	23	25	20
902	V1757	130	2026-03-22 02:53:43.605443	PAID	2	[{"method": "EFECTIVO", "amount": 130, "received": 130, "cambio": 0, "displayAmount": 130, "type": null, "id": 1774148024239}]	23	20	\N
901	V8543	102	2026-03-22 02:53:41.513324	PAID	4	[{"method": "EFECTIVO", "amount": 102, "received": 102, "cambio": 0, "displayAmount": 102, "type": null, "id": 1774148070901}]	23	27	20
903	V1379	39	2026-03-22 02:54:44.317148	PAID	3	[{"method": "EFECTIVO", "amount": 39, "displayAmount": 50, "type": null, "id": 1774358776855, "received": 50, "cambio": 11}]	29	14	20
908	V9482	51	2026-03-22 03:00:40.616669	PAID	5	[{"method": "EFECTIVO", "amount": 51, "received": 101, "cambio": 50, "displayAmount": 101, "type": null, "id": 1774148454808}]	23	27	20
909	V5190	82	2026-03-22 03:04:49.86484	PAID	5	[{"method": "EFECTIVO", "amount": 82, "received": 100, "cambio": 18, "displayAmount": 100, "type": null, "id": 1774148702275}]	23	20	20
875	V9835	28	2026-03-22 02:20:18.476277	PAID	5	[{"method": "EFECTIVO", "amount": 28, "received": 989, "cambio": 961, "displayAmount": 989, "type": null, "id": 1774148806646}]	23	27	20
1123	V6135	108	2026-03-22 22:12:44.587924	PAID	4	[{"method": "EFECTIVO", "amount": 108, "received": 200, "cambio": 92, "displayAmount": 200, "type": null, "id": 1774217586772}]	27	25	3
1124	V2468	29	2026-03-22 22:21:31.157965	PAID	4	[{"method": "EFECTIVO", "amount": 29, "received": 29, "cambio": 0, "displayAmount": 29, "type": null, "id": 1774218108119}]	27	29	3
1218	V9202	62	2026-03-23 01:18:55.121718	PAID	5	[{"method": "EFECTIVO", "amount": 62, "received": 200, "cambio": 138, "displayAmount": 200, "type": null, "id": 1774228775783}]	27	28	3
1221	V5924	30	2026-03-23 01:23:38.667219	PAID	6	[{"method": "EFECTIVO", "amount": 30, "displayAmount": 30, "type": null, "id": 1774374647636, "received": 30, "cambio": 0}]	29	16	20
1215	V1877	55	2026-03-23 01:15:30.678889	PAID	4	[{"method": "EFECTIVO", "amount": 55, "received": 55, "cambio": 0, "displayAmount": 55, "type": null, "id": 1774229114503}]	27	28	3
1224	V3899	34	2026-03-23 01:25:49.390689	PAID	6	[{"method": "EFECTIVO", "amount": 34, "received": 40, "cambio": 6, "displayAmount": 40, "type": null, "id": 1774229185498}]	27	25	3
1232	V3503	97	2026-03-23 01:30:57.400261	PAID	5	[{"method": "EFECTIVO", "amount": 97, "received": 200, "cambio": 103, "displayAmount": 200, "type": null, "id": 1774229578292}]	27	29	3
1234	V8499	38	2026-03-23 01:31:46.376907	PAID	6	[{"method": "EFECTIVO", "amount": 38, "received": 38, "cambio": 0, "displayAmount": 38, "type": null, "id": 1774319229414}]	28	24	20
1235	V4604	42	2026-03-23 01:32:48.097891	PAID	1	[{"method": "EFECTIVO", "amount": 42, "received": 42, "cambio": 0, "displayAmount": 42, "type": null, "id": 1774229680320}]	27	28	3
1238	V1937	38	2026-03-23 01:36:50.524195	PAID	1	[{"method": "EFECTIVO", "amount": 38, "received": 38, "cambio": 0, "displayAmount": 38, "type": null, "id": 1774489409203}]	35	18	3
1239	V3711	55	2026-03-23 01:38:46.911376	PAID	3	[{"method": "EFECTIVO", "amount": 55, "received": 200, "cambio": 145, "displayAmount": 200, "type": null, "id": 1774229945943}]	27	33	3
1242	V8925	132	2026-03-23 01:41:32.542849	PAID	5	[{"method": "EFECTIVO", "amount": 132, "received": 500, "cambio": 368, "displayAmount": 500, "type": null, "id": 1774230162510}]	27	28	3
1243	V1213	131	2026-03-23 01:42:43.577865	PAID	1	[{"method": "EFECTIVO", "amount": 131, "received": 200, "cambio": 69, "displayAmount": 200, "type": null, "id": 1774230217381}]	27	25	3
1245	V1043	64	2026-03-23 01:48:41.013594	PAID	5	[{"method": "EFECTIVO", "amount": 64, "received": 100, "cambio": 36, "displayAmount": 100, "type": null, "id": 1774230546603}]	27	25	3
1246	V9367	75	2026-03-23 01:49:29.29936	PAID	6	[{"method": "EFECTIVO", "amount": 75, "received": 75, "cambio": 0, "displayAmount": 75, "type": null, "id": 1774230612510}]	27	29	3
1247	V9308	93	2026-03-23 01:51:13.86398	PAID	1	[{"method": "EFECTIVO", "amount": 93, "received": 200, "cambio": 107, "displayAmount": 200, "type": null, "id": 1774230691116}]	27	31	3
1244	V3208	62	2026-03-23 01:47:07.995825	PAID	3	[{"method": "EFECTIVO", "amount": 62, "received": 62, "cambio": 0, "displayAmount": 62, "type": null, "id": 1774230750290}]	27	33	3
1248	V5576	146	2026-03-23 01:52:12.327118	PAID	3	[{"method": "EFECTIVO", "amount": 146, "received": 200, "cambio": 54, "displayAmount": 200, "type": null, "id": 1774230778585}]	27	33	3
1249	V4092	167	2026-03-23 01:52:54.933396	PAID	5	[{"method": "EFECTIVO", "amount": 167, "received": 167, "cambio": 0, "displayAmount": 167, "type": null, "id": 1774230808173}]	27	25	3
1250	V4011	96	2026-03-23 01:54:07.921739	PAID	1	[{"method": "EFECTIVO", "amount": 96, "received": 100, "cambio": 4, "displayAmount": 100, "type": null, "id": 1774230910083}]	27	26	3
1251	V9330	30	2026-03-23 01:55:07.733864	PAID	3	[{"method": "EFECTIVO", "amount": 30, "received": 30, "cambio": 0, "displayAmount": 30, "type": null, "id": 1774230934974}]	27	33	3
1252	V4046	115	2026-03-23 01:55:11.510071	PAID	6	[{"method": "EFECTIVO", "amount": 115, "received": 115, "cambio": 0, "displayAmount": 115, "type": null, "id": 1774230944217}]	27	28	3
1253	V2416	56	2026-03-23 01:55:56.554846	PAID	1	[{"method": "EFECTIVO", "amount": 56, "received": 100, "cambio": 44, "displayAmount": 100, "type": null, "id": 1774231039638}]	27	26	3
2254	V2648	26	2026-03-26 03:00:39.99929	PAID	5	[{"method": "EFECTIVO", "amount": 26, "received": 50, "cambio": 24, "displayAmount": 50, "type": null, "id": 1774494062097}]	35	18	3
1222	V3747	53	2026-03-23 01:24:53.610782	PAID	6	[{"method": "EFECTIVO", "amount": 53, "received": 53, "cambio": 0, "displayAmount": 53, "type": null, "id": 1774231135568}]	27	25	3
859	V1006	80	2026-03-22 01:52:36.317919	PAID	3	[{"method": "EFECTIVO", "amount": 80, "displayAmount": 80, "type": null, "id": 1774553233998, "received": 80, "cambio": 0}]	69	20	20
897	V8292	129	2026-03-22 02:45:15.690983	PAID	3	[{"method": "TARJETA", "amount": 129, "displayAmount": 129, "type": "DEBITO", "id": 1774147550951}]	23	13	20
899	V1534	125	2026-03-22 02:48:50.695327	PAID	3	[{"method": "EFECTIVO", "amount": 125, "received": 150, "cambio": 25, "displayAmount": 150, "type": null, "id": 1774311239539}]	28	9	20
900	V7304	150	2026-03-22 02:51:58.177568	PAID	3	[{"method": "EFECTIVO", "amount": 150, "received": 150, "cambio": 0, "displayAmount": 150, "type": null, "id": 1774147934768}]	23	13	20
904	V8328	78	2026-03-22 02:54:45.034909	PAID	4	[{"method": "EFECTIVO", "amount": 78, "received": 80, "cambio": 2, "displayAmount": 80, "type": null, "id": 1774398885378}]	30	9	3
905	V7117	22	2026-03-22 02:55:58.817352	PAID	3	[{"method": "EFECTIVO", "amount": 22, "received": 22, "cambio": 0, "displayAmount": 22, "type": null, "id": 1774148190357}]	23	13	20
907	V9503	48	2026-03-22 02:58:52.638604	PAID	4	[{"method": "EFECTIVO", "amount": 48, "displayAmount": 50, "type": null, "id": 1774623474752, "received": 50, "cambio": 2}]	71	15	20
866	V4682	126	2026-03-22 02:06:41.24961	PAID	3	[{"method": "EFECTIVO", "amount": 126, "received": 555, "cambio": 429, "displayAmount": 555, "type": null, "id": 1774148776598}]	23	13	20
906	V5260	37	2026-03-22 02:58:10.044593	PAID	3	[{"method": "EFECTIVO", "amount": 37, "received": 50, "cambio": 13, "displayAmount": 50, "type": null, "id": 1774575366522}]	70	4	1
910	V5986	86	2026-03-22 03:09:57.083691	PAID	4	[{"method": "EFECTIVO", "amount": 86, "received": 86, "cambio": 0, "displayAmount": 86, "type": null, "id": 1774149016221}]	23	27	20
912	V2138	93	2026-03-22 03:11:46.437186	PAID	5	[{"method": "EFECTIVO", "amount": 93, "received": 100, "cambio": 7, "displayAmount": 100, "type": null, "id": 1774149117933}]	23	24	20
913	V2596	62	2026-03-22 03:16:14.338831	PAID	3	[{"method": "EFECTIVO", "amount": 62, "received": 200, "cambio": 138, "displayAmount": 200, "type": null, "id": 1774149383166}]	23	13	20
1126	V4877	99	2026-03-22 22:25:58.619626	PAID	4	[{"method": "EFECTIVO", "amount": 99, "received": 100, "cambio": 1, "displayAmount": 100, "type": null, "id": 1774218390226}]	27	25	3
1130	V4090	106	2026-03-22 22:31:23.995798	PAID	5	[{"method": "EFECTIVO", "amount": 106, "received": 106, "cambio": 0, "displayAmount": 106, "type": null, "id": 1774218698951}]	27	21	3
1131	V3421	66	2026-03-22 22:33:36.218256	PAID	5	[{"method": "EFECTIVO", "amount": 66, "received": 70, "cambio": 4, "displayAmount": 70, "type": null, "id": 1774218826012}]	27	21	3
1132	V1899	38	2026-03-22 22:33:48.627643	PAID	4	[{"method": "EFECTIVO", "amount": 38, "received": 38, "cambio": 0, "displayAmount": 38, "type": null, "id": 1774218858596}]	27	25	3
1134	V5844	77	2026-03-22 22:35:42.006414	PAID	5	[{"method": "EFECTIVO", "amount": 77, "received": 100, "cambio": 23, "displayAmount": 100, "type": null, "id": 1774218958477}]	27	25	3
1133	V8364	89	2026-03-22 22:35:35.197723	PAID	4	[{"method": "EFECTIVO", "amount": 89, "received": 89, "cambio": 0, "displayAmount": 89, "type": null, "id": 1774218982426}]	27	28	3
1139	V7861	88	2026-03-22 22:45:53.655128	PAID	5	[{"method": "EFECTIVO", "amount": 88, "received": 88, "cambio": 0, "displayAmount": 88, "type": null, "id": 1774219582211}]	27	25	3
1138	V2642	32	2026-03-22 22:45:51.043521	PAID	4	[{"method": "EFECTIVO", "amount": 32, "received": 32, "cambio": 0, "displayAmount": 32, "type": null, "id": 1774219653339}]	27	28	3
1143	V9764	93	2026-03-22 22:55:22.137693	PAID	3	[{"method": "EFECTIVO", "amount": 93, "displayAmount": 500, "type": null, "id": 1774532210299, "received": 500, "cambio": 407}]	69	15	20
1141	V4983	14	2026-03-22 22:49:39.182636	PAID	4	[{"method": "EFECTIVO", "amount": 14, "received": 74, "cambio": 60, "displayAmount": 74, "type": null, "id": 1774220178732}]	27	28	3
1145	V9426	83	2026-03-22 22:58:09.668182	PAID	3	[{"method": "EFECTIVO", "amount": 83, "received": 83, "cambio": 0, "displayAmount": 83, "type": null, "id": 1774220304674}]	27	28	3
1147	V8533	79	2026-03-22 23:00:48.960199	PAID	4	[{"method": "EFECTIVO", "amount": 79, "received": 100, "cambio": 21, "displayAmount": 100, "type": null, "id": 1774236281908}]	27	33	3
1148	V6866	72	2026-03-22 23:12:05.659348	PAID	3	[{"method": "EFECTIVO", "amount": 72, "received": 100, "cambio": 28, "displayAmount": 100, "type": null, "id": 1774221137675}]	27	31	3
1149	V7931	141	2026-03-22 23:13:13.087422	PAID	1	[{"method": "EFECTIVO", "amount": 141, "received": 500, "cambio": 359, "displayAmount": 500, "type": null, "id": 1774221208152}]	27	26	3
1153	V9972	92	2026-03-22 23:24:19.344384	PAID	3	[{"method": "EFECTIVO", "amount": 92, "received": 92, "cambio": 0, "displayAmount": 92, "type": null, "id": 1774221873562}]	27	31	3
1156	V4391	47	2026-03-22 23:32:32.188656	PAID	3	[{"method": "EFECTIVO", "amount": 47, "received": 47, "cambio": 0, "displayAmount": 47, "type": null, "id": 1774222387024}]	27	33	3
1164	V6056	153	2026-03-22 23:45:40.559656	PAID	1	[{"method": "EFECTIVO", "amount": 153, "received": 200, "cambio": 47, "displayAmount": 200, "type": null, "id": 1774223155861}]	27	26	3
1167	V1632	85	2026-03-22 23:50:27.316554	PAID	5	[{"method": "EFECTIVO", "amount": 85, "received": 85, "cambio": 0, "displayAmount": 85, "type": null, "id": 1774223436326}]	27	25	3
1168	V1471	98	2026-03-22 23:50:56.537788	PAID	3	[{"method": "EFECTIVO", "amount": 98, "received": 200, "cambio": 102, "displayAmount": 200, "type": null, "id": 1774223466756}]	27	29	3
1170	V7770	20	2026-03-22 23:54:40.681565	PAID	3	[{"method": "EFECTIVO", "amount": 20, "received": 20, "cambio": 0, "displayAmount": 20, "type": null, "id": 1774223698937}]	27	33	3
1176	V7380	185	2026-03-23 00:06:35.163526	PAID	5	[{"method": "EFECTIVO", "amount": 185, "received": 500, "cambio": 315, "displayAmount": 500, "type": null, "id": 1774224406279}]	27	25	3
1177	V9823	127	2026-03-23 00:08:18.593747	PAID	3	[{"method": "EFECTIVO", "amount": 127, "received": 500, "cambio": 373, "displayAmount": 500, "type": null, "id": 1774224506210}]	27	28	3
1182	V3065	182	2026-03-23 00:23:00.976489	PAID	3	[{"method": "EFECTIVO", "amount": 182, "received": 200, "cambio": 18, "displayAmount": 200, "type": null, "id": 1774225391265}]	27	25	3
1184	V5167	70	2026-03-23 00:28:32.827957	PAID	3	[{"method": "EFECTIVO", "amount": 70, "received": 70, "cambio": 0, "displayAmount": 70, "type": null, "id": 1774225720444}]	27	25	3
1185	V5219	36	2026-03-23 00:29:17.542465	PAID	3	[{"method": "EFECTIVO", "amount": 36, "received": 36, "cambio": 0, "displayAmount": 36, "type": null, "id": 1774225775549}]	27	25	3
1135	V9507	68	2026-03-22 22:40:24.359943	PAID	4	[{"method": "EFECTIVO", "amount": 68, "displayAmount": 70, "type": null, "id": 1774447825674, "received": 70, "cambio": 2}]	31	14	20
914	V1814	36	2026-03-22 03:16:51.272299	PAID	3	[{"method": "EFECTIVO", "amount": 36, "received": 50, "cambio": 14, "displayAmount": 50, "type": null, "id": 1774149418351}]	23	13	20
1127	V7991	85	2026-03-22 22:27:05.302794	PAID	5	[{"method": "EFECTIVO", "amount": 85, "received": 100, "cambio": 15, "displayAmount": 100, "type": null, "id": 1774218451079}]	27	21	3
1128	V5768	94	2026-03-22 22:28:44.707298	PAID	3	[{"method": "EFECTIVO", "amount": 94, "received": 200, "cambio": 106, "displayAmount": 200, "type": null, "id": 1774218539375}]	27	25	3
1129	V6211	50	2026-03-22 22:29:07.18392	PAID	5	[{"method": "EFECTIVO", "amount": 50, "received": 50, "cambio": 0, "displayAmount": 50, "type": null, "id": 1774218568004}]	27	21	3
1136	V4244	84	2026-03-22 22:42:10.035446	PAID	5	[{"method": "EFECTIVO", "amount": 84, "received": 200, "cambio": 116, "displayAmount": 200, "type": null, "id": 1774219342729}]	27	25	3
1137	V9889	122	2026-03-22 22:42:49.430266	PAID	4	[{"method": "EFECTIVO", "amount": 122, "received": 500, "cambio": 378, "displayAmount": 500, "type": null, "id": 1774219386241}]	27	28	3
1140	V3975	46	2026-03-22 22:47:51.597724	PAID	4	[{"method": "EFECTIVO", "amount": 46, "displayAmount": 46, "type": null, "id": 1774467351858, "received": 46, "cambio": 0}]	31	20	20
1150	V9722	90	2026-03-22 23:17:54.710531	PAID	3	[{"method": "EFECTIVO", "amount": 90, "received": 90, "cambio": 0, "displayAmount": 90, "type": null, "id": 1774221482087}]	27	31	3
1154	V9244	207	2026-03-22 23:30:48.242498	PAID	5	[{"method": "EFECTIVO", "amount": 207, "received": 500, "cambio": 293, "displayAmount": 500, "type": null, "id": 1774222257628}]	27	25	3
1157	V7841	111	2026-03-22 23:35:33.244327	PAID	3	[{"method": "EFECTIVO", "amount": 111, "received": 200, "cambio": 89, "displayAmount": 200, "type": null, "id": 1774222561565}]	27	33	3
1158	V2910	32	2026-03-22 23:36:06.167449	PAID	5	[{"method": "EFECTIVO", "amount": 32, "received": 32, "cambio": 0, "displayAmount": 32, "type": null, "id": 1774222597918}]	27	25	3
1159	V6344	74	2026-03-22 23:36:12.600275	PAID	4	[{"method": "EFECTIVO", "amount": 74, "received": 100, "cambio": 26, "displayAmount": 100, "type": null, "id": 1774222609065}]	27	29	3
1161	V2577	143	2026-03-22 23:40:09.36088	PAID	5	[{"method": "EFECTIVO", "amount": 143, "received": 500, "cambio": 357, "displayAmount": 500, "type": null, "id": 1774222817657}]	27	25	3
1163	V5967	360	2026-03-22 23:43:53.863814	PAID	1	[{"method": "EFECTIVO", "amount": 360, "received": 400, "cambio": 40, "displayAmount": 400, "type": null, "id": 1774223046636}]	27	26	3
1166	V5195	104	2026-03-22 23:49:01.103119	PAID	3	[{"method": "EFECTIVO", "amount": 104, "received": 104, "cambio": 0, "displayAmount": 104, "type": null, "id": 1774223361875}]	27	29	3
1172	V6359	172	2026-03-23 00:00:30.791861	PAID	3	[{"method": "EFECTIVO", "amount": 172, "received": 200, "cambio": 28, "displayAmount": 200, "type": null, "id": 1774224038595}]	27	25	3
1173	V6029	89	2026-03-23 00:01:18.901045	PAID	4	[{"method": "EFECTIVO", "amount": 89, "received": 200, "cambio": 111, "displayAmount": 200, "type": null, "id": 1774224104092}]	27	28	3
1174	V1272	118	2026-03-23 00:05:05.688929	PAID	3	[{"method": "EFECTIVO", "amount": 118, "received": 120, "cambio": 2, "displayAmount": 120, "type": null, "id": 1774224324529}]	27	28	3
1175	V8417	74	2026-03-23 00:05:56.391061	PAID	3	[{"method": "EFECTIVO", "amount": 74, "received": 500, "cambio": 426, "displayAmount": 500, "type": null, "id": 1774224363701}]	27	28	3
1178	V1359	98	2026-03-23 00:08:21.295742	PAID	5	[{"method": "EFECTIVO", "amount": 98, "received": 98, "cambio": 0, "displayAmount": 98, "type": null, "id": 1774224543581}]	27	25	3
1179	V4395	140	2026-03-23 00:14:56.336865	PAID	5	[{"method": "EFECTIVO", "amount": 140, "received": 140, "cambio": 0, "displayAmount": 140, "type": null, "id": 1774224924554}]	27	25	3
1180	V3769	32	2026-03-23 00:17:15.281989	PAID	3	[{"method": "EFECTIVO", "amount": 32, "received": 32, "cambio": 0, "displayAmount": 32, "type": null, "id": 1774225125285}]	27	28	3
1183	V4000	69	2026-03-23 00:25:18.607033	PAID	3	[{"method": "EFECTIVO", "amount": 69, "received": 69, "cambio": 0, "displayAmount": 69, "type": null, "id": 1774225543998}]	27	25	3
1187	V4547	24	2026-03-23 00:31:55.655041	PAID	3	[{"method": "EFECTIVO", "amount": 24, "received": 24, "cambio": 0, "displayAmount": 24, "type": null, "id": 1774225922269}]	27	25	3
2255	V8228	54	2026-03-26 03:05:21.851655	PAID	4	[{"method": "EFECTIVO", "amount": 54, "received": 100, "cambio": 46, "displayAmount": 100, "type": null, "id": 1774494350002}]	35	24	3
1142	V4728	100	2026-03-22 22:50:56.581311	PAID	3	[{"method": "EFECTIVO", "amount": 100, "received": 500, "cambio": 400, "displayAmount": 500, "type": null, "id": 1774622881027}]	71	17	20
1191	V1981	86	2026-03-23 00:47:26.798682	PAID	4	[{"method": "EFECTIVO", "amount": 86, "received": 500, "cambio": 414, "displayAmount": 500, "type": null, "id": 1774226857235}]	27	21	3
978	V3440	88	2026-03-22 14:42:17.245637	PAID	5	[{"method": "EFECTIVO", "amount": 88, "received": 88, "cambio": 0, "displayAmount": 88, "type": null, "id": 1774226977749}]	27	3	3
1196	V5493	186	2026-03-23 00:52:47.567145	PAID	5	[{"method": "EFECTIVO", "amount": 186, "received": 200, "cambio": 14, "displayAmount": 200, "type": null, "id": 1774227179403}]	27	25	3
1197	V1185	43	2026-03-23 00:54:32.85254	PAID	4	[{"method": "EFECTIVO", "amount": 43, "received": 43, "cambio": 0, "displayAmount": 43, "type": null, "id": 1774227344104}]	27	28	3
1198	V3934	47	2026-03-23 00:56:19.878062	PAID	3	[{"method": "EFECTIVO", "amount": 47, "received": 47, "cambio": 0, "displayAmount": 47, "type": null, "id": 1774227400614}]	27	33	3
1219	V6517	244	2026-03-23 01:19:31.368202	PAID	3	[{"method": "EFECTIVO", "amount": 244, "received": 500, "cambio": 256, "displayAmount": 500, "type": null, "id": 1774228810456}]	27	33	3
1220	V1409	43	2026-03-23 01:22:39.122717	PAID	1	[{"method": "EFECTIVO", "amount": 43, "received": 100, "cambio": 57, "displayAmount": 100, "type": null, "id": 1774229014029}]	27	28	3
1228	V4762	66	2026-03-23 01:27:24.263792	PAID	5	[{"method": "EFECTIVO", "amount": 66, "received": 200, "cambio": 134, "displayAmount": 200, "type": null, "id": 1774229354862}]	27	29	3
1231	V4415	140	2026-03-23 01:29:54.124455	PAID	3	[{"method": "EFECTIVO", "amount": 140, "received": 140, "cambio": 0, "displayAmount": 140, "type": null, "id": 1774229470495}]	27	33	3
1278	V3630	203	2026-03-23 02:31:39.264375	PAID	2	[{"method": "EFECTIVO", "amount": 203, "received": 203, "cambio": 0, "displayAmount": 203, "type": null, "id": 1774233100666}]	27	3	\N
1217	V9660	69	2026-03-23 01:18:40.802093	PAID	4	[{"method": "EFECTIVO", "amount": 69, "received": 69, "cambio": 0, "displayAmount": 69, "type": null, "id": 1774231145210}]	27	21	3
1257	V9175	38	2026-03-23 02:02:10.516775	PAID	5	[{"method": "EFECTIVO", "amount": 38, "received": 38, "cambio": 0, "displayAmount": 38, "type": null, "id": 1774231370861}]	27	28	3
1258	V4007	78	2026-03-23 02:02:51.839811	PAID	3	[{"method": "EFECTIVO", "amount": 78, "received": 78, "cambio": 0, "displayAmount": 78, "type": null, "id": 1774231404311}]	27	33	3
1259	V6022	97	2026-03-23 02:04:12.178394	PAID	5	[{"method": "EFECTIVO", "amount": 97, "received": 97, "cambio": 0, "displayAmount": 97, "type": null, "id": 1774231506905}]	27	28	3
145	V1647	75	2026-03-19 14:30:11.506725	PAID	4	[{"method": "EFECTIVO", "amount": 75, "received": 100, "cambio": 25, "displayAmount": 100, "type": null, "id": 1774231886011}]	27	33	3
1268	V8465	85	2026-03-23 02:19:34.933561	PAID	3	[{"method": "EFECTIVO", "amount": 85, "received": 85, "cambio": 0, "displayAmount": 85, "type": null, "id": 1774232384883}]	27	25	3
1269	V3587	82	2026-03-23 02:20:49.584973	PAID	5	[{"method": "EFECTIVO", "amount": 82, "received": 200, "cambio": 118, "displayAmount": 200, "type": null, "id": 1774232463372}]	27	28	3
1273	V9989	44	2026-03-23 02:23:42.776462	PAID	3	[{"method": "EFECTIVO", "amount": 44, "received": 44, "cambio": 0, "displayAmount": 44, "type": null, "id": 1774232674809}]	27	25	3
2651	V5939	112	2026-03-27 16:05:17.186998	PAID	5	[{"method": "EFECTIVO", "amount": 112, "displayAmount": 112, "type": null, "id": 1774627532987, "received": 112, "cambio": 0}]	71	15	20
1256	V1069	28	2026-03-23 01:59:43.591759	PAID	5	[{"method": "EFECTIVO", "amount": 28, "received": 28, "cambio": 0, "displayAmount": 28, "type": null, "id": 1774310485072}]	28	9	20
1275	V4526	76	2026-03-23 02:25:02.60723	PAID	3	[{"method": "EFECTIVO", "amount": 76, "received": 76, "cambio": 0, "displayAmount": 76, "type": null, "id": 1774479397668}]	35	24	3
2251	V4130	25	2026-03-26 02:47:40.421345	PAID	5	[{"method": "EFECTIVO", "amount": 25, "received": 25, "cambio": 0, "displayAmount": 25, "type": null, "id": 1774495375911}]	35	18	3
2259	V5306	56	2026-03-26 03:09:40.462078	PAID	5	[{"method": "EFECTIVO", "amount": 56, "received": 56, "cambio": 0, "displayAmount": 56, "type": null, "id": 1774495386022}]	35	8	3
2266	V6343	24	2026-03-26 03:21:51.309691	PAID	5	[{"method": "EFECTIVO", "amount": 24, "received": 24, "cambio": 0, "displayAmount": 24, "type": null, "id": 1774495408026}]	35	8	3
2542	V6448	71	2026-03-27 02:37:58.032293	PAID	6	[{"method": "EFECTIVO", "amount": 71, "received": 100, "cambio": 29, "displayAmount": 100, "type": null, "id": 1774579127937}]	70	24	1
1255	V6756	17	2026-03-23 01:59:17.770158	PAID	3	[{"method": "EFECTIVO", "amount": 17, "received": 17, "cambio": 0, "displayAmount": 17, "type": null, "id": 1774580681553}]	70	9	1
2550	V2673	94	2026-03-27 02:59:29.200957	PAID	3	[{"method": "EFECTIVO", "amount": 94, "received": 94, "cambio": 0, "displayAmount": 94, "type": null, "id": 1774580779801}]	70	24	1
2552	V8103	82	2026-03-27 03:03:20.037297	PAID	5	[{"method": "EFECTIVO", "amount": 82, "received": 82, "cambio": 0, "displayAmount": 82, "type": null, "id": 1774580830511}]	70	4	1
1447	V4548	30	2026-03-24 00:15:43.271647	PAID	4	[{"method": "EFECTIVO", "amount": 30, "received": 30, "cambio": 0, "displayAmount": 30, "type": null, "id": 1774580847810}]	70	24	1
2558	V6489	34	2026-03-27 03:27:08.794745	PAID	3	[{"method": "EFECTIVO", "amount": 34, "received": 200, "cambio": 166, "displayAmount": 200, "type": null, "id": 1774582046426}]	70	24	1
2560	V1863	44	2026-03-27 03:28:31.669173	PAID	3	[{"method": "EFECTIVO", "amount": 44, "received": 100, "cambio": 56, "displayAmount": 100, "type": null, "id": 1774582117548}]	70	24	1
2258	V1212	21	2026-03-26 03:07:07.481585	PAID	3	[{"method": "EFECTIVO", "amount": 21, "displayAmount": 21, "type": null, "id": 1774621616998, "received": 21, "cambio": 0}]	71	15	20
2627	V6771	60	2026-03-27 15:09:44.184035	PAID	5	[{"method": "EFECTIVO", "amount": 60, "displayAmount": 60, "type": null, "id": 1774624241591, "received": 60, "cambio": 0}]	71	15	20
2628	V4945	39	2026-03-27 15:11:45.750467	PAID	3	[{"method": "EFECTIVO", "amount": 39, "displayAmount": 50, "type": null, "id": 1774624314584, "received": 50, "cambio": 11}]	71	17	20
2632	V9371	73	2026-03-27 15:16:23.433272	PAID	6	[{"method": "EFECTIVO", "amount": 73, "displayAmount": 100, "type": null, "id": 1774624596708, "received": 100, "cambio": 27}]	71	20	20
2642	V7533	31	2026-03-27 15:47:31.176624	PAID	4	[{"method": "EFECTIVO", "amount": 31, "displayAmount": 200, "type": null, "id": 1774626459323, "received": 200, "cambio": 169}]	71	15	20
2646	V5653	29	2026-03-27 15:54:13.897371	PAID	6	[{"method": "EFECTIVO", "amount": 29, "displayAmount": 29, "type": null, "id": 1774626915494, "received": 29, "cambio": 0}]	71	17	20
2659	V1367	128	2026-03-27 17:26:04.092365	PAID	1	[{"method": "EFECTIVO", "amount": 128, "displayAmount": 128, "type": null, "id": 1774632394868, "received": 128, "cambio": 0}]	71	20	20
2334	V8797	46	2026-03-26 14:45:36.5906	PAID	3	[{"method": "EFECTIVO", "amount": 46, "displayAmount": 46, "type": null, "id": 1774632631590, "received": 46, "cambio": 0}]	71	17	20
2654	V1957	42	2026-03-27 16:25:23.229147	PAID	3	[{"method": "EFECTIVO", "amount": 42, "displayAmount": 42, "type": null, "id": 1774632670465, "received": 42, "cambio": 0}]	71	17	20
981	V3443	19	2026-03-22 14:45:05.556205	PAID	3	[{"method": "EFECTIVO", "amount": 19, "displayAmount": 19, "type": null, "id": 1774632685515, "received": 19, "cambio": 0}]	71	17	20
2656	V3799	50	2026-03-27 17:02:37.735071	PAID	1	[{"method": "EFECTIVO", "amount": 50, "displayAmount": 50, "type": null, "id": 1774632772025, "received": 50, "cambio": 0}]	71	20	20
2657	V3159	8	2026-03-27 17:02:48.766315	PAID	1	[{"method": "EFECTIVO", "amount": 8, "displayAmount": 8, "type": null, "id": 1774632779953, "received": 8, "cambio": 0}]	71	20	20
2658	V8883	44	2026-03-27 17:06:37.949556	PAID	1	[{"method": "EFECTIVO", "amount": 44, "displayAmount": 44, "type": null, "id": 1774632786060, "received": 44, "cambio": 0}]	71	20	20
2661	V7060	86	2026-03-27 17:48:37.252277	PAID	5	[{"method": "EFECTIVO", "amount": 86, "displayAmount": 200, "type": null, "id": 1774633736812, "received": 200, "cambio": 114}]	71	15	20
2662	V8801	157	2026-03-27 18:01:23.304409	PAID	1	[{"method": "EFECTIVO", "amount": 157, "displayAmount": 157, "type": null, "id": 1774634495009, "received": 157, "cambio": 0}]	71	20	20
2663	V4407	56	2026-03-27 19:35:50.788761	PAID	2	[{"method": "EFECTIVO", "amount": 56, "displayAmount": 100, "type": null, "id": 1774640150128, "received": 100, "cambio": 44}]	71	20	\N
1261	V5573	137	2026-03-23 02:07:55.879953	PAID	3	[{"method": "EFECTIVO", "amount": 137, "received": 137, "cambio": 0, "displayAmount": 137, "type": null, "id": 1774231699258}]	27	33	3
2256	V1799	158	2026-03-26 03:05:36.250439	PAID	3	[{"method": "EFECTIVO", "amount": 158, "received": 158, "cambio": 0, "displayAmount": 158, "type": null, "id": 1774494462498}]	35	18	3
1266	V1049	124	2026-03-23 02:14:58.779731	PAID	3	[{"method": "EFECTIVO", "amount": 124, "received": 200, "cambio": 76, "displayAmount": 200, "type": null, "id": 1774232120162}]	27	33	3
1267	V4538	88	2026-03-23 02:16:37.940574	PAID	5	[{"method": "EFECTIVO", "amount": 88, "received": 200, "cambio": 112, "displayAmount": 200, "type": null, "id": 1774232210422}]	27	25	3
2260	V9674	119	2026-03-26 03:11:28.220489	PAID	5	[{"method": "EFECTIVO", "amount": 119, "received": 119, "cambio": 0, "displayAmount": 119, "type": null, "id": 1774494727529}]	35	24	3
1260	V5534	134	2026-03-23 02:05:35.975877	PAID	5	[{"method": "EFECTIVO", "amount": 134, "received": 134, "cambio": 0, "displayAmount": 134, "type": null, "id": 1774308625715}]	28	4	20
2267	V5794	49	2026-03-26 03:22:25.580484	PAID	3	[{"method": "EFECTIVO", "amount": 49, "received": 49, "cambio": 0, "displayAmount": 49, "type": null, "id": 1774495369757}]	35	18	3
1262	V6865	64	2026-03-23 02:09:07.3373	PAID	5	[{"method": "EFECTIVO", "amount": 64, "displayAmount": 64, "type": null, "id": 1774360938618, "received": 64, "cambio": 0}]	29	17	20
2262	V5469	22	2026-03-26 03:15:04.811884	PAID	5	[{"method": "EFECTIVO", "amount": 22, "received": 22, "cambio": 0, "displayAmount": 22, "type": null, "id": 1774495393879}]	35	18	3
1274	V3223	163	2026-03-23 02:24:28.560009	PAID	5	[{"method": "EFECTIVO", "amount": 163, "received": 500, "cambio": 337, "displayAmount": 500, "type": null, "id": 1774482493166}]	35	18	3
1271	V9924	44	2026-03-23 02:22:20.552735	PAID	5	[{"method": "EFECTIVO", "amount": 44, "received": 200, "cambio": 156, "displayAmount": 200, "type": null, "id": 1774487778267}]	35	24	3
2268	V1451	43	2026-03-26 03:35:38.601396	PAID	3	[{"method": "EFECTIVO", "amount": 43, "received": 43, "cambio": 0, "displayAmount": 43, "type": null, "id": 1774497056958}]	36	18	3
2264	V6318	107	2026-03-26 03:18:28.751173	PAID	5	[{"method": "EFECTIVO", "amount": 107, "received": 200, "cambio": 93, "displayAmount": 200, "type": null, "id": 1774579655082}]	70	24	1
2074	V6776	36	2026-03-25 16:02:54.885291	PAID	5	[{"method": "EFECTIVO", "amount": 36, "displayAmount": 40, "type": null, "id": 1774581658196, "received": 40, "cambio": 4}]	70	1	1
2559	V9927	123	2026-03-27 03:28:00.914682	PAID	5	[{"method": "EFECTIVO", "amount": 123, "received": 150, "cambio": 27, "displayAmount": 150, "type": null, "id": 1774582095628}]	70	4	1
2635	V2093	140	2026-03-27 15:23:39.807526	PAID	1	[{"method": "EFECTIVO", "amount": 140, "displayAmount": 200, "type": null, "id": 1774625026456, "received": 200, "cambio": 60}]	71	20	20
2639	V4433	43	2026-03-27 15:40:56.410141	PAID	3	[{"method": "EFECTIVO", "amount": 43, "displayAmount": 100, "type": null, "id": 1774626063965, "received": 100, "cambio": 57}]	71	17	20
2645	V9626	29	2026-03-27 15:53:54.209875	PAID	4	[{"method": "EFECTIVO", "amount": 29, "displayAmount": 29, "type": null, "id": 1774626863066, "received": 29, "cambio": 0}]	71	15	20
2647	V6620	25	2026-03-27 15:54:43.651662	PAID	3	[{"method": "EFECTIVO", "amount": 25, "displayAmount": 25, "type": null, "id": 1774626957119, "received": 25, "cambio": 0}]	71	17	20
2650	V2886	68	2026-03-27 16:04:07.875916	PAID	3	[{"method": "EFECTIVO", "amount": 68, "received": 100, "cambio": 32, "displayAmount": 100, "type": null, "id": 1774627474287}]	71	17	20
2652	V4066	81	2026-03-27 16:15:14.521133	PAID	3	[{"method": "EFECTIVO", "amount": 81, "displayAmount": 81, "type": null, "id": 1774632647761, "received": 81, "cambio": 0}]	71	17	20
2638	V8823	55	2026-03-27 15:32:57.743558	PAID	1	[{"method": "EFECTIVO", "amount": 55, "displayAmount": 55, "type": null, "id": 1774632745670, "received": 55, "cambio": 0}]	71	20	20
2637	V2734	13	2026-03-27 15:32:26.178265	PAID	1	[{"method": "EFECTIVO", "amount": 13, "displayAmount": 13, "type": null, "id": 1774632761603, "received": 13, "cambio": 0}]	71	20	20
2031	V9791	88	2026-03-25 14:41:08.393208	PAID	3	[{"method": "EFECTIVO", "amount": 88, "displayAmount": 100, "type": null, "id": 1774638453962, "received": 100, "cambio": 12}]	71	20	20
1606	V7238	170	2026-03-24 03:15:29.723073	PAID	3	[{"method": "EFECTIVO", "amount": 170, "displayAmount": 200, "type": null, "id": 1774638865290, "received": 200, "cambio": 30}]	71	20	20
1263	V1901	63	2026-03-23 02:10:41.004853	PAID	1	[{"method": "EFECTIVO", "amount": 63, "received": 63, "cambio": 0, "displayAmount": 63, "type": null, "id": 1774231879652}]	27	26	3
1264	V8631	94	2026-03-23 02:12:30.321602	PAID	5	[{"method": "EFECTIVO", "amount": 94, "received": 94, "cambio": 0, "displayAmount": 94, "type": null, "id": 1774231975651}]	27	28	3
1270	V4908	104	2026-03-23 02:21:39.473892	PAID	3	[{"method": "EFECTIVO", "amount": 104, "received": 500, "cambio": 396, "displayAmount": 500, "type": null, "id": 1774232512202}]	27	25	3
1272	V2544	47	2026-03-23 02:22:50.833448	PAID	3	[{"method": "EFECTIVO", "amount": 47, "received": 47, "cambio": 0, "displayAmount": 47, "type": null, "id": 1774232588467}]	27	25	3
1276	V1720	91	2026-03-23 02:26:01.62596	PAID	3	[{"method": "EFECTIVO", "amount": 91, "received": 91, "cambio": 0, "displayAmount": 91, "type": null, "id": 1774232787502}]	27	25	3
1277	V4730	45	2026-03-23 02:29:28.046864	PAID	3	[{"method": "EFECTIVO", "amount": 45, "received": 45, "cambio": 0, "displayAmount": 45, "type": null, "id": 1774232977317}]	27	25	3
1279	V3196	50	2026-03-23 02:35:26.661694	PAID	3	[{"method": "EFECTIVO", "amount": 50, "received": 50, "cambio": 0, "displayAmount": 50, "type": null, "id": 1774233352232}]	27	33	3
1285	V9937	77	2026-03-23 02:43:09.25793	PAID	5	[{"method": "EFECTIVO", "amount": 77, "received": 200, "cambio": 123, "displayAmount": 200, "type": null, "id": 1774233802893}]	27	25	3
1286	V5119	80	2026-03-23 02:44:33.872404	PAID	5	[{"method": "EFECTIVO", "amount": 80, "received": 80, "cambio": 0, "displayAmount": 80, "type": null, "id": 1774233892825}]	27	25	3
1287	V7927	86	2026-03-23 02:44:59.814432	PAID	3	[{"method": "EFECTIVO", "amount": 86, "received": 90, "cambio": 4, "displayAmount": 90, "type": null, "id": 1774233923883}]	27	33	3
1288	V3367	89	2026-03-23 02:46:11.8421	PAID	5	[{"method": "EFECTIVO", "amount": 89, "received": 100, "cambio": 11, "displayAmount": 100, "type": null, "id": 1774233982291}]	27	25	3
1293	V6008	67	2026-03-23 03:22:46.031198	PAID	6	[{"method": "EFECTIVO", "amount": 67, "received": 100, "cambio": 33, "displayAmount": 100, "type": null, "id": 1774236194428}]	27	25	3
1295	V2702	59	2026-03-23 03:36:03.409036	PAID	6	[{"method": "EFECTIVO", "amount": 59, "received": 100, "cambio": 41, "displayAmount": 100, "type": null, "id": 1774236971997}]	27	25	3
2261	V7020	64	2026-03-26 03:13:26.746714	PAID	6	[{"method": "EFECTIVO", "amount": 64, "received": 64, "cambio": 0, "displayAmount": 64, "type": null, "id": 1774494896866}]	35	8	3
1265	V8845	13	2026-03-23 02:12:57.4645	PAID	5	[{"method": "EFECTIVO", "amount": 13, "received": 13, "cambio": 0, "displayAmount": 13, "type": null, "id": 1774277625731}]	28	28	20
1282	V6319	61	2026-03-23 02:40:12.829639	PAID	3	[{"method": "EFECTIVO", "amount": 61, "displayAmount": 100, "type": null, "id": 1774279446764, "received": 100, "cambio": 39}]	28	16	20
1280	V8080	105	2026-03-23 02:37:52.222087	PAID	5	[{"method": "EFECTIVO", "amount": 105, "received": 105, "cambio": 0, "displayAmount": 105, "type": null, "id": 1774300118866}]	28	4	20
2265	V6867	81	2026-03-26 03:21:07.08905	PAID	3	[{"method": "EFECTIVO", "amount": 81, "received": 81, "cambio": 0, "displayAmount": 81, "type": null, "id": 1774495322493}]	35	18	3
1297	V3129	66	2026-03-23 03:37:25.907685	PAID	6	[{"method": "EFECTIVO", "amount": 66, "received": 100, "cambio": 34, "displayAmount": 100, "type": null, "id": 1774484932159}]	35	8	3
2263	V4573	46	2026-03-26 03:16:32.518071	PAID	3	[{"method": "EFECTIVO", "amount": 46, "received": 46, "cambio": 0, "displayAmount": 46, "type": null, "id": 1774495363566}]	35	18	3
2563	V8011	65	2026-03-27 13:02:31.582021	PAID	5	[{"method": "EFECTIVO", "amount": 65, "displayAmount": 100, "type": null, "id": 1774616575218, "received": 100, "cambio": 35}]	71	15	20
2564	V7679	59	2026-03-27 13:03:22.820717	PAID	5	[{"method": "EFECTIVO", "amount": 59, "displayAmount": 100, "type": null, "id": 1774616620653, "received": 100, "cambio": 41}]	71	15	20
2565	V2094	39	2026-03-27 13:08:21.693923	PAID	5	[{"method": "EFECTIVO", "amount": 39, "displayAmount": 50, "type": null, "id": 1774616908218, "received": 50, "cambio": 11}]	71	15	20
2567	V6078	44	2026-03-27 13:14:46.389631	PAID	4	[{"method": "EFECTIVO", "amount": 44, "displayAmount": 50, "type": null, "id": 1774617294859, "received": 50, "cambio": 6}]	71	20	20
2568	V8660	114	2026-03-27 13:15:05.375094	PAID	5	[{"method": "EFECTIVO", "amount": 114, "displayAmount": 150, "type": null, "id": 1774617320154, "received": 150, "cambio": 36}]	71	15	20
2569	V8198	40	2026-03-27 13:16:30.261204	PAID	3	[{"method": "EFECTIVO", "amount": 40, "displayAmount": 50, "type": null, "id": 1774617404363, "received": 50, "cambio": 10}]	71	15	20
2571	V9649	38	2026-03-27 13:17:26.558626	PAID	3	[{"method": "EFECTIVO", "amount": 38, "displayAmount": 100, "type": null, "id": 1774617463638, "received": 100, "cambio": 62}]	71	15	20
2575	V9235	14	2026-03-27 13:21:24.102666	PAID	3	[{"method": "EFECTIVO", "amount": 14, "displayAmount": 14, "type": null, "id": 1774617710053, "received": 14, "cambio": 0}]	71	15	20
2576	V7511	32	2026-03-27 13:31:14.653965	PAID	5	[{"method": "EFECTIVO", "amount": 32, "displayAmount": 32, "type": null, "id": 1774618293472, "received": 32, "cambio": 0}]	71	15	20
2580	V1753	44	2026-03-27 13:45:59.972087	PAID	5	[{"method": "EFECTIVO", "amount": 44, "displayAmount": 100, "type": null, "id": 1774619188506, "received": 100, "cambio": 56}]	71	15	20
2581	V8044	42	2026-03-27 13:46:34.862982	PAID	4	[{"method": "EFECTIVO", "amount": 42, "displayAmount": 42, "type": null, "id": 1774619224726, "received": 42, "cambio": 0}]	71	14	20
2584	V4733	81	2026-03-27 13:49:01.829643	PAID	4	[{"method": "EFECTIVO", "amount": 81, "displayAmount": 100, "type": null, "id": 1774619372507, "received": 100, "cambio": 19}]	71	14	20
2582	V7306	27	2026-03-27 13:47:32.131685	PAID	5	[{"method": "EFECTIVO", "amount": 27, "displayAmount": 27, "type": null, "id": 1774619448725, "received": 27, "cambio": 0}]	71	15	20
2589	V6779	23	2026-03-27 13:53:42.105179	PAID	5	[{"method": "EFECTIVO", "amount": 23, "displayAmount": 100, "type": null, "id": 1774619628122, "received": 100, "cambio": 77}]	71	17	20
2590	V9808	59	2026-03-27 13:54:02.337737	PAID	3	[{"method": "EFECTIVO", "amount": 59, "displayAmount": 100, "type": null, "id": 1774619653164, "received": 100, "cambio": 41}]	71	16	20
2592	V4788	36	2026-03-27 13:59:09.573613	PAID	3	[{"method": "EFECTIVO", "amount": 36, "displayAmount": 200, "type": null, "id": 1774619965966, "received": 200, "cambio": 164}]	71	16	20
2591	V8113	52	2026-03-27 13:57:29.895892	PAID	3	[{"method": "EFECTIVO", "amount": 52, "displayAmount": 52, "type": null, "id": 1774621707843, "received": 52, "cambio": 0}]	71	16	20
1281	V4544	120	2026-03-23 02:39:59.892259	PAID	5	[{"method": "EFECTIVO", "amount": 120, "received": 150, "cambio": 30, "displayAmount": 150, "type": null, "id": 1774233625466}]	27	25	3
1283	V6102	89	2026-03-23 02:41:52.479848	PAID	5	[{"method": "EFECTIVO", "amount": 89, "received": 100, "cambio": 11, "displayAmount": 100, "type": null, "id": 1774233728461}]	27	25	3
1284	V6852	47	2026-03-23 02:42:11.363199	PAID	3	[{"method": "EFECTIVO", "amount": 47, "received": 47, "cambio": 0, "displayAmount": 47, "type": null, "id": 1774233756983}]	27	33	3
1289	V6772	59	2026-03-23 02:58:34.270894	PAID	2	[{"method": "EFECTIVO", "amount": 59, "received": 100, "cambio": 41, "displayAmount": 100, "type": null, "id": 1774234715623}]	27	3	\N
1292	V1360	67	2026-03-23 03:16:03.276237	PAID	5	[{"method": "EFECTIVO", "amount": 67, "received": 67, "cambio": 0, "displayAmount": 67, "type": null, "id": 1774235789816}]	27	25	3
1294	V1075	57	2026-03-23 03:35:11.102735	PAID	5	[{"method": "EFECTIVO", "amount": 57, "received": 57, "cambio": 0, "displayAmount": 57, "type": null, "id": 1774237090183}]	27	25	3
1291	V5622	44	2026-03-23 03:11:16.926413	PAID	5	[{"method": "EFECTIVO", "amount": 44, "received": 44, "cambio": 0, "displayAmount": 44, "type": null, "id": 1774237100386}]	27	28	3
2270	V4522	35	2026-03-26 13:09:09.158988	PAID	5	[{"method": "EFECTIVO", "amount": 35, "displayAmount": 200, "type": null, "id": 1774530560073, "received": 200, "cambio": 165}]	69	14	20
2277	V4618	80	2026-03-26 13:21:56.181051	PAID	1	[{"method": "EFECTIVO", "amount": 80, "displayAmount": 100, "type": null, "id": 1774531329734, "received": 100, "cambio": 20}]	69	20	20
2278	V4883	89	2026-03-26 13:24:29.338204	PAID	3	[{"method": "EFECTIVO", "amount": 89, "displayAmount": 200, "type": null, "id": 1774531477149, "received": 200, "cambio": 111}]	69	14	20
2283	V1158	45	2026-03-26 13:34:59.78688	PAID	4	[{"method": "EFECTIVO", "amount": 45, "displayAmount": 45, "type": null, "id": 1774532151657, "received": 45, "cambio": 0}]	69	15	20
2269	V1623	50	2026-03-26 13:06:54.186496	PAID	1	[{"method": "EFECTIVO", "amount": 50, "received": 50, "cambio": 0, "displayAmount": 50, "type": null, "id": 1774581273671}]	70	24	1
2286	V2237	48	2026-03-26 13:37:32.664841	PAID	3	[{"method": "EFECTIVO", "amount": 48, "displayAmount": 100, "type": null, "id": 1774532263170, "received": 100, "cambio": 52}]	69	14	20
2289	V4819	75	2026-03-26 13:39:22.501816	PAID	4	[{"method": "EFECTIVO", "amount": 75, "displayAmount": 100, "type": null, "id": 1774532376998, "received": 100, "cambio": 25}]	69	15	20
2285	V4665	29	2026-03-26 13:36:45.844139	PAID	3	[{"method": "EFECTIVO", "amount": 29, "received": 29, "cambio": 0, "displayAmount": 29, "type": null, "id": 1774575104534}]	70	4	1
2294	V7803	15	2026-03-26 13:49:12.927419	PAID	5	[{"method": "EFECTIVO", "amount": 15, "displayAmount": 15, "type": null, "id": 1774532975199, "received": 15, "cambio": 0}]	69	14	20
2292	V8222	43	2026-03-26 13:46:25.106083	PAID	1	[{"method": "EFECTIVO", "amount": 43, "received": 43, "cambio": 0, "displayAmount": 43, "type": null, "id": 1774533237377}]	69	20	20
2303	V7810	48	2026-03-26 14:00:47.373231	PAID	3	[{"method": "EFECTIVO", "amount": 48, "displayAmount": 48, "type": null, "id": 1774533785558, "received": 48, "cambio": 0}]	69	17	20
2309	V4240	46	2026-03-26 14:06:48.583753	PAID	3	[{"method": "EFECTIVO", "amount": 46, "displayAmount": 46, "type": null, "id": 1774534028224, "received": 46, "cambio": 0}]	69	17	20
2311	V8907	65	2026-03-26 14:07:45.518398	PAID	3	[{"method": "EFECTIVO", "amount": 65, "received": 65, "cambio": 0, "displayAmount": 65, "type": null, "id": 1774534090562}]	69	17	20
2312	V3241	87	2026-03-26 14:08:35.724039	PAID	4	[{"method": "EFECTIVO", "amount": 87, "displayAmount": 100, "type": null, "id": 1774534133571, "received": 100, "cambio": 13}]	69	14	20
2313	V1897	39	2026-03-26 14:09:13.574108	PAID	3	[{"method": "EFECTIVO", "amount": 39, "displayAmount": 100, "type": null, "id": 1774616652897, "received": 100, "cambio": 61}]	71	15	20
2314	V5607	27	2026-03-26 14:09:53.405014	PAID	4	[{"method": "EFECTIVO", "amount": 27, "displayAmount": 50, "type": null, "id": 1774534207812, "received": 50, "cambio": 23}]	69	14	20
2325	V1308	64	2026-03-26 14:25:55.315523	PAID	5	[{"method": "EFECTIVO", "amount": 64, "displayAmount": 100, "type": null, "id": 1774535168723, "received": 100, "cambio": 36}]	69	14	20
2328	V6488	97	2026-03-26 14:31:01.848832	PAID	3	[{"method": "EFECTIVO", "amount": 97, "displayAmount": 100, "type": null, "id": 1774535479135, "received": 100, "cambio": 3}]	69	15	20
2329	V8277	35	2026-03-26 14:32:11.828771	PAID	3	[{"method": "EFECTIVO", "amount": 35, "displayAmount": 50, "type": null, "id": 1774535539128, "received": 50, "cambio": 15}]	69	15	20
2330	V6069	39	2026-03-26 14:32:52.106068	PAID	3	[{"method": "EFECTIVO", "amount": 39, "displayAmount": 40, "type": null, "id": 1774535581335, "received": 40, "cambio": 1}]	69	15	20
2332	V2610	79	2026-03-26 14:43:29.244793	PAID	3	[{"method": "EFECTIVO", "amount": 79, "displayAmount": 200, "type": null, "id": 1774536219108, "received": 200, "cambio": 121}]	69	17	20
2326	V8661	23	2026-03-26 14:28:30.960562	PAID	5	[{"method": "EFECTIVO", "amount": 23, "displayAmount": 23, "type": null, "id": 1774536441261, "received": 23, "cambio": 0}]	69	14	20
2335	V1311	108	2026-03-26 14:53:25.763776	PAID	3	[{"method": "EFECTIVO", "amount": 108, "displayAmount": 200, "type": null, "id": 1774536828432, "received": 200, "cambio": 92}]	69	14	20
2337	V9548	21	2026-03-26 14:54:50.35501	PAID	3	[{"method": "EFECTIVO", "amount": 21, "displayAmount": 100, "type": null, "id": 1774536898561, "received": 100, "cambio": 79}]	69	14	20
2338	V3188	42	2026-03-26 14:55:35.885467	PAID	3	[{"method": "EFECTIVO", "amount": 42, "displayAmount": 50, "type": null, "id": 1774536942180, "received": 50, "cambio": 8}]	69	14	20
2348	V7654	61	2026-03-26 15:25:27.538176	PAID	6	[{"method": "EFECTIVO", "amount": 61, "displayAmount": 100, "type": null, "id": 1774538732738, "received": 100, "cambio": 39}]	69	20	20
2349	V9393	79	2026-03-26 15:26:28.766348	PAID	6	[{"method": "EFECTIVO", "amount": 79, "received": 100, "cambio": 21, "displayAmount": 100, "type": null, "id": 1774566311661}]	70	13	1
2357	V3770	110	2026-03-26 15:58:44.724209	PAID	6	[{"method": "EFECTIVO", "amount": 110, "displayAmount": 110, "type": null, "id": 1774540730968, "received": 110, "cambio": 0}]	69	20	20
2353	V9897	66	2026-03-26 15:37:30.723632	PAID	5	[{"method": "EFECTIVO", "amount": 66, "displayAmount": 66, "type": null, "id": 1774542361229, "received": 66, "cambio": 0}]	69	15	20
1296	V4215	91	2026-03-23 03:36:53.723728	PAID	5	[{"method": "EFECTIVO", "amount": 91, "received": 100, "cambio": 9, "displayAmount": 100, "type": null, "id": 1774237025675}]	27	29	3
1307	V9360	22	2026-03-23 14:59:09.80451	PAID	5	[{"method": "EFECTIVO", "amount": 22, "received": 200, "cambio": 178, "displayAmount": 200, "type": null, "id": 1774277973741}]	28	15	20
1299	V7746	99	2026-03-23 14:48:55.782268	PAID	3	[{"method": "EFECTIVO", "amount": 99, "displayAmount": 99, "type": null, "id": 1774278047983, "received": 99, "cambio": 0}]	28	20	20
1311	V5139	62	2026-03-23 15:05:29.842159	PAID	5	[{"method": "EFECTIVO", "amount": 62, "displayAmount": 62, "type": null, "id": 1774278969019, "received": 62, "cambio": 0}]	28	17	20
1325	V1429	8	2026-03-23 15:22:23.174939	PAID	5	[{"method": "EFECTIVO", "amount": 8, "displayAmount": 8, "type": null, "id": 1774279635772, "received": 8, "cambio": 0}]	28	16	20
1327	V4729	32	2026-03-23 15:26:38.01518	PAID	5	[{"method": "EFECTIVO", "amount": 32, "displayAmount": 32, "type": null, "id": 1774279656558, "received": 32, "cambio": 0}]	28	16	20
1316	V6948	30	2026-03-23 15:10:33.187302	PAID	6	[{"method": "EFECTIVO", "amount": 30, "displayAmount": 30, "type": null, "id": 1774279665785, "received": 30, "cambio": 0}]	28	20	20
1328	V7575	50	2026-03-23 15:27:50.641565	PAID	5	[{"method": "EFECTIVO", "amount": 50, "displayAmount": 100, "type": null, "id": 1774279686688, "received": 100, "cambio": 50}]	28	16	20
1319	V4798	79	2026-03-23 15:13:12.888898	PAID	6	[{"method": "EFECTIVO", "amount": 79, "displayAmount": 79, "type": null, "id": 1774279712331, "received": 79, "cambio": 0}]	28	20	20
1321	V5236	43	2026-03-23 15:15:50.479261	PAID	6	[{"method": "EFECTIVO", "amount": 43, "displayAmount": 43, "type": null, "id": 1774279735444, "received": 43, "cambio": 0}]	28	20	20
1308	V4332	77	2026-03-23 15:02:49.361042	PAID	5	[{"method": "EFECTIVO", "amount": 77, "displayAmount": 77, "type": null, "id": 1774279749601, "received": 77, "cambio": 0}]	28	14	20
1331	V1299	38	2026-03-23 15:36:14.434793	PAID	6	[{"method": "EFECTIVO", "amount": 38, "displayAmount": 100, "type": null, "id": 1774280210064, "received": 100, "cambio": 62}]	28	20	20
1310	V3542	20	2026-03-23 15:03:36.542447	PAID	3	[{"method": "EFECTIVO", "amount": 20, "displayAmount": 20, "type": null, "id": 1774280710229, "received": 20, "cambio": 0}]	28	14	20
1334	V2619	21	2026-03-23 15:54:24.578169	PAID	6	[{"method": "EFECTIVO", "amount": 21, "displayAmount": 21, "type": null, "id": 1774281275529, "received": 21, "cambio": 0}]	28	20	20
1343	V4919	105	2026-03-23 16:45:38.112566	PAID	3	[{"method": "EFECTIVO", "amount": 105, "displayAmount": 200, "type": null, "id": 1774285093064, "received": 200, "cambio": 95}]	28	17	20
1354	V1088	11	2026-03-23 18:56:04.835192	PAID	5	[{"method": "EFECTIVO", "amount": 11, "displayAmount": 11, "type": null, "id": 1774297631310, "received": 11, "cambio": 0}]	28	16	20
1346	V2499	32	2026-03-23 16:59:16.198193	PAID	3	[{"method": "EFECTIVO", "amount": 32, "displayAmount": 32, "type": null, "id": 1774297284596, "received": 32, "cambio": 0}]	28	17	20
1347	V2225	30	2026-03-23 17:01:35.481539	PAID	3	[{"method": "EFECTIVO", "amount": 30, "displayAmount": 30, "type": null, "id": 1774297310264, "received": 30, "cambio": 0}]	28	17	20
1360	V1112	34	2026-03-23 20:21:53.575291	PAID	3	[{"method": "EFECTIVO", "amount": 34, "displayAmount": 100, "type": null, "id": 1774297342054, "received": 100, "cambio": 66}]	28	4	20
1362	V4694	55	2026-03-23 20:30:53.484585	PAID	3	[{"method": "EFECTIVO", "amount": 55, "received": 200, "cambio": 145, "displayAmount": 200, "type": null, "id": 1774627136866}]	71	17	20
1349	V2670	33	2026-03-23 17:56:56.073953	PAID	3	[{"method": "EFECTIVO", "amount": 33, "displayAmount": 33, "type": null, "id": 1774297402855, "received": 33, "cambio": 0}]	28	17	20
1351	V5865	12	2026-03-23 18:45:19.631159	PAID	5	[{"method": "EFECTIVO", "amount": 12, "displayAmount": 12, "type": null, "id": 1774297584530, "received": 12, "cambio": 0}]	28	16	20
2271	V4911	34	2026-03-26 13:15:30.022913	PAID	1	[{"method": "EFECTIVO", "amount": 34, "displayAmount": 34, "type": null, "id": 1774532168840, "received": 34, "cambio": 0}]	69	20	20
1368	V8779	14	2026-03-23 21:17:57.991893	PAID	3	[{"method": "EFECTIVO", "amount": 14, "received": 14, "cambio": 0, "displayAmount": 14, "type": null, "id": 1774301086658}]	28	4	20
1370	V1370	46	2026-03-23 21:51:58.855092	PAID	3	[{"method": "EFECTIVO", "amount": 46, "received": 100, "cambio": 54, "displayAmount": 100, "type": null, "id": 1774302728444}]	28	4	20
1344	V3062	32	2026-03-23 16:55:47.291746	PAID	3	[{"method": "EFECTIVO", "amount": 32, "displayAmount": 100, "type": null, "id": 1774530631103, "received": 100, "cambio": 68}]	69	14	20
1300	V5763	132	2026-03-23 14:49:46.510477	PAID	3	[{"method": "EFECTIVO", "amount": 132, "displayAmount": 200, "type": null, "id": 1774392947147, "received": 200, "cambio": 68}]	29	4	20
1290	V5285	119	2026-03-23 03:09:44.672818	PAID	5	[{"method": "EFECTIVO", "amount": 119, "received": 200, "cambio": 81, "displayAmount": 200, "type": null, "id": 1774485768607}]	35	24	3
1361	V9926	203	2026-03-23 20:22:40.266075	PAID	3	[{"method": "EFECTIVO", "amount": 203, "received": 203, "cambio": 0, "displayAmount": 203, "type": null, "id": 1774399179412}]	30	9	3
2273	V9807	66	2026-03-26 13:17:42.190222	PAID	3	[{"method": "EFECTIVO", "amount": 66, "displayAmount": 200, "type": null, "id": 1774531070332, "received": 200, "cambio": 134}]	69	14	20
2279	V5694	40	2026-03-26 13:25:43.545656	PAID	3	[{"method": "EFECTIVO", "amount": 40, "displayAmount": 200, "type": null, "id": 1774531550224, "received": 200, "cambio": 160}]	69	14	20
2287	V7263	158	2026-03-26 13:38:16.544117	PAID	4	[{"method": "EFECTIVO", "amount": 158, "received": 170, "cambio": 12, "displayAmount": 170, "type": null, "id": 1774571792351}]	70	9	1
2288	V2805	61	2026-03-26 13:38:24.716924	PAID	3	[{"method": "EFECTIVO", "amount": 61, "displayAmount": 61, "type": null, "id": 1774532344933, "received": 61, "cambio": 0}]	69	14	20
2275	V5019	51	2026-03-26 13:20:28.768955	PAID	3	[{"method": "EFECTIVO", "amount": 51, "displayAmount": 51, "type": null, "id": 1774532910499, "received": 51, "cambio": 0}]	69	14	20
2293	V2359	32	2026-03-26 13:48:30.413761	PAID	5	[{"method": "EFECTIVO", "amount": 32, "displayAmount": 102, "type": null, "id": 1774532927484, "received": 102, "cambio": 70}]	69	14	20
2282	V2753	19	2026-03-26 13:32:17.324652	PAID	3	[{"method": "EFECTIVO", "amount": 19, "received": 19, "cambio": 0, "displayAmount": 19, "type": null, "id": 1774533261701}]	69	14	20
1356	V9392	87	2026-03-23 19:04:37.626717	PAID	2	[{"method": "EFECTIVO", "amount": 87, "displayAmount": 100, "type": null, "id": 1774618466292, "received": 100, "cambio": 13}]	71	17	20
1302	V8108	160	2026-03-23 14:52:04.285468	PAID	5	[{"method": "EFECTIVO", "amount": 160, "displayAmount": 160, "type": null, "id": 1774277634691, "received": 160, "cambio": 0}]	28	17	20
1301	V5665	38	2026-03-23 14:50:52.703443	PAID	3	[{"method": "EFECTIVO", "amount": 38, "displayAmount": 38, "type": null, "id": 1774277648221, "received": 38, "cambio": 0}]	28	20	20
1305	V2836	59	2026-03-23 14:58:14.597856	PAID	4	[{"method": "EFECTIVO", "amount": 59, "displayAmount": 500, "type": null, "id": 1774277915399, "received": 500, "cambio": 441}]	28	14	20
1306	V8320	39	2026-03-23 14:58:29.244012	PAID	5	[{"method": "EFECTIVO", "amount": 39, "displayAmount": 39, "type": null, "id": 1774277999922, "received": 39, "cambio": 0}]	28	15	20
1303	V1440	70	2026-03-23 14:56:13.852007	PAID	1	[{"method": "EFECTIVO", "amount": 70, "displayAmount": 70, "type": null, "id": 1774278010695, "received": 70, "cambio": 0}]	28	20	20
1298	V5561	60	2026-03-23 14:46:19.075202	PAID	3	[{"method": "EFECTIVO", "amount": 60, "displayAmount": 60, "type": null, "id": 1774278150817, "received": 60, "cambio": 0}]	28	20	20
1314	V7455	2	2026-03-23 15:09:04.738106	PAID	6	[{"method": "EFECTIVO", "amount": 2, "displayAmount": 2, "type": null, "id": 1774279005138, "received": 2, "cambio": 0}]	28	20	20
1315	V1803	34	2026-03-23 15:09:24.160533	PAID	6	[{"method": "EFECTIVO", "amount": 34, "received": 34, "cambio": 0, "displayAmount": 34, "type": null, "id": 1774279014834}]	28	20	20
1323	V3756	31	2026-03-23 15:19:45.869443	PAID	2	[{"method": "EFECTIVO", "amount": 31, "displayAmount": 31, "type": null, "id": 1774279185937, "received": 31, "cambio": 0}]	28	20	\N
1326	V7853	111	2026-03-23 15:22:54.629722	PAID	5	[{"method": "EFECTIVO", "amount": 111, "displayAmount": 120, "type": null, "id": 1774538440862, "received": 120, "cambio": 9}]	69	20	20
1329	V7873	35	2026-03-23 15:34:09.779938	PAID	6	[{"method": "EFECTIVO", "amount": 35, "displayAmount": 100, "type": null, "id": 1774280070596, "received": 100, "cambio": 65}]	28	20	20
1330	V8461	32	2026-03-23 15:36:05.611819	PAID	1	[{"method": "EFECTIVO", "amount": 32, "displayAmount": 500, "type": null, "id": 1774280178454, "received": 500, "cambio": 468}]	28	20	20
1332	V3484	82	2026-03-23 15:41:41.001888	PAID	3	[{"method": "EFECTIVO", "amount": 82, "displayAmount": 100, "type": null, "id": 1774280513584, "received": 100, "cambio": 18}]	28	15	20
1335	V5417	96	2026-03-23 15:54:38.034705	PAID	5	[{"method": "EFECTIVO", "amount": 96, "displayAmount": 200, "type": null, "id": 1774281297768, "received": 200, "cambio": 104}]	28	15	20
1336	V4543	19	2026-03-23 15:57:55.19701	PAID	5	[{"method": "EFECTIVO", "amount": 19, "displayAmount": 19, "type": null, "id": 1774281763858, "received": 19, "cambio": 0}]	28	15	20
1342	V1502	20	2026-03-23 16:38:24.529463	PAID	3	[{"method": "EFECTIVO", "amount": 20, "displayAmount": 500, "type": null, "id": 1774283932361, "received": 500, "cambio": 480}]	28	20	20
1358	V3640	212	2026-03-23 19:41:35.708269	PAID	4	[{"method": "EFECTIVO", "amount": 212, "displayAmount": 212, "type": null, "id": 1774294939049, "received": 212, "cambio": 0}]	28	20	20
1353	V9095	20	2026-03-23 18:50:10.824441	PAID	5	[{"method": "EFECTIVO", "amount": 20, "displayAmount": 20, "type": null, "id": 1774297621286, "received": 20, "cambio": 0}]	28	14	20
1341	V9046	78	2026-03-23 16:33:33.711215	PAID	3	[{"method": "EFECTIVO", "amount": 78, "received": 78, "cambio": 0, "displayAmount": 78, "type": null, "id": 1774297666119}]	28	17	20
1340	V3643	31	2026-03-23 16:29:40.394559	PAID	3	[{"method": "EFECTIVO", "amount": 31, "displayAmount": 31, "type": null, "id": 1774297672893, "received": 31, "cambio": 0}]	28	17	20
1214	V8368	106	2026-03-23 01:11:30.857744	PAID	3	[{"method": "EFECTIVO", "amount": 106, "displayAmount": 106, "type": null, "id": 1774297680710, "received": 106, "cambio": 0}]	28	20	20
1366	V1089	61	2026-03-23 21:11:02.627115	PAID	3	[{"method": "EFECTIVO", "amount": 61, "received": 200, "cambio": 139, "displayAmount": 200, "type": null, "id": 1774300275464}]	28	4	20
1367	V4564	37	2026-03-23 21:12:40.160712	PAID	3	[{"method": "EFECTIVO", "amount": 37, "received": 50, "cambio": 13, "displayAmount": 50, "type": null, "id": 1774300368602}]	28	4	20
1369	V2449	26	2026-03-23 21:50:23.01791	PAID	3	[{"method": "EFECTIVO", "amount": 26, "received": 26, "cambio": 0, "displayAmount": 26, "type": null, "id": 1774302640624}]	28	4	20
1372	V3400	43	2026-03-23 22:01:42.737908	PAID	3	[{"method": "EFECTIVO", "amount": 43, "received": 100, "cambio": 57, "displayAmount": 100, "type": null, "id": 1774303321238}]	28	9	20
2274	V6838	36	2026-03-26 13:18:33.127073	PAID	3	[{"method": "EFECTIVO", "amount": 36, "displayAmount": 50, "type": null, "id": 1774531131287, "received": 50, "cambio": 14}]	69	14	20
1322	V5155	61	2026-03-23 15:18:13.496673	PAID	2	[{"method": "EFECTIVO", "amount": 61, "received": 100, "cambio": 39, "displayAmount": 100, "type": null, "id": 1774307318533}]	28	4	20
1313	V5523	76	2026-03-23 15:08:43.41002	PAID	6	[{"method": "EFECTIVO", "amount": 76, "received": 100, "cambio": 24, "displayAmount": 100, "type": null, "id": 1774308142573}]	28	18	20
1312	V9620	100	2026-03-23 15:06:46.834407	PAID	3	[{"method": "EFECTIVO", "amount": 100, "received": 100, "cambio": 0, "displayAmount": 100, "type": null, "id": 1774489020256}]	35	1	3
2280	V7244	66	2026-03-26 13:27:16.605132	PAID	3	[{"method": "EFECTIVO", "amount": 66, "displayAmount": 100, "type": null, "id": 1774531656152, "received": 100, "cambio": 34}]	69	14	20
2281	V8140	27	2026-03-26 13:29:05.013144	PAID	3	[{"method": "EFECTIVO", "amount": 27, "received": 27, "cambio": 0, "displayAmount": 27, "type": null, "id": 1774531790194}]	69	14	20
2272	V4310	82	2026-03-26 13:16:33.41104	PAID	5	[{"method": "EFECTIVO", "amount": 82, "displayAmount": 82, "type": null, "id": 1774532135092, "received": 82, "cambio": 0}]	69	14	20
2284	V9486	44	2026-03-26 13:36:15.863091	PAID	3	[{"method": "EFECTIVO", "amount": 44, "displayAmount": 50, "type": null, "id": 1774532187578, "received": 50, "cambio": 6}]	69	14	20
2290	V7703	63	2026-03-26 13:39:28.616304	PAID	3	[{"method": "EFECTIVO", "amount": 63, "displayAmount": 100, "type": null, "id": 1774532411185, "received": 100, "cambio": 37}]	69	14	20
943	V8914	29	2026-03-22 14:18:37.053887	PAID	3	[{"method": "EFECTIVO", "amount": 26, "displayAmount": 26, "type": null, "id": 1774532437694, "received": 26, "cambio": 0}, {"method": "EFECTIVO", "amount": 3, "displayAmount": 30, "type": null, "id": 1774532444966, "received": 30, "cambio": 27}]	69	14	20
2291	V3702	50	2026-03-26 13:40:10.980046	PAID	4	[{"method": "TARJETA", "amount": 50, "displayAmount": 50, "type": "DEBITO", "id": 1774532490946}]	69	15	20
1304	V9061	28	2026-03-23 14:57:51.838769	PAID	1	[{"method": "EFECTIVO", "amount": 28, "displayAmount": 28, "type": null, "id": 1774278020793, "received": 28, "cambio": 0}]	28	20	20
1309	V3583	31	2026-03-23 15:03:32.601491	PAID	5	[{"method": "EFECTIVO", "amount": 31, "received": 31, "cambio": 0, "displayAmount": 31, "type": null, "id": 1774278933202}]	28	20	20
1376	V5399	114	2026-03-23 22:12:36.094924	PAID	3	[{"method": "EFECTIVO", "amount": 114, "received": 114, "cambio": 0, "displayAmount": 114, "type": null, "id": 1774303986455}]	28	18	20
1318	V3266	62	2026-03-23 15:12:39.357947	PAID	5	[{"method": "EFECTIVO", "amount": 62, "displayAmount": 62, "type": null, "id": 1774278989564, "received": 62, "cambio": 0}]	28	16	20
1324	V8897	113	2026-03-23 15:22:14.593561	PAID	6	[{"method": "EFECTIVO", "amount": 113, "displayAmount": 200, "type": null, "id": 1774279344596, "received": 200, "cambio": 87}]	28	20	20
1320	V6101	2	2026-03-23 15:14:45.513313	PAID	6	[{"method": "EFECTIVO", "amount": 2, "displayAmount": 2, "type": null, "id": 1774632728136, "received": 2, "cambio": 0}]	71	15	20
1333	V9188	37	2026-03-23 15:42:29.544367	PAID	5	[{"method": "EFECTIVO", "amount": 37, "displayAmount": 500, "type": null, "id": 1774280563539, "received": 500, "cambio": 463}]	28	15	20
1337	V1718	58	2026-03-23 16:02:47.563642	PAID	5	[{"method": "EFECTIVO", "amount": 58, "displayAmount": 100, "type": null, "id": 1774281809013, "received": 100, "cambio": 42}]	28	15	20
1338	V3315	69	2026-03-23 16:10:34.654283	PAID	5	[{"method": "EFECTIVO", "amount": 69, "displayAmount": 100, "type": null, "id": 1774282245148, "received": 100, "cambio": 31}]	28	15	20
1339	V3342	63	2026-03-23 16:11:32.96539	PAID	5	[{"method": "EFECTIVO", "amount": 63, "displayAmount": 100, "type": null, "id": 1774282306601, "received": 100, "cambio": 37}]	28	15	20
1345	V1257	60	2026-03-23 16:56:55.523615	PAID	3	[{"method": "EFECTIVO", "amount": 60, "received": 200, "cambio": 140, "displayAmount": 200, "type": null, "id": 1774489835229}]	35	24	3
1348	V5121	313	2026-03-23 17:18:21.189905	PAID	3	[{"method": "EFECTIVO", "amount": 313, "displayAmount": 313, "type": null, "id": 1774470048438, "received": 313, "cambio": 0}]	32	4	20
1357	V5482	167	2026-03-23 19:10:56.657919	PAID	4	[{"method": "EFECTIVO", "amount": 167, "displayAmount": 207, "type": null, "id": 1774293078540, "received": 207, "cambio": 40}]	28	20	20
1317	V3168	174	2026-03-23 15:11:50.882565	PAID	5	[{"method": "EFECTIVO", "amount": 174, "displayAmount": 500, "type": null, "id": 1774294084234, "received": 500, "cambio": 326}]	28	20	20
1350	V3786	17	2026-03-23 18:43:50.189161	PAID	5	[{"method": "EFECTIVO", "amount": 17, "displayAmount": 17, "type": null, "id": 1774297576891, "received": 17, "cambio": 0}]	28	16	20
1352	V5257	24	2026-03-23 18:49:29.374515	PAID	5	[{"method": "EFECTIVO", "amount": 24, "displayAmount": 24, "type": null, "id": 1774297597895, "received": 24, "cambio": 0}]	28	14	20
1355	V7944	54	2026-03-23 18:57:13.171735	PAID	5	[{"method": "EFECTIVO", "amount": 54, "displayAmount": 54, "type": null, "id": 1774297640920, "received": 54, "cambio": 0}]	28	16	20
1363	V1634	32	2026-03-23 20:55:21.813844	PAID	3	[{"method": "EFECTIVO", "amount": 32, "received": 50, "cambio": 18, "displayAmount": 50, "type": null, "id": 1774299345766}]	28	4	20
1364	V3412	99	2026-03-23 21:02:52.575985	PAID	3	[{"method": "EFECTIVO", "amount": 99, "received": 99, "cambio": 0, "displayAmount": 99, "type": null, "id": 1774321525510}]	28	18	20
1365	V7619	123	2026-03-23 21:09:33.646824	PAID	3	[{"method": "EFECTIVO", "amount": 123, "received": 123, "cambio": 0, "displayAmount": 123, "type": null, "id": 1774300185133}]	28	4	20
1371	V5689	26	2026-03-23 21:54:52.096179	PAID	3	[{"method": "EFECTIVO", "amount": 26, "received": 26, "cambio": 0, "displayAmount": 26, "type": null, "id": 1774303551134}]	28	4	20
1373	V5163	143	2026-03-23 22:05:39.125755	PAID	3	[{"method": "EFECTIVO", "amount": 143, "received": 200, "cambio": 57, "displayAmount": 200, "type": null, "id": 1774303558974}]	28	18	20
1374	V5168	49	2026-03-23 22:09:19.592196	PAID	3	[{"method": "EFECTIVO", "amount": 49, "received": 50, "cambio": 1, "displayAmount": 50, "type": null, "id": 1774303771437}]	28	18	20
1375	V1484	32	2026-03-23 22:10:15.151156	PAID	4	[{"method": "EFECTIVO", "amount": 32, "received": 200, "cambio": 168, "displayAmount": 200, "type": null, "id": 1774303826161}]	28	8	20
1381	V1420	53	2026-03-23 22:28:52.870725	PAID	5	[{"method": "EFECTIVO", "amount": 53, "received": 53, "cambio": 0, "displayAmount": 53, "type": null, "id": 1774304977487}]	28	4	20
1391	V3027	90	2026-03-23 22:46:52.959563	PAID	5	[{"method": "EFECTIVO", "amount": 90, "received": 100, "cambio": 10, "displayAmount": 100, "type": null, "id": 1774306033076}]	28	4	20
950	V1373	17	2026-03-22 14:26:00.073761	PAID	5	[{"method": "EFECTIVO", "amount": 17, "received": 17, "cambio": 0, "displayAmount": 17, "type": null, "id": 1774307113231}]	28	18	20
1393	V7815	332	2026-03-23 23:00:11.596715	PAID	5	[{"method": "EFECTIVO", "amount": 332, "received": 332, "cambio": 0, "displayAmount": 332, "type": null, "id": 1774307158640}]	28	4	20
1397	V7178	51	2026-03-23 23:10:35.681707	PAID	3	[{"method": "EFECTIVO", "amount": 51, "received": 51, "cambio": 0, "displayAmount": 51, "type": null, "id": 1774308412631}]	28	18	20
1405	V2925	49	2026-03-23 23:30:45.040304	PAID	5	[{"method": "EFECTIVO", "amount": 49, "received": 200, "cambio": 151, "displayAmount": 200, "type": null, "id": 1774308714754}]	28	4	20
1407	V2312	66	2026-03-23 23:33:03.328628	PAID	5	[{"method": "EFECTIVO", "amount": 66, "received": 66, "cambio": 0, "displayAmount": 66, "type": null, "id": 1774308901881}]	28	4	20
1409	V3991	82	2026-03-23 23:38:59.670642	PAID	4	[{"method": "EFECTIVO", "amount": 82, "received": 82, "cambio": 0, "displayAmount": 82, "type": null, "id": 1774309189103}]	28	9	20
1412	V2486	135	2026-03-23 23:41:33.130112	PAID	3	[{"method": "EFECTIVO", "amount": 135, "received": 150, "cambio": 15, "displayAmount": 150, "type": null, "id": 1774309330294}]	28	18	20
1414	V4943	51	2026-03-23 23:43:54.668825	PAID	3	[{"method": "EFECTIVO", "amount": 51, "received": 51, "cambio": 0, "displayAmount": 51, "type": null, "id": 1774309472610}]	28	18	20
1415	V4495	58	2026-03-23 23:44:09.18156	PAID	5	[{"method": "EFECTIVO", "amount": 58, "received": 60, "cambio": 2, "displayAmount": 60, "type": null, "id": 1774408038123}]	30	13	3
1429	V5676	38	2026-03-23 23:54:37.606371	PAID	4	[{"method": "EFECTIVO", "amount": 38, "received": 38, "cambio": 0, "displayAmount": 38, "type": null, "id": 1774310638614}]	28	4	20
1377	V7505	152	2026-03-23 22:24:02.179924	PAID	3	[{"method": "EFECTIVO", "amount": 152, "received": 152, "cambio": 0, "displayAmount": 152, "type": null, "id": 1774304666266}]	28	18	20
1378	V5123	130	2026-03-23 22:24:31.972626	PAID	5	[{"method": "EFECTIVO", "amount": 130, "received": 500, "cambio": 370, "displayAmount": 500, "type": null, "id": 1774304693779}]	28	9	20
1379	V4104	38	2026-03-23 22:25:24.20198	PAID	5	[{"method": "EFECTIVO", "amount": 38, "received": 100, "cambio": 62, "displayAmount": 100, "type": null, "id": 1774304742711}]	28	9	20
1380	V5026	23	2026-03-23 22:27:01.980577	PAID	5	[{"method": "EFECTIVO", "amount": 23, "received": 24, "cambio": 1, "displayAmount": 24, "type": null, "id": 1774304883945}]	28	9	20
1382	V8623	255	2026-03-23 22:28:55.692024	PAID	3	[{"method": "EFECTIVO", "amount": 255, "received": 255, "cambio": 0, "displayAmount": 255, "type": null, "id": 1774304946256}]	28	18	20
1385	V5079	189	2026-03-23 22:33:05.746132	PAID	3	[{"method": "EFECTIVO", "amount": 189, "received": 200, "cambio": 11, "displayAmount": 200, "type": null, "id": 1774305197984}]	28	18	20
1386	V1042	51	2026-03-23 22:36:04.764857	PAID	5	[{"method": "EFECTIVO", "amount": 51, "received": 51, "cambio": 0, "displayAmount": 51, "type": null, "id": 1774305400095}]	28	4	20
1387	V6950	70	2026-03-23 22:36:09.58449	PAID	3	[{"method": "EFECTIVO", "amount": 70, "received": 70, "cambio": 0, "displayAmount": 70, "type": null, "id": 1774305471366}]	28	18	20
1388	V5235	32	2026-03-23 22:40:38.003061	PAID	3	[{"method": "EFECTIVO", "amount": 32, "received": 50, "cambio": 18, "displayAmount": 50, "type": null, "id": 1774305656317}]	28	18	20
1389	V8268	43	2026-03-23 22:40:52.563085	PAID	5	[{"method": "EFECTIVO", "amount": 43, "received": 50, "cambio": 7, "displayAmount": 50, "type": null, "id": 1774305679339}]	28	4	20
1390	V2118	51	2026-03-23 22:45:37.046165	PAID	3	[{"method": "EFECTIVO", "amount": 51, "received": 51, "cambio": 0, "displayAmount": 51, "type": null, "id": 1774305954414}]	28	18	20
1392	V3686	39	2026-03-23 22:49:29.634112	PAID	5	[{"method": "EFECTIVO", "amount": 39, "received": 100, "cambio": 61, "displayAmount": 100, "type": null, "id": 1774306189416}]	28	4	20
1395	V1403	34	2026-03-23 23:03:35.93605	PAID	3	[{"method": "EFECTIVO", "amount": 34, "received": 34, "cambio": 0, "displayAmount": 34, "type": null, "id": 1774307031177}]	28	18	20
1396	V5896	96	2026-03-23 23:03:41.503426	PAID	5	[{"method": "EFECTIVO", "amount": 96, "received": 200, "cambio": 104, "displayAmount": 200, "type": null, "id": 1774307058303}]	28	4	20
2297	V8217	24	2026-03-26 13:54:17.126585	PAID	4	[{"method": "EFECTIVO", "amount": 24, "displayAmount": 24, "type": null, "id": 1774533305994, "received": 24, "cambio": 0}]	69	15	20
1399	V6792	111	2026-03-23 23:24:15.388006	PAID	3	[{"method": "EFECTIVO", "amount": 111, "received": 500, "cambio": 389, "displayAmount": 500, "type": null, "id": 1774308309005}]	28	18	20
1402	V2337	127	2026-03-23 23:29:32.414689	PAID	3	[{"method": "EFECTIVO", "amount": 127, "received": 150, "cambio": 23, "displayAmount": 150, "type": null, "id": 1774308589787}]	28	18	20
1408	V6500	26	2026-03-23 23:34:52.11767	PAID	5	[{"method": "EFECTIVO", "amount": 26, "displayAmount": 50, "type": null, "id": 1774621286129, "received": 50, "cambio": 24}]	71	16	20
1437	V4317	104	2026-03-24 00:03:07.785259	PAID	5	[{"method": "EFECTIVO", "amount": 104, "received": 104, "cambio": 0, "displayAmount": 104, "type": null, "id": 1774497064021}]	36	18	3
1411	V4484	50	2026-03-23 23:40:32.341606	PAID	4	[{"method": "EFECTIVO", "amount": 50, "displayAmount": 50, "type": null, "id": 1774449388786, "received": 50, "cambio": 0}]	31	13	20
1426	V6471	77	2026-03-23 23:51:32.146946	PAID	4	[{"method": "EFECTIVO", "amount": 77, "received": 77, "cambio": 0, "displayAmount": 77, "type": null, "id": 1774309941118}]	28	4	20
1428	V1416	247	2026-03-23 23:54:08.494344	PAID	3	[{"method": "EFECTIVO", "amount": 247, "received": 247, "cambio": 0, "displayAmount": 247, "type": null, "id": 1774573643664}]	70	13	1
1430	V9851	54	2026-03-23 23:55:17.72581	PAID	3	[{"method": "EFECTIVO", "amount": 54, "received": 500, "cambio": 446, "displayAmount": 500, "type": null, "id": 1774310183548}]	28	18	20
972	V1298	40	2026-03-22 14:37:42.818568	PAID	4	[{"method": "EFECTIVO", "amount": 40, "received": 100, "cambio": 60, "displayAmount": 100, "type": null, "id": 1774310218467}]	28	18	20
1432	V9474	67	2026-03-23 23:57:59.943614	PAID	3	[{"method": "EFECTIVO", "amount": 67, "received": 74, "cambio": 7, "displayAmount": 74, "type": null, "id": 1774310335398}]	28	18	20
1427	V6372	53	2026-03-23 23:53:35.879777	PAID	5	[{"method": "EFECTIVO", "amount": 53, "received": 53, "cambio": 0, "displayAmount": 53, "type": null, "id": 1774310508505}]	28	9	20
1438	V5440	81	2026-03-24 00:03:57.607151	PAID	4	[{"method": "EFECTIVO", "amount": 81, "received": 500, "cambio": 419, "displayAmount": 500, "type": null, "id": 1774310666870}]	28	9	20
1439	V3529	71	2026-03-24 00:04:32.5189	PAID	5	[{"method": "EFECTIVO", "amount": 71, "received": 71, "cambio": 0, "displayAmount": 71, "type": null, "id": 1774310717574}]	28	4	20
1445	V9312	96	2026-03-24 00:10:39.302591	PAID	4	[{"method": "EFECTIVO", "amount": 96, "received": 100, "cambio": 4, "displayAmount": 100, "type": null, "id": 1774311055569}]	28	9	20
2295	V8676	65	2026-03-26 13:50:18.137568	PAID	3	[{"method": "EFECTIVO", "amount": 65, "displayAmount": 100, "type": null, "id": 1774533024362, "received": 100, "cambio": 35}]	69	15	20
1422	V1202	76	2026-03-23 23:49:28.072367	PAID	5	[{"method": "EFECTIVO", "amount": 76, "received": 76, "cambio": 0, "displayAmount": 76, "type": null, "id": 1774384261049}]	29	9	20
1398	V6469	43	2026-03-23 23:23:36.09009	PAID	5	[{"method": "EFECTIVO", "amount": 43, "received": 100, "cambio": 57, "displayAmount": 100, "type": null, "id": 1774581395233}]	70	4	1
2298	V2086	55	2026-03-26 13:54:19.175376	PAID	3	[{"method": "EFECTIVO", "amount": 55, "displayAmount": 55, "type": null, "id": 1774533270992, "received": 55, "cambio": 0}]	69	14	20
2299	V7512	55	2026-03-26 13:55:38.409279	PAID	3	[{"method": "EFECTIVO", "amount": 55, "received": 55, "cambio": 0, "displayAmount": 55, "type": null, "id": 1774533360086}]	69	14	20
2301	V9799	64	2026-03-26 13:57:06.740816	PAID	3	[{"method": "EFECTIVO", "amount": 64, "displayAmount": 100, "type": null, "id": 1774533447335, "received": 100, "cambio": 36}]	69	14	20
2302	V6744	32	2026-03-26 13:57:07.820583	PAID	4	[{"method": "EFECTIVO", "amount": 32, "displayAmount": 50, "type": null, "id": 1774533482722, "received": 50, "cambio": 18}]	69	15	20
2305	V8918	49	2026-03-26 14:02:22.975785	PAID	3	[{"method": "EFECTIVO", "amount": 49, "displayAmount": 100, "type": null, "id": 1774533749152, "received": 100, "cambio": 51}]	69	17	20
1383	V7764	157	2026-03-23 22:31:28.676951	PAID	4	[{"method": "EFECTIVO", "amount": 157, "received": 200, "cambio": 43, "displayAmount": 200, "type": null, "id": 1774305126463}]	28	9	20
1384	V7121	53	2026-03-23 22:32:37.486858	PAID	5	[{"method": "EFECTIVO", "amount": 53, "received": 53, "cambio": 0, "displayAmount": 53, "type": null, "id": 1774305179591}]	28	4	20
1394	V2010	53	2026-03-23 23:01:10.618411	PAID	5	[{"method": "EFECTIVO", "amount": 53, "received": 53, "cambio": 0, "displayAmount": 53, "type": null, "id": 1774306915618}]	28	4	20
1400	V7406	38	2026-03-23 23:24:38.686498	PAID	5	[{"method": "EFECTIVO", "amount": 38, "received": 38, "cambio": 0, "displayAmount": 38, "type": null, "id": 1774308372085}]	28	9	20
1401	V3113	50	2026-03-23 23:25:23.365812	PAID	3	[{"method": "EFECTIVO", "amount": 50, "received": 50, "cambio": 0, "displayAmount": 50, "type": null, "id": 1774308395372}]	28	18	20
1404	V4352	45	2026-03-23 23:30:21.563154	PAID	3	[{"method": "EFECTIVO", "amount": 45, "received": 45, "cambio": 0, "displayAmount": 45, "type": null, "id": 1774308706553}]	28	18	20
1406	V3560	60	2026-03-23 23:31:53.642575	PAID	3	[{"method": "EFECTIVO", "amount": 60, "received": 60, "cambio": 0, "displayAmount": 60, "type": null, "id": 1774308754919}]	28	18	20
1410	V6882	117	2026-03-23 23:39:09.290973	PAID	5	[{"method": "EFECTIVO", "amount": 117, "received": 500, "cambio": 383, "displayAmount": 500, "type": null, "id": 1774309218900}]	28	4	20
1416	V7442	35	2026-03-23 23:44:48.458971	PAID	3	[{"method": "EFECTIVO", "amount": 35, "received": 100, "cambio": 65, "displayAmount": 100, "type": null, "id": 1774309513558}]	28	18	20
1417	V7792	120	2026-03-23 23:45:19.680896	PAID	4	[{"method": "EFECTIVO", "amount": 120, "received": 150, "cambio": 30, "displayAmount": 150, "type": null, "id": 1774309549264}]	28	4	20
1418	V9525	87	2026-03-23 23:46:13.559986	PAID	3	[{"method": "EFECTIVO", "amount": 87, "received": 87, "cambio": 0, "displayAmount": 87, "type": null, "id": 1774309592157}]	28	18	20
1419	V8772	148	2026-03-23 23:46:34.913107	PAID	5	[{"method": "EFECTIVO", "amount": 148, "received": 148, "cambio": 0, "displayAmount": 148, "type": null, "id": 1774309648898}]	28	9	20
2296	V4452	21	2026-03-26 13:52:21.866172	PAID	3	[{"method": "EFECTIVO", "amount": 21, "displayAmount": 221, "type": null, "id": 1774533253475, "received": 221, "cambio": 200}]	69	14	20
1423	V2777	81	2026-03-23 23:49:34.997656	PAID	3	[{"method": "EFECTIVO", "amount": 81, "received": 100, "cambio": 19, "displayAmount": 100, "type": null, "id": 1774309824622}]	28	18	20
2276	V3392	44	2026-03-26 13:21:25.439423	PAID	3	[{"method": "EFECTIVO", "amount": 44, "displayAmount": 44, "type": null, "id": 1774533318073, "received": 44, "cambio": 0}]	69	14	20
1425	V1255	20	2026-03-23 23:51:29.975749	PAID	3	[{"method": "EFECTIVO", "amount": 20, "received": 50, "cambio": 30, "displayAmount": 50, "type": null, "id": 1774309990796}]	28	18	20
1434	V7925	104	2026-03-23 23:59:09.980815	PAID	3	[{"method": "EFECTIVO", "amount": 104, "received": 104, "cambio": 0, "displayAmount": 104, "type": null, "id": 1774310404302}]	28	18	20
1436	V1918	35	2026-03-24 00:02:38.193364	PAID	3	[{"method": "EFECTIVO", "amount": 35, "received": 50, "cambio": 15, "displayAmount": 50, "type": null, "id": 1774310575522}]	28	18	20
1441	V2164	128	2026-03-24 00:06:26.800485	PAID	5	[{"method": "EFECTIVO", "amount": 128, "received": 200, "cambio": 72, "displayAmount": 200, "type": null, "id": 1774310837744}]	28	4	20
1442	V6321	13	2026-03-24 00:06:27.17623	PAID	3	[{"method": "EFECTIVO", "amount": 13, "received": 13, "cambio": 0, "displayAmount": 13, "type": null, "id": 1774310885532}]	28	18	20
1403	V8699	32	2026-03-23 23:30:03.052679	PAID	4	[{"method": "EFECTIVO", "amount": 32, "received": 32, "cambio": 0, "displayAmount": 32, "type": null, "id": 1774310894131}]	28	9	20
1443	V6096	54	2026-03-24 00:08:26.905111	PAID	4	[{"method": "EFECTIVO", "amount": 54, "received": 100, "cambio": 46, "displayAmount": 100, "type": null, "id": 1774310926589}]	28	9	20
2300	V8902	118	2026-03-26 13:56:56.011737	PAID	5	[{"method": "EFECTIVO", "amount": 118, "displayAmount": 200, "type": null, "id": 1774533423067, "received": 200, "cambio": 82}]	69	17	20
1440	V9435	69	2026-03-24 00:05:36.713114	PAID	4	[{"method": "EFECTIVO", "amount": 69, "received": 200, "cambio": 131, "displayAmount": 200, "type": null, "id": 1774315012538}]	28	18	20
2304	V1999	27	2026-03-26 14:01:49.374592	PAID	3	[{"method": "EFECTIVO", "amount": 27, "displayAmount": 27, "type": null, "id": 1774533738164, "received": 27, "cambio": 0}]	69	17	20
1420	V2837	160	2026-03-23 23:46:51.48808	PAID	4	[{"method": "EFECTIVO", "amount": 160, "received": 200, "cambio": 40, "displayAmount": 200, "type": null, "id": 1774316742827}]	28	9	20
2307	V9701	75	2026-03-26 14:04:51.053504	PAID	5	[{"method": "EFECTIVO", "amount": 75, "displayAmount": 100, "type": null, "id": 1774533926197, "received": 100, "cambio": 25}]	69	14	20
1446	V1995	57	2026-03-24 00:14:36.4592	PAID	3	[{"method": "EFECTIVO", "amount": 57, "displayAmount": 57, "type": null, "id": 1774374471526, "received": 57, "cambio": 0}]	29	16	20
1421	V1171	86	2026-03-23 23:48:38.562775	PAID	4	[{"method": "EFECTIVO", "amount": 86, "received": 100, "cambio": 14, "displayAmount": 100, "type": null, "id": 1774390427582}]	29	9	20
2308	V6753	103	2026-03-26 14:05:50.408652	PAID	3	[{"method": "EFECTIVO", "amount": 103, "displayAmount": 103, "type": null, "id": 1774533973811, "received": 103, "cambio": 0}]	69	17	20
2317	V8886	32	2026-03-26 14:12:01.431741	PAID	5	[{"method": "EFECTIVO", "amount": 32, "displayAmount": 50, "type": null, "id": 1774534341980, "received": 50, "cambio": 18}]	69	14	20
2318	V2874	35	2026-03-26 14:12:24.680274	PAID	3	[{"method": "EFECTIVO", "amount": 35, "displayAmount": 200, "type": null, "id": 1774534372611, "received": 200, "cambio": 165}]	69	15	20
2319	V9505	20	2026-03-26 14:12:38.986271	PAID	5	[{"method": "EFECTIVO", "amount": 20, "displayAmount": 20, "type": null, "id": 1774534401556, "received": 20, "cambio": 0}]	69	14	20
2321	V7903	108	2026-03-26 14:21:26.479572	PAID	6	[{"method": "EFECTIVO", "amount": 108, "displayAmount": 200, "type": null, "id": 1774534891962, "received": 200, "cambio": 92}]	69	20	20
2322	V1271	50	2026-03-26 14:22:26.83763	PAID	5	[{"method": "EFECTIVO", "amount": 50, "displayAmount": 50, "type": null, "id": 1774535051423, "received": 50, "cambio": 0}]	69	14	20
2327	V6088	53	2026-03-26 14:29:17.794976	PAID	3	[{"method": "EFECTIVO", "amount": 53, "displayAmount": 200, "type": null, "id": 1774535376389, "received": 200, "cambio": 147}]	69	15	20
1431	V2383	129	2026-03-23 23:57:13.782531	PAID	5	[{"method": "EFECTIVO", "amount": 129, "received": 200, "cambio": 71, "displayAmount": 200, "type": null, "id": 1774310261409}]	28	9	20
1424	V3263	58	2026-03-23 23:50:29.420243	PAID	3	[{"method": "EFECTIVO", "amount": 58, "received": 58, "cambio": 0, "displayAmount": 58, "type": null, "id": 1774310317198}]	28	18	20
1433	V4267	88	2026-03-23 23:58:53.58451	PAID	5	[{"method": "EFECTIVO", "amount": 88, "received": 100, "cambio": 12, "displayAmount": 100, "type": null, "id": 1774486529573}]	35	8	3
1435	V3840	16	2026-03-24 00:00:26.683341	PAID	4	[{"method": "EFECTIVO", "amount": 16, "received": 16, "cambio": 0, "displayAmount": 16, "type": null, "id": 1774310523956}]	28	4	20
1444	V8300	68	2026-03-24 00:09:13.170563	PAID	3	[{"method": "EFECTIVO", "amount": 68, "received": 70, "cambio": 2, "displayAmount": 70, "type": null, "id": 1774310969851}]	28	18	20
1254	V3483	156	2026-03-23 01:58:09.58405	PAID	3	[{"method": "EFECTIVO", "amount": 156, "received": 156, "cambio": 0, "displayAmount": 156, "type": null, "id": 1774311574474}]	28	18	20
1449	V4159	194	2026-03-24 00:19:27.298264	PAID	4	[{"method": "EFECTIVO", "amount": 194, "received": 500, "cambio": 306, "displayAmount": 500, "type": null, "id": 1774311593942}]	28	9	20
1451	V6196	26	2026-03-24 00:20:42.860709	PAID	5	[{"method": "EFECTIVO", "amount": 26, "received": 26, "cambio": 0, "displayAmount": 26, "type": null, "id": 1774374413065}]	29	17	20
1452	V5023	51	2026-03-24 00:21:20.476702	PAID	3	[{"method": "EFECTIVO", "amount": 51, "received": 200, "cambio": 149, "displayAmount": 200, "type": null, "id": 1774311697530}]	28	18	20
1453	V3552	71	2026-03-24 00:21:32.698608	PAID	4	[{"method": "EFECTIVO", "amount": 71, "received": 100, "cambio": 29, "displayAmount": 100, "type": null, "id": 1774311730729}]	28	9	20
1455	V1566	109	2026-03-24 00:24:21.452631	PAID	4	[{"method": "EFECTIVO", "amount": 109, "received": 109, "cambio": 0, "displayAmount": 109, "type": null, "id": 1774311892240}]	28	9	20
1456	V9992	147	2026-03-24 00:25:09.2464	PAID	3	[{"method": "EFECTIVO", "amount": 147, "received": 200, "cambio": 53, "displayAmount": 200, "type": null, "id": 1774311924640}]	28	18	20
1450	V7875	32	2026-03-24 00:20:09.150025	PAID	3	[{"method": "EFECTIVO", "amount": 32, "received": 32, "cambio": 0, "displayAmount": 32, "type": null, "id": 1774311962028}]	28	18	20
2306	V5776	49	2026-03-26 14:03:14.433325	PAID	3	[{"method": "EFECTIVO", "amount": 49, "displayAmount": 200, "type": null, "id": 1774533810081, "received": 200, "cambio": 151}]	69	17	20
1461	V9441	54	2026-03-24 00:30:31.679966	PAID	4	[{"method": "EFECTIVO", "amount": 54, "received": 60, "cambio": 6, "displayAmount": 60, "type": null, "id": 1774312260644}]	28	9	20
1463	V2959	25	2026-03-24 00:31:12.323633	PAID	3	[{"method": "EFECTIVO", "amount": 25, "displayAmount": 25, "type": null, "id": 1774448156181, "received": 25, "cambio": 0}]	31	14	20
1465	V6273	63	2026-03-24 00:32:59.431033	PAID	4	[{"method": "EFECTIVO", "amount": 63, "received": 65, "cambio": 2, "displayAmount": 65, "type": null, "id": 1774312403321}]	28	9	20
1472	V5706	52	2026-03-24 00:41:41.911074	PAID	3	[{"method": "EFECTIVO", "amount": 52, "received": 200, "cambio": 148, "displayAmount": 200, "type": null, "id": 1774312929580}]	28	18	20
1474	V7278	41	2026-03-24 00:43:31.125678	PAID	4	[{"method": "EFECTIVO", "amount": 41, "received": 41, "cambio": 0, "displayAmount": 41, "type": null, "id": 1774313063697}]	28	9	20
1476	V7696	122	2026-03-24 00:44:25.866136	PAID	3	[{"method": "EFECTIVO", "amount": 122, "received": 122, "cambio": 0, "displayAmount": 122, "type": null, "id": 1774313078526}]	28	18	20
1477	V8733	56	2026-03-24 00:44:55.837151	PAID	5	[{"method": "EFECTIVO", "amount": 56, "received": 56, "cambio": 0, "displayAmount": 56, "type": null, "id": 1774313113012}]	28	4	20
1480	V2259	152	2026-03-24 00:46:49.072353	PAID	3	[{"method": "EFECTIVO", "amount": 152, "received": 205, "cambio": 53, "displayAmount": 205, "type": null, "id": 1774313243552}]	28	18	20
1481	V4492	80	2026-03-24 00:48:03.796264	PAID	4	[{"method": "EFECTIVO", "amount": 80, "received": 100, "cambio": 20, "displayAmount": 100, "type": null, "id": 1774313300753}]	28	9	20
1482	V5230	90	2026-03-24 00:49:50.078493	PAID	4	[{"method": "EFECTIVO", "amount": 90, "received": 200, "cambio": 110, "displayAmount": 200, "type": null, "id": 1774313423291}]	28	9	20
1483	V3227	40	2026-03-24 00:51:06.684869	PAID	3	[{"method": "EFECTIVO", "amount": 40, "received": 500, "cambio": 460, "displayAmount": 500, "type": null, "id": 1774313531222}]	28	4	20
1491	V9357	44	2026-03-24 00:58:19.45498	PAID	5	[{"method": "EFECTIVO", "amount": 44, "received": 50, "cambio": 6, "displayAmount": 50, "type": null, "id": 1774489161539}]	35	18	3
1501	V5015	66	2026-03-24 01:04:56.943819	PAID	3	[{"method": "EFECTIVO", "amount": 66, "displayAmount": 100, "type": null, "id": 1774314362262, "received": 100, "cambio": 34}]	28	18	20
1504	V5836	56	2026-03-24 01:09:47.128291	PAID	5	[{"method": "EFECTIVO", "amount": 56, "displayAmount": 56, "type": null, "id": 1774314617764, "received": 56, "cambio": 0}]	28	18	20
1510	V3825	38	2026-03-24 01:13:20.234543	PAID	5	[{"method": "EFECTIVO", "amount": 38, "received": 200, "cambio": 162, "displayAmount": 200, "type": null, "id": 1774314896489}]	28	18	20
1513	V3633	82	2026-03-24 01:17:20.610346	PAID	5	[{"method": "EFECTIVO", "amount": 82, "received": 200, "cambio": 118, "displayAmount": 200, "type": null, "id": 1774482527071}]	35	24	3
1515	V4656	63	2026-03-24 01:19:00.902459	PAID	5	[{"method": "EFECTIVO", "amount": 63, "received": 63, "cambio": 0, "displayAmount": 63, "type": null, "id": 1774315175710}]	28	18	20
1518	V4166	85	2026-03-24 01:21:05.066451	PAID	5	[{"method": "EFECTIVO", "amount": 85, "received": 85, "cambio": 0, "displayAmount": 85, "type": null, "id": 1774315328478}]	28	18	20
1488	V9409	20	2026-03-24 00:55:40.691553	PAID	3	[{"method": "EFECTIVO", "amount": 20, "received": 20, "cambio": 0, "displayAmount": 20, "type": null, "id": 1774315377996}]	28	18	20
1509	V3361	33	2026-03-24 01:13:15.936367	PAID	3	[{"method": "EFECTIVO", "amount": 33, "received": 33, "cambio": 0, "displayAmount": 33, "type": null, "id": 1774315787412}]	28	4	20
1505	V2954	60	2026-03-24 01:10:02.023255	PAID	4	[{"method": "EFECTIVO", "amount": 60, "received": 60, "cambio": 0, "displayAmount": 60, "type": null, "id": 1774315801836}]	28	9	20
1528	V1352	157	2026-03-24 01:32:15.560885	PAID	5	[{"method": "EFECTIVO", "amount": 157, "received": 200, "cambio": 43, "displayAmount": 200, "type": null, "id": 1774315987355}]	28	18	20
1448	V6484	99	2026-03-24 00:17:00.3731	PAID	3	[{"method": "EFECTIVO", "amount": 99, "received": 100, "cambio": 1, "displayAmount": 100, "type": null, "id": 1774311440921}]	28	18	20
1458	V5963	26	2026-03-24 00:27:36.386626	PAID	4	[{"method": "EFECTIVO", "amount": 26, "received": 26, "cambio": 0, "displayAmount": 26, "type": null, "id": 1774312086944}]	28	9	20
1460	V8393	88	2026-03-24 00:30:00.825718	PAID	3	[{"method": "EFECTIVO", "amount": 88, "received": 100, "cambio": 12, "displayAmount": 100, "type": null, "id": 1774312218652}]	28	18	20
1464	V5331	35	2026-03-24 00:32:35.122338	PAID	3	[{"method": "EFECTIVO", "amount": 35, "received": 50, "cambio": 15, "displayAmount": 50, "type": null, "id": 1774312375241}]	28	18	20
1466	V5220	50	2026-03-24 00:33:22.007833	PAID	5	[{"method": "EFECTIVO", "amount": 50, "received": 50, "cambio": 0, "displayAmount": 50, "type": null, "id": 1774312433065}]	28	4	20
1469	V5102	43	2026-03-24 00:38:11.498062	PAID	5	[{"method": "EFECTIVO", "amount": 43, "received": 50, "cambio": 7, "displayAmount": 50, "type": null, "id": 1774312719850}]	28	4	20
1471	V1964	13	2026-03-24 00:39:40.814565	PAID	5	[{"method": "EFECTIVO", "amount": 13, "received": 13, "cambio": 0, "displayAmount": 13, "type": null, "id": 1774575145250}]	70	24	1
1473	V3115	69	2026-03-24 00:42:17.520803	PAID	4	[{"method": "EFECTIVO", "amount": 69, "received": 100, "cambio": 31, "displayAmount": 100, "type": null, "id": 1774312959876}]	28	9	20
830	V2387	147	2026-03-22 00:55:42.774797	PAID	4	[{"method": "EFECTIVO", "amount": 147, "received": 500, "cambio": 353, "displayAmount": 500, "type": null, "id": 1774312985331}]	28	4	20
1475	V2990	53	2026-03-24 00:43:31.148141	PAID	5	[{"method": "EFECTIVO", "amount": 53, "received": 53, "cambio": 0, "displayAmount": 53, "type": null, "id": 1774313026928}]	28	4	20
2310	V3596	92	2026-03-26 14:07:21.447523	PAID	5	[{"method": "EFECTIVO", "amount": 92, "displayAmount": 100, "type": null, "id": 1774534059681, "received": 100, "cambio": 8}]	69	15	20
1479	V1395	146	2026-03-24 00:46:36.683846	PAID	4	[{"method": "EFECTIVO", "amount": 146, "received": 500, "cambio": 354, "displayAmount": 500, "type": null, "id": 1774313205999}]	28	9	20
1484	V8374	11	2026-03-24 00:52:02.540054	PAID	4	[{"method": "EFECTIVO", "amount": 11, "received": 11, "cambio": 0, "displayAmount": 11, "type": null, "id": 1774313567569}]	28	18	20
1485	V7549	31	2026-03-24 00:52:08.898126	PAID	5	[{"method": "EFECTIVO", "amount": 31, "received": 50, "cambio": 19, "displayAmount": 50, "type": null, "id": 1774313583334}]	28	4	20
1487	V7134	30	2026-03-24 00:54:43.650037	PAID	3	[{"method": "EFECTIVO", "amount": 30, "received": 30, "cambio": 0, "displayAmount": 30, "type": null, "id": 1774313710658}]	28	18	20
1492	V9619	78	2026-03-24 00:58:23.671132	PAID	3	[{"method": "EFECTIVO", "amount": 78, "received": 78, "cambio": 0, "displayAmount": 78, "type": null, "id": 1774576187127}]	70	4	1
1495	V4171	70	2026-03-24 01:01:37.504104	PAID	3	[{"method": "EFECTIVO", "amount": 70, "received": 100, "cambio": 30, "displayAmount": 100, "type": null, "id": 1774314112947}]	28	18	20
1506	V4594	32	2026-03-24 01:11:08.877425	PAID	3	[{"method": "EFECTIVO", "amount": 32, "received": 200, "cambio": 168, "displayAmount": 200, "type": null, "id": 1774314752737}]	28	4	20
1508	V8186	94	2026-03-24 01:12:07.39985	PAID	3	[{"method": "EFECTIVO", "amount": 94, "received": 100, "cambio": 6, "displayAmount": 100, "type": null, "id": 1774314859791}]	28	4	20
1512	V5436	110	2026-03-24 01:17:12.304282	PAID	4	[{"method": "EFECTIVO", "amount": 110, "received": 110, "cambio": 0, "displayAmount": 110, "type": null, "id": 1774315094096}]	28	9	20
1514	V1518	156	2026-03-24 01:18:58.270215	PAID	3	[{"method": "EFECTIVO", "amount": 156, "received": 200, "cambio": 44, "displayAmount": 200, "type": null, "id": 1774315200803}]	28	4	20
1516	V9135	73	2026-03-24 01:19:48.202199	PAID	3	[{"method": "EFECTIVO", "amount": 73, "received": 100, "cambio": 27, "displayAmount": 100, "type": null, "id": 1774572932576}]	70	24	1
1517	V2909	194	2026-03-24 01:20:28.893516	PAID	4	[{"method": "EFECTIVO", "amount": 194, "received": 500, "cambio": 306, "displayAmount": 500, "type": null, "id": 1774315260468}]	28	9	20
1497	V3953	73	2026-03-24 01:02:32.389966	PAID	3	[{"method": "EFECTIVO", "amount": 73, "received": 73, "cambio": 0, "displayAmount": 73, "type": null, "id": 1774576080769}]	70	4	1
1520	V1661	44	2026-03-24 01:24:03.225451	PAID	5	[{"method": "EFECTIVO", "amount": 44, "received": 44, "cambio": 0, "displayAmount": 44, "type": null, "id": 1774315477484}]	28	18	20
1523	V4192	17	2026-03-24 01:28:55.3064	PAID	5	[{"method": "EFECTIVO", "amount": 17, "received": 17, "cambio": 0, "displayAmount": 17, "type": null, "id": 1774315757315}]	28	18	20
1524	V5435	68	2026-03-24 01:29:16.841982	PAID	4	[{"method": "EFECTIVO", "amount": 68, "received": 100, "cambio": 32, "displayAmount": 100, "type": null, "id": 1774315769840}]	28	9	20
1525	V7326	44	2026-03-24 01:29:59.271962	PAID	5	[{"method": "EFECTIVO", "amount": 44, "received": 100, "cambio": 56, "displayAmount": 100, "type": null, "id": 1774315820003}]	28	18	20
1526	V5718	130	2026-03-24 01:31:58.666755	PAID	4	[{"method": "EFECTIVO", "amount": 130, "received": 130, "cambio": 0, "displayAmount": 130, "type": null, "id": 1774315938122}]	28	9	20
2315	V4563	31	2026-03-26 14:10:47.277926	PAID	4	[{"method": "EFECTIVO", "amount": 31, "displayAmount": 200, "type": null, "id": 1774534257262, "received": 200, "cambio": 169}]	69	14	20
1478	V5678	32	2026-03-24 00:45:58.677986	PAID	5	[{"method": "EFECTIVO", "amount": 32, "received": 50, "cambio": 18, "displayAmount": 50, "type": null, "id": 1774316279532}]	28	9	20
1507	V8430	25	2026-03-24 01:11:33.310892	PAID	5	[{"method": "EFECTIVO", "amount": 25, "received": 25, "cambio": 0, "displayAmount": 25, "type": null, "id": 1774394135971}]	29	13	20
2316	V1852	43	2026-03-26 14:11:28.200949	PAID	5	[{"method": "EFECTIVO", "amount": 43, "displayAmount": 50, "type": null, "id": 1774534319807, "received": 50, "cambio": 7}]	69	14	20
2320	V4897	55	2026-03-26 14:13:23.507364	PAID	3	[{"method": "EFECTIVO", "amount": 55, "displayAmount": 100, "type": null, "id": 1774534412819, "received": 100, "cambio": 45}]	69	15	20
2323	V3829	65	2026-03-26 14:23:30.583415	PAID	6	[{"method": "EFECTIVO", "amount": 65, "received": 200, "cambio": 135, "displayAmount": 200, "type": null, "id": 1774573345918}]	70	13	1
2324	V2620	53	2026-03-26 14:23:46.926181	PAID	5	[{"method": "EFECTIVO", "amount": 53, "displayAmount": 53, "type": null, "id": 1774535064837, "received": 53, "cambio": 0}]	69	14	20
712	V8129	23	2026-03-21 20:09:35.630495	PAID	5	[{"method": "EFECTIVO", "amount": 23, "displayAmount": 23, "type": null, "id": 1774536465319, "received": 23, "cambio": 0}]	69	17	20
1454	V9002	23	2026-03-24 00:22:55.480957	PAID	3	[{"method": "EFECTIVO", "amount": 23, "received": 23, "cambio": 0, "displayAmount": 23, "type": null, "id": 1774311971604}]	28	18	20
1459	V6691	38	2026-03-24 00:29:05.815121	PAID	4	[{"method": "EFECTIVO", "amount": 38, "received": 100, "cambio": 62, "displayAmount": 100, "type": null, "id": 1774312169184}]	28	9	20
1462	V8056	104	2026-03-24 00:31:09.806101	PAID	5	[{"method": "EFECTIVO", "amount": 104, "received": 104, "cambio": 0, "displayAmount": 104, "type": null, "id": 1774312320836}]	28	4	20
1467	V9275	65	2026-03-24 00:34:41.956313	PAID	3	[{"method": "EFECTIVO", "amount": 65, "received": 65, "cambio": 0, "displayAmount": 65, "type": null, "id": 1774312505136}]	28	18	20
1468	V3992	78	2026-03-24 00:36:24.752527	PAID	5	[{"method": "EFECTIVO", "amount": 78, "received": 200, "cambio": 122, "displayAmount": 200, "type": null, "id": 1774312621310}]	28	4	20
1470	V7151	89	2026-03-24 00:39:00.22082	PAID	3	[{"method": "EFECTIVO", "amount": 89, "received": 100, "cambio": 11, "displayAmount": 100, "type": null, "id": 1774312753437}]	28	18	20
1486	V6277	105	2026-03-24 00:53:46.602735	PAID	3	[{"method": "EFECTIVO", "amount": 105, "received": 105, "cambio": 0, "displayAmount": 105, "type": null, "id": 1774313641610}]	28	18	20
1489	V5184	44	2026-03-24 00:56:17.396827	PAID	3	[{"method": "EFECTIVO", "amount": 44, "received": 44, "cambio": 0, "displayAmount": 44, "type": null, "id": 1774313810810}]	28	18	20
1490	V3691	18	2026-03-24 00:56:58.47761	PAID	3	[{"method": "EFECTIVO", "amount": 18, "received": 18, "cambio": 0, "displayAmount": 18, "type": null, "id": 1774313908341}]	28	18	20
1493	V1776	44	2026-03-24 00:58:28.038842	PAID	4	[{"method": "EFECTIVO", "amount": 44, "received": 100, "cambio": 56, "displayAmount": 100, "type": null, "id": 1774313982215}]	28	9	20
1494	V7494	15	2026-03-24 01:00:04.817972	PAID	3	[{"method": "EFECTIVO", "amount": 15, "received": 50, "cambio": 35, "displayAmount": 50, "type": null, "id": 1774314021788}]	28	18	20
1496	V3365	62	2026-03-24 01:02:20.010212	PAID	5	[{"method": "EFECTIVO", "amount": 62, "received": 62, "cambio": 0, "displayAmount": 62, "type": null, "id": 1774488657601}]	35	8	3
1498	V7437	193	2026-03-24 01:03:06.875176	PAID	5	[{"method": "EFECTIVO", "amount": 193, "received": 200, "cambio": 7, "displayAmount": 200, "type": null, "id": 1774571748100}]	70	13	1
1499	V3097	148	2026-03-24 01:03:46.225092	PAID	4	[{"method": "EFECTIVO", "amount": 148, "displayAmount": 500, "type": null, "id": 1774314293444, "received": 500, "cambio": 352}]	28	9	20
1500	V9103	108	2026-03-24 01:04:52.872537	PAID	5	[{"method": "EFECTIVO", "amount": 108, "displayAmount": 500, "type": null, "id": 1774314419385, "received": 500, "cambio": 392}]	28	4	20
1502	V4657	70	2026-03-24 01:06:26.802403	PAID	5	[{"method": "EFECTIVO", "amount": 70, "displayAmount": 70, "type": null, "id": 1774314488923, "received": 70, "cambio": 0}]	28	4	20
1503	V9934	43	2026-03-24 01:08:18.914818	PAID	5	[{"method": "EFECTIVO", "amount": 43, "displayAmount": 100, "type": null, "id": 1774314539707, "received": 100, "cambio": 57}]	28	18	20
1511	V6164	65	2026-03-24 01:14:14.16785	PAID	4	[{"method": "EFECTIVO", "amount": 65, "received": 200, "cambio": 135, "displayAmount": 200, "type": null, "id": 1774314962679}]	28	9	20
1519	V8068	35	2026-03-24 01:22:57.926645	PAID	5	[{"method": "EFECTIVO", "amount": 35, "received": 100, "cambio": 65, "displayAmount": 100, "type": null, "id": 1774315406189}]	28	18	20
1521	V9128	82	2026-03-24 01:25:35.831826	PAID	5	[{"method": "EFECTIVO", "amount": 82, "received": 200, "cambio": 118, "displayAmount": 200, "type": null, "id": 1774315561521}]	28	18	20
1522	V5196	67	2026-03-24 01:27:08.423164	PAID	5	[{"method": "EFECTIVO", "amount": 67, "received": 100, "cambio": 33, "displayAmount": 100, "type": null, "id": 1774315648748}]	28	18	20
1527	V9153	41	2026-03-24 01:32:08.781944	PAID	3	[{"method": "EFECTIVO", "amount": 41, "received": 200, "cambio": 159, "displayAmount": 200, "type": null, "id": 1774315962231}]	28	4	20
1529	V5269	49	2026-03-24 01:32:58.013824	PAID	4	[{"method": "EFECTIVO", "amount": 49, "received": 49, "cambio": 0, "displayAmount": 49, "type": null, "id": 1774316018602}]	28	9	20
1530	V1530	136	2026-03-24 01:36:01.836963	PAID	6	[{"method": "EFECTIVO", "amount": 136, "received": 136, "cambio": 0, "displayAmount": 136, "type": null, "id": 1774316171123}]	28	8	20
1531	V5229	80	2026-03-24 01:36:10.755719	PAID	5	[{"method": "EFECTIVO", "amount": 80, "received": 100, "cambio": 20, "displayAmount": 100, "type": null, "id": 1774316196014}]	28	18	20
1532	V1204	64	2026-03-24 01:36:21.348473	PAID	4	[{"method": "EFECTIVO", "amount": 64, "received": 100, "cambio": 36, "displayAmount": 100, "type": null, "id": 1774316213014}]	28	9	20
1533	V9401	42	2026-03-24 01:37:27.768156	PAID	6	[{"method": "EFECTIVO", "amount": 42, "received": 50, "cambio": 8, "displayAmount": 50, "type": null, "id": 1774316261130}]	28	8	20
1534	V7847	70	2026-03-24 01:38:23.250757	PAID	5	[{"method": "EFECTIVO", "amount": 70, "received": 200, "cambio": 130, "displayAmount": 200, "type": null, "id": 1774316324543}]	28	18	20
1535	V9571	213	2026-03-24 01:39:08.660496	PAID	3	[{"method": "EFECTIVO", "amount": 213, "received": 500, "cambio": 287, "displayAmount": 500, "type": null, "id": 1774316363664}]	28	4	20
1541	V6964	67	2026-03-24 01:41:48.034989	PAID	4	[{"method": "EFECTIVO", "amount": 67, "received": 100, "cambio": 33, "displayAmount": 100, "type": null, "id": 1774316540008}]	28	8	20
1540	V6788	6	2026-03-24 01:41:47.359405	PAID	5	[{"method": "EFECTIVO", "amount": 6, "received": 6, "cambio": 0, "displayAmount": 6, "type": null, "id": 1774316635227}]	28	18	20
1543	V7398	128	2026-03-24 01:44:40.345593	PAID	3	[{"method": "EFECTIVO", "amount": 128, "received": 130, "cambio": 2, "displayAmount": 130, "type": null, "id": 1774316727413}]	28	4	20
1544	V2939	89	2026-03-24 01:45:59.586424	PAID	4	[{"method": "EFECTIVO", "amount": 89, "received": 100, "cambio": 11, "displayAmount": 100, "type": null, "id": 1774316778063}]	28	24	20
1545	V7672	47	2026-03-24 01:46:06.408739	PAID	5	[{"method": "EFECTIVO", "amount": 47, "received": 50, "cambio": 3, "displayAmount": 50, "type": null, "id": 1774316807158}]	28	18	20
1546	V5128	32	2026-03-24 01:46:56.468039	PAID	6	[{"method": "EFECTIVO", "amount": 32, "received": 32, "cambio": 0, "displayAmount": 32, "type": null, "id": 1774316831383}]	28	8	20
1548	V5071	92	2026-03-24 01:49:37.680238	PAID	6	[{"method": "EFECTIVO", "amount": 92, "received": 100, "cambio": 8, "displayAmount": 100, "type": null, "id": 1774317003222}]	28	9	20
1549	V4289	102	2026-03-24 01:49:50.347181	PAID	5	[{"method": "EFECTIVO", "amount": 102, "received": 200, "cambio": 98, "displayAmount": 200, "type": null, "id": 1774317033414}]	28	18	20
1536	V2586	35	2026-03-24 01:39:54.248046	PAID	5	[{"method": "EFECTIVO", "amount": 35, "received": 35, "cambio": 0, "displayAmount": 35, "type": null, "id": 1774316412932}]	28	18	20
2331	V9879	104	2026-03-26 14:33:13.046242	PAID	5	[{"method": "EFECTIVO", "amount": 104, "displayAmount": 105, "type": null, "id": 1774535609997, "received": 105, "cambio": 1}]	69	14	20
1538	V3265	26	2026-03-24 01:40:57.712473	PAID	3	[{"method": "EFECTIVO", "amount": 26, "received": 50, "cambio": 24, "displayAmount": 50, "type": null, "id": 1774316476463}]	28	4	20
1539	V4816	32	2026-03-24 01:41:26.873265	PAID	5	[{"method": "EFECTIVO", "amount": 32, "received": 100, "cambio": 68, "displayAmount": 100, "type": null, "id": 1774316504838}]	28	18	20
1542	V3339	58	2026-03-24 01:43:50.685198	PAID	5	[{"method": "EFECTIVO", "amount": 58, "received": 58, "cambio": 0, "displayAmount": 58, "type": null, "id": 1774316698367}]	28	18	20
2333	V4631	30	2026-03-26 14:44:48.167695	PAID	3	[{"method": "EFECTIVO", "amount": 30, "displayAmount": 30, "type": null, "id": 1774536475712, "received": 30, "cambio": 0}]	69	17	20
1551	V7976	99	2026-03-24 01:52:46.040492	PAID	5	[{"method": "EFECTIVO", "amount": 99, "received": 100, "cambio": 1, "displayAmount": 100, "type": null, "id": 1774317244253}]	28	18	20
1552	V5426	97	2026-03-24 01:57:36.50572	PAID	5	[{"method": "EFECTIVO", "amount": 97, "received": 100, "cambio": 3, "displayAmount": 100, "type": null, "id": 1774317477079}]	28	18	20
1547	V6991	50	2026-03-24 01:47:03.114906	PAID	1	[{"method": "EFECTIVO", "amount": 50, "received": 200, "cambio": 150, "displayAmount": 200, "type": null, "id": 1774490258561}]	35	18	3
1555	V9459	55	2026-03-24 02:01:43.477597	PAID	6	[{"method": "EFECTIVO", "amount": 55, "received": 200, "cambio": 145, "displayAmount": 200, "type": null, "id": 1774317899234}]	28	9	20
1563	V1303	67	2026-03-24 02:08:20.303864	PAID	5	[{"method": "EFECTIVO", "amount": 67, "received": 100, "cambio": 33, "displayAmount": 100, "type": null, "id": 1774318128131}]	28	9	20
1564	V9509	99	2026-03-24 02:09:01.753478	PAID	3	[{"method": "EFECTIVO", "amount": 99, "received": 100, "cambio": 1, "displayAmount": 100, "type": null, "id": 1774318160980}]	28	18	20
1554	V3459	96	2026-03-24 02:01:35.21096	PAID	3	[{"method": "EFECTIVO", "amount": 96, "received": 500, "cambio": 404, "displayAmount": 500, "type": null, "id": 1774403791976}]	30	8	3
1569	V2794	136	2026-03-24 02:14:33.610788	PAID	6	[{"method": "EFECTIVO", "amount": 136, "received": 500, "cambio": 364, "displayAmount": 500, "type": null, "id": 1774318522259}]	28	18	20
1573	V7975	320	2026-03-24 02:16:24.784199	PAID	5	[{"method": "EFECTIVO", "amount": 320, "received": 320, "cambio": 0, "displayAmount": 320, "type": null, "id": 1774318764884}]	28	9	20
1578	V7606	79	2026-03-24 02:21:44.482209	PAID	6	[{"method": "EFECTIVO", "amount": 79, "received": 79, "cambio": 0, "displayAmount": 79, "type": null, "id": 1774319002172}]	28	4	20
1581	V8274	88	2026-03-24 02:23:55.023215	PAID	6	[{"method": "EFECTIVO", "amount": 88, "received": 200, "cambio": 112, "displayAmount": 200, "type": null, "id": 1774319097901}]	28	18	20
1580	V2764	20	2026-03-24 02:23:32.751216	PAID	3	[{"method": "EFECTIVO", "amount": 20, "received": 20, "cambio": 0, "displayAmount": 20, "type": null, "id": 1774319168521}]	28	9	20
1582	V7675	18	2026-03-24 02:24:38.928705	PAID	3	[{"method": "EFECTIVO", "amount": 18, "received": 18, "cambio": 0, "displayAmount": 18, "type": null, "id": 1774319174323}]	28	4	20
1571	V7170	78	2026-03-24 02:15:12.068967	PAID	4	[{"method": "EFECTIVO", "amount": 78, "received": 78, "cambio": 0, "displayAmount": 78, "type": null, "id": 1774319223359}]	28	8	20
1584	V5421	27	2026-03-24 02:27:16.567387	PAID	2	[{"method": "EFECTIVO", "amount": 27, "received": 27, "cambio": 0, "displayAmount": 27, "type": null, "id": 1774319237980}]	28	20	\N
1583	V2960	99	2026-03-24 02:27:08.667613	PAID	5	[{"method": "EFECTIVO", "amount": 99, "received": 100, "cambio": 1, "displayAmount": 100, "type": null, "id": 1774319270204}]	28	18	20
1537	V6492	41	2026-03-24 01:40:29.841507	PAID	5	[{"method": "EFECTIVO", "amount": 41, "displayAmount": 41, "type": null, "id": 1774448644352, "received": 41, "cambio": 0}]	31	14	20
1587	V4799	125	2026-03-24 02:34:00.863569	PAID	3	[{"method": "EFECTIVO", "amount": 125, "received": 125, "cambio": 0, "displayAmount": 125, "type": null, "id": 1774319685374}]	28	18	20
1588	V1152	58	2026-03-24 02:35:28.093665	PAID	5	[{"method": "EFECTIVO", "amount": 58, "received": 58, "cambio": 0, "displayAmount": 58, "type": null, "id": 1774319755542}]	28	9	20
1589	V8614	178	2026-03-24 02:38:07.320752	PAID	3	[{"method": "EFECTIVO", "amount": 178, "received": 200, "cambio": 22, "displayAmount": 200, "type": null, "id": 1774319903524}]	28	4	20
1591	V2955	88	2026-03-24 02:40:24.557243	PAID	5	[{"method": "EFECTIVO", "amount": 88, "received": 88, "cambio": 0, "displayAmount": 88, "type": null, "id": 1774320100321}]	28	18	20
1593	V7086	51	2026-03-24 02:42:16.006792	PAID	5	[{"method": "EFECTIVO", "amount": 51, "received": 51, "cambio": 0, "displayAmount": 51, "type": null, "id": 1774320165152}]	28	18	20
1594	V3565	42	2026-03-24 02:42:26.830496	PAID	3	[{"method": "EFECTIVO", "amount": 42, "received": 42, "cambio": 0, "displayAmount": 42, "type": null, "id": 1774320343915}]	28	9	20
1597	V3063	72	2026-03-24 02:44:15.234642	PAID	3	[{"method": "EFECTIVO", "amount": 72, "received": 72, "cambio": 0, "displayAmount": 72, "type": null, "id": 1774320355409}]	28	9	20
1598	V5352	103	2026-03-24 02:47:02.626647	PAID	3	[{"method": "EFECTIVO", "amount": 103, "received": 103, "cambio": 0, "displayAmount": 103, "type": null, "id": 1774320539759}]	28	18	20
1608	V7200	80	2026-03-24 03:27:28.93059	PAID	3	[{"method": "EFECTIVO", "amount": 80, "received": 80, "cambio": 0, "displayAmount": 80, "type": null, "id": 1774323135931}]	28	18	20
1610	V8857	26	2026-03-24 03:32:02.678959	PAID	3	[{"method": "EFECTIVO", "amount": 26, "received": 26, "cambio": 0, "displayAmount": 26, "type": null, "id": 1774323148153}]	28	18	20
1586	V3684	45	2026-03-24 02:33:25.037058	PAID	5	[{"method": "EFECTIVO", "amount": 45, "received": 200, "cambio": 155, "displayAmount": 200, "type": null, "id": 1774403378129}]	30	9	3
1567	V2977	86	2026-03-24 02:11:24.278388	PAID	5	[{"method": "EFECTIVO", "amount": 86, "received": 500, "cambio": 414, "displayAmount": 500, "type": null, "id": 1774396677183}]	29	8	20
2336	V4742	30	2026-03-26 14:54:18.860243	PAID	3	[{"method": "EFECTIVO", "amount": 30, "displayAmount": 500, "type": null, "id": 1774536867339, "received": 500, "cambio": 470}]	69	14	20
2342	V7647	149	2026-03-26 15:04:32.441917	PAID	3	[{"method": "EFECTIVO", "amount": 149, "displayAmount": 200, "type": null, "id": 1774537479282, "received": 200, "cambio": 51}]	69	14	20
1550	V1381	126	2026-03-24 01:52:04.502497	PAID	6	[{"method": "EFECTIVO", "amount": 126, "received": 200, "cambio": 74, "displayAmount": 200, "type": null, "id": 1774317156468}]	28	9	20
1553	V1618	77	2026-03-24 02:00:50.693589	PAID	4	[{"method": "EFECTIVO", "amount": 77, "received": 77, "cambio": 0, "displayAmount": 77, "type": null, "id": 1774317702132}]	28	18	20
1559	V8373	110	2026-03-24 02:05:11.218861	PAID	5	[{"method": "EFECTIVO", "amount": 110, "received": 110, "cambio": 0, "displayAmount": 110, "type": null, "id": 1774317968770}]	28	9	20
1561	V5544	27	2026-03-24 02:06:37.659319	PAID	3	[{"method": "EFECTIVO", "amount": 27, "received": 100, "cambio": 73, "displayAmount": 100, "type": null, "id": 1774318034952}]	28	18	20
1557	V8789	52	2026-03-24 02:03:06.766873	PAID	4	[{"method": "EFECTIVO", "amount": 52, "received": 52, "cambio": 0, "displayAmount": 52, "type": null, "id": 1774318109180}]	28	18	20
1566	V7330	32	2026-03-24 02:11:17.236029	PAID	3	[{"method": "EFECTIVO", "amount": 32, "received": 32, "cambio": 0, "displayAmount": 32, "type": null, "id": 1774318367704}]	28	24	20
2340	V1538	52	2026-03-26 14:59:48.942235	PAID	3	[{"method": "EFECTIVO", "amount": 52, "displayAmount": 52, "type": null, "id": 1774632641366, "received": 52, "cambio": 0}]	71	16	20
2359	V3444	117	2026-03-26 16:05:37.863639	PAID	4	[{"method": "EFECTIVO", "amount": 117, "displayAmount": 200, "type": null, "id": 1774541144864, "received": 200, "cambio": 83}]	69	20	20
1577	V9034	38	2026-03-24 02:20:41.286923	PAID	4	[{"method": "EFECTIVO", "amount": 38, "received": 38, "cambio": 0, "displayAmount": 38, "type": null, "id": 1774318905992}]	28	8	20
1574	V5925	30	2026-03-24 02:17:44.851582	PAID	5	[{"method": "EFECTIVO", "amount": 30, "received": 30, "cambio": 0, "displayAmount": 30, "type": null, "id": 1774318914108}]	28	18	20
1576	V7275	66	2026-03-24 02:20:40.520889	PAID	5	[{"method": "EFECTIVO", "amount": 66, "received": 100, "cambio": 34, "displayAmount": 100, "type": null, "id": 1774318945633}]	28	18	20
1579	V4250	59	2026-03-24 02:22:12.398679	PAID	5	[{"method": "EFECTIVO", "amount": 59, "received": 59, "cambio": 0, "displayAmount": 59, "type": null, "id": 1774319193896}]	28	18	20
2358	V8087	105	2026-03-26 16:05:24.74928	PAID	5	[{"method": "EFECTIVO", "amount": 105, "displayAmount": 105, "type": null, "id": 1774542329035, "received": 105, "cambio": 0}]	69	15	20
1585	V2321	166	2026-03-24 02:29:40.855935	PAID	3	[{"method": "EFECTIVO", "amount": 166, "received": 200, "cambio": 34, "displayAmount": 200, "type": null, "id": 1774319571657}]	28	18	20
1568	V7137	17	2026-03-24 02:12:15.06013	PAID	4	[{"method": "EFECTIVO", "amount": 17, "received": 17, "cambio": 0, "displayAmount": 17, "type": null, "id": 1774495414917}]	35	18	3
1570	V2467	206	2026-03-24 02:14:46.8702	PAID	3	[{"method": "EFECTIVO", "amount": 206, "received": 206, "cambio": 0, "displayAmount": 206, "type": null, "id": 1774320114651}]	28	9	20
1596	V7283	68	2026-03-24 02:43:37.905935	PAID	5	[{"method": "EFECTIVO", "amount": 68, "received": 68, "cambio": 0, "displayAmount": 68, "type": null, "id": 1774320362767}]	28	18	20
1590	V1229	127	2026-03-24 02:40:03.754705	PAID	4	[{"method": "EFECTIVO", "amount": 127, "received": 127, "cambio": 0, "displayAmount": 127, "type": null, "id": 1774320371541}]	28	4	20
1592	V5669	58	2026-03-24 02:41:20.560973	PAID	4	[{"method": "EFECTIVO", "amount": 58, "received": 58, "cambio": 0, "displayAmount": 58, "type": null, "id": 1774320378831}]	28	4	20
1595	V6589	23	2026-03-24 02:42:54.318754	PAID	4	[{"method": "EFECTIVO", "amount": 23, "received": 23, "cambio": 0, "displayAmount": 23, "type": null, "id": 1774320391502}]	28	4	20
1603	V3426	44	2026-03-24 03:05:14.37323	PAID	5	[{"method": "EFECTIVO", "amount": 44, "received": 50, "cambio": 6, "displayAmount": 50, "type": null, "id": 1774321532407}]	28	9	20
1609	V3671	50	2026-03-24 03:31:26.100773	PAID	3	[{"method": "EFECTIVO", "amount": 50, "received": 50, "cambio": 0, "displayAmount": 50, "type": null, "id": 1774323141173}]	28	18	20
2339	V2827	101	2026-03-26 14:58:21.703948	PAID	3	[{"method": "EFECTIVO", "amount": 101, "displayAmount": 101, "type": null, "id": 1774537113653, "received": 101, "cambio": 0}]	69	14	20
2341	V3963	18	2026-03-26 15:00:19.497827	PAID	3	[{"method": "EFECTIVO", "amount": 18, "displayAmount": 50, "type": null, "id": 1774537236741, "received": 50, "cambio": 32}]	69	14	20
2343	V1887	68	2026-03-26 15:09:22.597665	PAID	5	[{"method": "EFECTIVO", "amount": 68, "displayAmount": 200, "type": null, "id": 1774537778300, "received": 200, "cambio": 132}]	69	14	20
2347	V2045	118	2026-03-26 15:24:12.495649	PAID	6	[{"method": "TARJETA", "amount": 118, "displayAmount": 118, "type": "DEBITO", "id": 1774538678881}]	69	20	20
5	V1434	56	2026-03-13 20:02:58.95769	PAID	1	[{"method": "EFECTIVO", "amount": 56, "displayAmount": 100, "type": null, "id": 1774538770525, "received": 100, "cambio": 44}]	69	15	20
2350	V5562	38	2026-03-26 15:26:38.960325	PAID	5	[{"method": "EFECTIVO", "amount": 38, "displayAmount": 40, "type": null, "id": 1774538856928, "received": 40, "cambio": 2}]	69	15	20
2351	V1671	56	2026-03-26 15:29:07.863019	PAID	5	[{"method": "EFECTIVO", "amount": 56, "displayAmount": 200, "type": null, "id": 1774538954857, "received": 200, "cambio": 144}]	69	15	20
2352	V7844	54	2026-03-26 15:31:17.364572	PAID	5	[{"method": "EFECTIVO", "amount": 54, "displayAmount": 55, "type": null, "id": 1774539100844, "received": 55, "cambio": 1}]	69	15	20
2354	V5256	64	2026-03-26 15:41:49.32749	PAID	5	[{"method": "EFECTIVO", "amount": 64, "displayAmount": 64, "type": null, "id": 1774542341210, "received": 64, "cambio": 0}]	69	15	20
2364	V2903	213	2026-03-26 17:03:09.366515	PAID	4	[{"method": "EFECTIVO", "amount": 213, "displayAmount": 213, "type": null, "id": 1774544603205, "received": 213, "cambio": 0}]	69	20	20
2370	V8400	115	2026-03-26 18:57:26.637023	PAID	2	[{"method": "EFECTIVO", "amount": 115, "displayAmount": 115, "type": null, "id": 1774551445511, "received": 115, "cambio": 0}]	69	20	\N
2361	V9734	35	2026-03-26 16:48:03.257336	PAID	5	[{"method": "EFECTIVO", "amount": 35, "displayAmount": 35, "type": null, "id": 1774557697834, "received": 35, "cambio": 0}]	69	15	20
2367	V1233	128	2026-03-26 18:21:24.450806	PAID	5	[{"method": "EFECTIVO", "amount": 128, "displayAmount": 128, "type": null, "id": 1774557766247, "received": 128, "cambio": 0}]	69	14	20
2566	V1125	44	2026-03-27 13:10:40.636053	PAID	5	[{"method": "EFECTIVO", "amount": 44, "displayAmount": 100, "type": null, "id": 1774617051443, "received": 100, "cambio": 56}]	71	15	20
1556	V6699	57	2026-03-24 02:02:53.960747	PAID	6	[{"method": "EFECTIVO", "amount": 57, "displayAmount": 57, "type": null, "id": 1774632734866, "received": 57, "cambio": 0}]	71	15	20
1558	V9510	55	2026-03-24 02:04:31.401354	PAID	3	[{"method": "EFECTIVO", "amount": 55, "received": 55, "cambio": 0, "displayAmount": 55, "type": null, "id": 1774317953664}]	28	18	20
1560	V8237	23	2026-03-24 02:06:04.371791	PAID	5	[{"method": "EFECTIVO", "amount": 23, "received": 30, "cambio": 7, "displayAmount": 30, "type": null, "id": 1774576121978}]	70	9	1
1565	V9772	79	2026-03-24 02:09:57.484608	PAID	4	[{"method": "EFECTIVO", "amount": 79, "received": 500, "cambio": 421, "displayAmount": 500, "type": null, "id": 1774318237638}]	28	24	20
1562	V8760	90	2026-03-24 02:07:12.546899	PAID	4	[{"method": "EFECTIVO", "amount": 90, "received": 90, "cambio": 0, "displayAmount": 90, "type": null, "id": 1774318388405}]	28	24	20
1575	V8188	58	2026-03-24 02:18:55.657567	PAID	5	[{"method": "EFECTIVO", "amount": 58, "received": 58, "cambio": 0, "displayAmount": 58, "type": null, "id": 1774319182153}]	28	18	20
1572	V1044	32	2026-03-24 02:16:09.515981	PAID	6	[{"method": "EFECTIVO", "amount": 32, "received": 32, "cambio": 0, "displayAmount": 32, "type": null, "id": 1774320385755}]	28	18	20
1599	V1187	44	2026-03-24 02:48:28.617289	PAID	5	[{"method": "EFECTIVO", "amount": 44, "received": 44, "cambio": 0, "displayAmount": 44, "type": null, "id": 1774320588408}]	28	9	20
1600	V4431	56	2026-03-24 02:49:50.706371	PAID	3	[{"method": "EFECTIVO", "amount": 56, "received": 200, "cambio": 144, "displayAmount": 200, "type": null, "id": 1774320600587}]	28	4	20
1601	V7947	63	2026-03-24 02:51:18.806575	PAID	3	[{"method": "EFECTIVO", "amount": 63, "received": 63, "cambio": 0, "displayAmount": 63, "type": null, "id": 1774320709101}]	28	4	20
1602	V7245	40	2026-03-24 03:02:43.111484	PAID	3	[{"method": "EFECTIVO", "amount": 40, "received": 40, "cambio": 0, "displayAmount": 40, "type": null, "id": 1774321399247}]	28	18	20
1604	V6628	115	2026-03-24 03:13:34.50898	PAID	3	[{"method": "EFECTIVO", "amount": 115, "received": 200, "cambio": 85, "displayAmount": 200, "type": null, "id": 1774322023946}]	28	18	20
1605	V5792	119	2026-03-24 03:14:01.998142	PAID	3	[{"method": "EFECTIVO", "amount": 119, "received": 120, "cambio": 1, "displayAmount": 120, "type": null, "id": 1774322077483}]	28	18	20
1607	V3454	100	2026-03-24 03:17:16.604563	PAID	3	[{"method": "EFECTIVO", "amount": 100, "received": 100, "cambio": 0, "displayAmount": 100, "type": null, "id": 1774323130036}]	28	18	20
1611	V6392	68	2026-03-24 13:06:27.928705	PAID	3	[{"method": "EFECTIVO", "amount": 68, "displayAmount": 70, "type": null, "id": 1774357597538, "received": 70, "cambio": 2}]	29	14	20
291	V3036	48	2026-03-20 13:07:34.040852	PAID	4	[{"method": "EFECTIVO", "amount": 48, "displayAmount": 500, "type": null, "id": 1774357630971, "received": 500, "cambio": 452}]	29	17	20
1612	V1689	72	2026-03-24 13:07:18.470199	PAID	3	[{"method": "EFECTIVO", "amount": 72, "received": 100, "cambio": 28, "displayAmount": 100, "type": null, "id": 1774402024489}]	30	13	3
1613	V4881	41	2026-03-24 13:09:06.796895	PAID	5	[{"method": "EFECTIVO", "amount": 41, "displayAmount": 100, "type": null, "id": 1774357753512, "received": 100, "cambio": 59}]	29	17	20
1615	V2150	32	2026-03-24 13:15:10.249305	PAID	5	[{"method": "EFECTIVO", "amount": 32, "displayAmount": 32, "type": null, "id": 1774358139164, "received": 32, "cambio": 0}]	29	17	20
1614	V5318	37	2026-03-24 13:10:31.167575	PAID	5	[{"method": "EFECTIVO", "amount": 37, "displayAmount": 37, "type": null, "id": 1774358160502, "received": 37, "cambio": 0}]	29	17	20
1616	V5657	39	2026-03-24 13:18:41.220301	PAID	4	[{"method": "EFECTIVO", "amount": 39, "displayAmount": 100, "type": null, "id": 1774358343552, "received": 100, "cambio": 61}]	29	16	20
1617	V2084	64	2026-03-24 13:19:47.464644	PAID	5	[{"method": "EFECTIVO", "amount": 64, "displayAmount": 200, "type": null, "id": 1774358397041, "received": 200, "cambio": 136}]	29	17	20
1618	V9089	37	2026-03-24 13:21:10.940154	PAID	5	[{"method": "EFECTIVO", "amount": 37, "displayAmount": 50, "type": null, "id": 1774358484995, "received": 50, "cambio": 13}]	29	17	20
1619	V2371	25	2026-03-24 13:22:27.222992	PAID	5	[{"method": "EFECTIVO", "amount": 25, "displayAmount": 25, "type": null, "id": 1774358564259, "received": 25, "cambio": 0}]	29	17	20
1457	V5668	161	2026-03-24 00:26:03.643221	PAID	4	[{"method": "EFECTIVO", "amount": 161, "displayAmount": 200, "type": null, "id": 1774358683793, "received": 200, "cambio": 39}]	29	16	20
1620	V2396	50	2026-03-24 13:24:50.707727	PAID	6	[{"method": "EFECTIVO", "amount": 50, "displayAmount": 200, "type": null, "id": 1774358741000, "received": 200, "cambio": 150}]	29	14	20
1621	V2417	61	2026-03-24 13:26:13.9137	PAID	4	[{"method": "TARJETA", "amount": 61, "displayAmount": 61, "type": "DEBITO", "id": 1774358841719}]	29	16	20
1622	V1065	26	2026-03-24 13:27:49.72414	PAID	6	[{"method": "EFECTIVO", "amount": 26, "displayAmount": 26, "type": null, "id": 1774358901711, "received": 26, "cambio": 0}]	29	14	20
1624	V5539	164	2026-03-24 13:28:40.384283	PAID	3	[{"method": "EFECTIVO", "amount": 164, "displayAmount": 164, "type": null, "id": 1774358942437, "received": 164, "cambio": 0}]	29	17	20
1623	V2919	17	2026-03-24 13:28:33.49119	PAID	6	[{"method": "EFECTIVO", "amount": 17, "displayAmount": 17, "type": null, "id": 1774358998665, "received": 17, "cambio": 0}]	29	14	20
1627	V6961	32	2026-03-24 13:35:17.514203	PAID	4	[{"method": "EFECTIVO", "amount": 32, "displayAmount": 32, "type": null, "id": 1774359621982, "received": 32, "cambio": 0}]	29	16	20
1638	V5849	68	2026-03-24 13:51:33.797404	PAID	3	[{"method": "EFECTIVO", "amount": 68, "received": 68, "cambio": 0, "displayAmount": 68, "type": null, "id": 1774492752356}]	35	24	3
1632	V4858	70	2026-03-24 13:38:23.821692	PAID	4	[{"method": "EFECTIVO", "amount": 70, "displayAmount": 70, "type": null, "id": 1774359652463, "received": 70, "cambio": 0}]	29	16	20
1637	V2797	129	2026-03-24 13:46:17.199584	PAID	3	[{"method": "EFECTIVO", "amount": 129, "displayAmount": 200, "type": null, "id": 1774359988082, "received": 200, "cambio": 71}]	29	17	20
1636	V4203	82	2026-03-24 13:43:18.908843	PAID	2	[{"method": "EFECTIVO", "amount": 82, "displayAmount": 100, "type": null, "id": 1774534603808, "received": 100, "cambio": 18}]	69	14	20
1641	V4990	43	2026-03-24 13:58:06.592507	PAID	3	[{"method": "EFECTIVO", "amount": 43, "displayAmount": 43, "type": null, "id": 1774360812076, "received": 43, "cambio": 0}]	29	17	20
1628	V9232	42	2026-03-24 13:35:34.726697	PAID	3	[{"method": "EFECTIVO", "amount": 42, "displayAmount": 42, "type": null, "id": 1774632696121, "received": 42, "cambio": 0}]	71	20	20
1625	V9802	38	2026-03-24 13:29:16.84499	PAID	6	[{"method": "EFECTIVO", "amount": 38, "displayAmount": 38, "type": null, "id": 1774358988466, "received": 38, "cambio": 0}]	29	14	20
1629	V5855	63	2026-03-24 13:36:23.338592	PAID	3	[{"method": "EFECTIVO", "amount": 63, "displayAmount": 100, "type": null, "id": 1774359391285, "received": 100, "cambio": 37}]	29	17	20
1630	V3199	54	2026-03-24 13:36:59.605961	PAID	4	[{"method": "EFECTIVO", "amount": 54, "displayAmount": 54, "type": null, "id": 1774359636531, "received": 54, "cambio": 0}]	29	16	20
1633	V6932	38	2026-03-24 13:39:22.513294	PAID	4	[{"method": "EFECTIVO", "amount": 38, "displayAmount": 38, "type": null, "id": 1774359664442, "received": 38, "cambio": 0}]	29	16	20
1635	V6462	65	2026-03-24 13:41:20.402449	PAID	3	[{"method": "EFECTIVO", "amount": 65, "displayAmount": 100, "type": null, "id": 1774359691601, "received": 100, "cambio": 35}]	29	17	20
1639	V8327	66	2026-03-24 13:53:58.1583	PAID	3	[{"method": "EFECTIVO", "amount": 66, "displayAmount": 100, "type": null, "id": 1774360456835, "received": 100, "cambio": 34}]	29	17	20
1634	V7213	26	2026-03-24 13:40:42.11984	PAID	3	[{"method": "EFECTIVO", "amount": 26, "displayAmount": 26, "type": null, "id": 1774360845859, "received": 26, "cambio": 0}]	29	17	20
1642	V9852	50	2026-03-24 14:00:30.563476	PAID	5	[{"method": "EFECTIVO", "amount": 50, "displayAmount": 50, "type": null, "id": 1774360857086, "received": 50, "cambio": 0}]	29	20	20
1626	V8488	32	2026-03-24 13:34:37.798996	PAID	4	[{"method": "EFECTIVO", "amount": 32, "displayAmount": 32, "type": null, "id": 1774360867380, "received": 32, "cambio": 0}]	29	16	20
1640	V1269	44	2026-03-24 13:55:01.063852	PAID	4	[{"method": "EFECTIVO", "amount": 44, "displayAmount": 50, "type": null, "id": 1774624432696, "received": 50, "cambio": 6}]	71	15	20
1631	V2011	56	2026-03-24 13:38:13.63745	PAID	3	[{"method": "EFECTIVO", "amount": 56, "displayAmount": 56, "type": null, "id": 1774360970706, "received": 56, "cambio": 0}]	29	17	20
1646	V8453	68	2026-03-24 14:19:04.087029	PAID	4	[{"method": "EFECTIVO", "amount": 68, "displayAmount": 100, "type": null, "id": 1774361969634, "received": 100, "cambio": 32}]	29	16	20
1653	V4146	78	2026-03-24 14:26:08.074068	PAID	3	[{"method": "EFECTIVO", "amount": 78, "displayAmount": 100, "type": null, "id": 1774362379194, "received": 100, "cambio": 22}]	29	20	20
1663	V3320	63	2026-03-24 14:45:41.03766	PAID	5	[{"method": "EFECTIVO", "amount": 63, "displayAmount": 100, "type": null, "id": 1774363572158, "received": 100, "cambio": 37}]	29	15	20
1667	V6210	46	2026-03-24 14:47:19.036544	PAID	5	[{"method": "EFECTIVO", "amount": 46, "displayAmount": 100, "type": null, "id": 1774363695248, "received": 100, "cambio": 54}]	29	15	20
1644	V3260	23	2026-03-24 14:13:03.119075	PAID	4	[{"method": "EFECTIVO", "amount": 23, "displayAmount": 23, "type": null, "id": 1774364684406, "received": 23, "cambio": 0}]	29	16	20
2344	V3879	62	2026-03-26 15:16:48.120097	PAID	6	[{"method": "EFECTIVO", "amount": 62, "displayAmount": 62, "type": null, "id": 1774538220474, "received": 62, "cambio": 0}]	69	20	20
1664	V4210	32	2026-03-24 14:46:36.814047	PAID	4	[{"method": "EFECTIVO", "amount": 32, "displayAmount": 32, "type": null, "id": 1774365067295, "received": 32, "cambio": 0}]	29	17	20
1683	V4071	113	2026-03-24 15:14:10.523719	PAID	3	[{"method": "EFECTIVO", "amount": 113, "displayAmount": 120, "type": null, "id": 1774365268463, "received": 120, "cambio": 7}]	29	17	20
1689	V7633	38	2026-03-24 15:24:27.891174	PAID	3	[{"method": "EFECTIVO", "amount": 38, "displayAmount": 38, "type": null, "id": 1774374340751, "received": 38, "cambio": 0}]	29	20	20
1687	V7038	42	2026-03-24 15:21:07.527884	PAID	5	[{"method": "EFECTIVO", "amount": 42, "displayAmount": 42, "type": null, "id": 1774374434889, "received": 42, "cambio": 0}]	29	16	20
1691	V7298	50	2026-03-24 15:46:40.889774	PAID	5	[{"method": "EFECTIVO", "amount": 50, "displayAmount": 50, "type": null, "id": 1774374465034, "received": 50, "cambio": 0}]	29	16	20
1693	V5593	64	2026-03-24 15:50:34.052807	PAID	5	[{"method": "EFECTIVO", "amount": 64, "displayAmount": 64, "type": null, "id": 1774374481750, "received": 64, "cambio": 0}]	29	16	20
1643	V8866	49	2026-03-24 14:11:32.121985	PAID	6	[{"method": "EFECTIVO", "amount": 49, "displayAmount": 49, "type": null, "id": 1774374657509, "received": 49, "cambio": 0}]	29	17	20
1666	V4617	30	2026-03-24 14:46:45.531825	PAID	1	[{"method": "EFECTIVO", "amount": 30, "displayAmount": 30, "type": null, "id": 1774374730283, "received": 30, "cambio": 0}]	29	16	20
2345	V2498	68	2026-03-26 15:18:28.231339	PAID	4	[{"method": "EFECTIVO", "amount": 68, "displayAmount": 200, "type": null, "id": 1774538319858, "received": 200, "cambio": 132}]	69	14	20
2346	V2423	84	2026-03-26 15:21:34.249392	PAID	6	[{"method": "EFECTIVO", "amount": 84, "displayAmount": 100, "type": null, "id": 1774538502629, "received": 100, "cambio": 16}]	69	20	20
2360	V3316	307	2026-03-26 16:21:02.402561	PAID	4	[{"method": "EFECTIVO", "amount": 307, "received": 307, "cambio": 0, "displayAmount": 307, "type": null, "id": 1774578902219}]	70	13	1
2355	V4837	78	2026-03-26 15:43:30.06627	PAID	5	[{"method": "EFECTIVO", "amount": 78, "displayAmount": 78, "type": null, "id": 1774542348900, "received": 78, "cambio": 0}]	69	15	20
2356	V2414	37	2026-03-26 15:50:13.897157	PAID	5	[{"method": "EFECTIVO", "amount": 37, "displayAmount": 37, "type": null, "id": 1774542355376, "received": 37, "cambio": 0}]	69	15	20
2363	V7000	22	2026-03-26 16:57:38.883858	PAID	4	[{"method": "EFECTIVO", "amount": 22, "displayAmount": 500, "type": null, "id": 1774544269914, "received": 500, "cambio": 478}]	69	20	20
2365	V7451	55	2026-03-26 17:04:53.150422	PAID	2	[{"method": "EFECTIVO", "amount": 55, "displayAmount": 500, "type": null, "id": 1774544691226, "received": 500, "cambio": 445}]	69	20	\N
2366	V9342	444	2026-03-26 18:02:11.678888	PAID	4	[{"method": "EFECTIVO", "amount": 444, "displayAmount": 1000, "type": null, "id": 1774548144596, "received": 1000, "cambio": 556}]	69	20	20
846	V7830	203	2026-03-22 01:22:03.428104	PAID	5	[{"method": "EFECTIVO", "amount": 203, "displayAmount": 503, "type": null, "id": 1774549416190, "received": 503, "cambio": 300}]	69	20	20
2368	V3515	58	2026-03-26 18:32:14.861941	PAID	2	[{"method": "EFECTIVO", "amount": 58, "displayAmount": 100, "type": null, "id": 1774549933549, "received": 100, "cambio": 42}]	69	20	\N
2372	V6834	228	2026-03-26 19:56:28.189958	PAID	2	[{"method": "EFECTIVO", "amount": 228, "displayAmount": 528, "type": null, "id": 1774554984150, "received": 528, "cambio": 300}]	69	20	\N
391	V9535	130	2026-03-21 01:57:57.762471	PAID	5	[{"method": "EFECTIVO", "amount": 130, "displayAmount": 130, "type": null, "id": 1774557686333, "received": 130, "cambio": 0}]	69	15	20
1645	V9091	82	2026-03-24 14:13:25.947751	PAID	3	[{"method": "EFECTIVO", "amount": 82, "displayAmount": 100, "type": null, "id": 1774361618165, "received": 100, "cambio": 18}]	29	20	20
1649	V3496	58	2026-03-24 14:23:28.713238	PAID	3	[{"method": "EFECTIVO", "amount": 58, "displayAmount": 70, "type": null, "id": 1774362221655, "received": 70, "cambio": 12}]	29	20	20
1656	V5965	74	2026-03-24 14:29:02.865116	PAID	5	[{"method": "EFECTIVO", "amount": 74, "displayAmount": 100, "type": null, "id": 1774362558474, "received": 100, "cambio": 26}]	29	14	20
1658	V2500	63	2026-03-24 14:35:16.161736	PAID	5	[{"method": "EFECTIVO", "amount": 63, "displayAmount": 63, "type": null, "id": 1774362933983, "received": 63, "cambio": 0}]	29	14	20
1662	V1382	90	2026-03-24 14:44:10.351173	PAID	2	[{"method": "TARJETA", "amount": 90, "displayAmount": 90, "type": "DEBITO", "id": 1774363451109}]	29	20	\N
1670	V7504	39	2026-03-24 14:56:36.753853	PAID	3	[{"method": "EFECTIVO", "amount": 39, "received": 39, "cambio": 0, "displayAmount": 39, "type": null, "id": 1774364560749}]	29	17	20
1647	V7667	37	2026-03-24 14:19:05.548619	PAID	3	[{"method": "EFECTIVO", "amount": 37, "displayAmount": 37, "type": null, "id": 1774364600335, "received": 37, "cambio": 0}]	29	20	20
1660	V2699	47	2026-03-24 14:41:00.58638	PAID	5	[{"method": "EFECTIVO", "amount": 47, "displayAmount": 47, "type": null, "id": 1774364673596, "received": 47, "cambio": 0}]	29	14	20
1671	V4075	24	2026-03-24 14:57:09.121411	PAID	4	[{"method": "EFECTIVO", "amount": 24, "displayAmount": 24, "type": null, "id": 1774365075563, "received": 24, "cambio": 0}]	29	16	20
1685	V5464	34	2026-03-24 15:20:16.418856	PAID	3	[{"method": "EFECTIVO", "amount": 34, "displayAmount": 34, "type": null, "id": 1774374309785, "received": 34, "cambio": 0}]	29	20	20
2369	V4870	127	2026-03-26 18:56:01.686477	PAID	2	[{"method": "EFECTIVO", "amount": 127, "displayAmount": 200, "type": null, "id": 1774551360011, "received": 200, "cambio": 73}]	69	20	\N
1690	V6066	30	2026-03-24 15:38:08.025261	PAID	5	[{"method": "EFECTIVO", "amount": 30, "displayAmount": 30, "type": null, "id": 1774374443915, "received": 30, "cambio": 0}]	29	16	20
1672	V9522	21	2026-03-24 14:58:04.796769	PAID	4	[{"method": "EFECTIVO", "amount": 21, "displayAmount": 21, "type": null, "id": 1774374542728, "received": 21, "cambio": 0}]	29	16	20
1673	V1716	29	2026-03-24 14:58:51.081596	PAID	4	[{"method": "EFECTIVO", "amount": 29, "displayAmount": 29, "type": null, "id": 1774374550972, "received": 29, "cambio": 0}]	29	16	20
1682	V8009	40	2026-03-24 15:10:20.858923	PAID	4	[{"method": "EFECTIVO", "amount": 40, "displayAmount": 40, "type": null, "id": 1774374749234, "received": 40, "cambio": 0}]	29	16	20
2371	V7874	132	2026-03-26 19:39:10.664254	PAID	2	[{"method": "EFECTIVO", "amount": 132, "displayAmount": 132, "type": null, "id": 1774553946763, "received": 132, "cambio": 0}]	69	20	\N
1686	V1953	108	2026-03-24 15:21:01.23948	PAID	3	[{"method": "EFECTIVO", "amount": 108, "received": 110, "cambio": 2, "displayAmount": 110, "type": null, "id": 1774490532921}]	35	4	3
2373	V8085	37	2026-03-26 20:04:27.620629	PAID	4	[{"method": "EFECTIVO", "amount": 37, "displayAmount": 37, "type": null, "id": 1774557729968, "received": 37, "cambio": 0}]	69	20	20
2570	V7867	64	2026-03-27 13:16:57.235055	PAID	6	[{"method": "EFECTIVO", "amount": 64, "displayAmount": 200, "type": null, "id": 1774617427109, "received": 200, "cambio": 136}]	71	17	20
2573	V9284	35	2026-03-27 13:19:01.576501	PAID	6	[{"method": "EFECTIVO", "amount": 35, "displayAmount": 35, "type": null, "id": 1774617591061, "received": 35, "cambio": 0}]	71	17	20
2572	V4034	19	2026-03-27 13:18:57.371653	PAID	3	[{"method": "EFECTIVO", "amount": 19, "displayAmount": 19, "type": null, "id": 1774617597333, "received": 19, "cambio": 0}]	71	15	20
2574	V2716	91	2026-03-27 13:20:11.662363	PAID	3	[{"method": "EFECTIVO", "amount": 91, "displayAmount": 500, "type": null, "id": 1774617621713, "received": 500, "cambio": 409}]	71	15	20
2578	V4340	68	2026-03-27 13:38:04.164143	PAID	5	[{"method": "EFECTIVO", "amount": 68, "displayAmount": 200, "type": null, "id": 1774618691283, "received": 200, "cambio": 132}]	71	17	20
2579	V8194	75	2026-03-27 13:44:20.455868	PAID	5	[{"method": "EFECTIVO", "amount": 75, "displayAmount": 100, "type": null, "id": 1774619111313, "received": 100, "cambio": 25}]	71	15	20
2583	V2294	58	2026-03-27 13:47:51.612704	PAID	4	[{"method": "EFECTIVO", "amount": 58, "displayAmount": 58, "type": null, "id": 1774619297424, "received": 58, "cambio": 0}]	71	14	20
2577	V4953	52	2026-03-27 13:31:17.949489	PAID	3	[{"method": "EFECTIVO", "amount": 52, "displayAmount": 52, "type": null, "id": 1774619455198, "received": 52, "cambio": 0}]	71	17	20
2588	V4848	6	2026-03-27 13:52:51.287597	PAID	3	[{"method": "EFECTIVO", "amount": 6, "displayAmount": 6, "type": null, "id": 1774619675468, "received": 6, "cambio": 0}]	71	16	20
2595	V6973	52	2026-03-27 14:12:47.278687	PAID	1	[{"method": "EFECTIVO", "amount": 52, "displayAmount": 100, "type": null, "id": 1774620775676, "received": 100, "cambio": 48}]	71	20	20
2597	V2509	67	2026-03-27 14:16:31.039547	PAID	1	[{"method": "EFECTIVO", "amount": 67, "displayAmount": 100, "type": null, "id": 1774620999728, "received": 100, "cambio": 33}]	71	20	20
2598	V9028	126	2026-03-27 14:20:08.518093	PAID	1	[{"method": "EFECTIVO", "amount": 126, "displayAmount": 527, "type": null, "id": 1774621242019, "received": 527, "cambio": 401}]	71	20	20
2600	V7039	73	2026-03-27 14:22:51.909038	PAID	3	[{"method": "EFECTIVO", "amount": 73, "displayAmount": 100, "type": null, "id": 1774621385297, "received": 100, "cambio": 27}]	71	15	20
2601	V1242	29	2026-03-27 14:23:49.152769	PAID	3	[{"method": "EFECTIVO", "amount": 29, "displayAmount": 500, "type": null, "id": 1774621443038, "received": 500, "cambio": 471}]	71	15	20
2594	V7253	52	2026-03-27 14:10:57.462459	PAID	3	[{"method": "EFECTIVO", "amount": 52, "displayAmount": 52, "type": null, "id": 1774621644390, "received": 52, "cambio": 0}]	71	15	20
2604	V3637	62	2026-03-27 14:29:17.662093	PAID	5	[{"method": "EFECTIVO", "amount": 62, "displayAmount": 70, "type": null, "id": 1774621770605, "received": 70, "cambio": 8}]	71	15	20
2608	V2889	88	2026-03-27 14:34:05.614765	PAID	3	[{"method": "EFECTIVO", "amount": 88, "displayAmount": 200, "type": null, "id": 1774622058202, "received": 200, "cambio": 112}]	71	15	20
2609	V9741	40	2026-03-27 14:38:49.245666	PAID	1	[{"method": "EFECTIVO", "amount": 40, "displayAmount": 500, "type": null, "id": 1774622349451, "received": 500, "cambio": 460}]	71	20	20
2611	V5188	48	2026-03-27 14:39:29.042029	PAID	3	[{"method": "EFECTIVO", "amount": 48, "displayAmount": 48, "type": null, "id": 1774622555858, "received": 48, "cambio": 0}]	71	15	20
1648	V4958	60	2026-03-24 14:20:01.557226	PAID	3	[{"method": "EFECTIVO", "amount": 60, "displayAmount": 100, "type": null, "id": 1774362012544, "received": 100, "cambio": 40}]	29	20	20
1654	V1948	58	2026-03-24 14:26:56.779069	PAID	5	[{"method": "EFECTIVO", "amount": 58, "displayAmount": 100, "type": null, "id": 1774362432732, "received": 100, "cambio": 42}]	29	14	20
1655	V3132	34	2026-03-24 14:28:40.705916	PAID	3	[{"method": "EFECTIVO", "amount": 34, "displayAmount": 50, "type": null, "id": 1774362531347, "received": 50, "cambio": 16}]	29	20	20
1657	V6654	54	2026-03-24 14:34:00.431314	PAID	5	[{"method": "EFECTIVO", "amount": 54, "displayAmount": 54, "type": null, "id": 1774362853244, "received": 54, "cambio": 0}]	29	14	20
1659	V3868	99	2026-03-24 14:39:59.931418	PAID	5	[{"method": "EFECTIVO", "amount": 99, "displayAmount": 500, "type": null, "id": 1774363213898, "received": 500, "cambio": 401}]	29	14	20
1661	V4057	160	2026-03-24 14:43:58.7277	PAID	5	[{"method": "EFECTIVO", "amount": 160, "displayAmount": 160, "type": null, "id": 1774363499750, "received": 160, "cambio": 0}]	29	14	20
1665	V6418	27	2026-03-24 14:46:44.088182	PAID	3	[{"method": "EFECTIVO", "amount": 27, "displayAmount": 200, "type": null, "id": 1774531868590, "received": 200, "cambio": 173}]	69	14	20
1668	V4362	61	2026-03-24 14:48:42.122432	PAID	3	[{"method": "EFECTIVO", "amount": 61, "displayAmount": 500, "type": null, "id": 1774363735086, "received": 500, "cambio": 439}]	29	20	20
1675	V7751	64	2026-03-24 14:59:44.789167	PAID	3	[{"method": "EFECTIVO", "amount": 64, "displayAmount": 100, "type": null, "id": 1774364406141, "received": 100, "cambio": 36}]	29	17	20
1674	V5663	38	2026-03-24 14:59:13.389004	PAID	3	[{"method": "EFECTIVO", "amount": 38, "displayAmount": 38, "type": null, "id": 1774364571059, "received": 38, "cambio": 0}]	29	17	20
1676	V5357	26	2026-03-24 15:01:45.161487	PAID	3	[{"method": "EFECTIVO", "amount": 26, "displayAmount": 26, "type": null, "id": 1774364581920, "received": 26, "cambio": 0}]	29	17	20
1697	V2813	69	2026-03-24 17:04:26.642612	PAID	3	[{"method": "EFECTIVO", "amount": 69, "displayAmount": 69, "type": null, "id": 1774374352457, "received": 69, "cambio": 0}]	29	17	20
1650	V7160	20	2026-03-24 14:24:18.062636	PAID	5	[{"method": "EFECTIVO", "amount": 20, "displayAmount": 30, "type": null, "id": 1774364622591, "received": 30, "cambio": 10}]	29	14	20
1669	V6644	38	2026-03-24 14:49:25.40736	PAID	5	[{"method": "EFECTIVO", "amount": 38, "received": 38, "cambio": 0, "displayAmount": 38, "type": null, "id": 1774364652671}]	29	16	20
1678	V4009	38	2026-03-24 15:06:53.189517	PAID	2	[{"method": "EFECTIVO", "amount": 38, "displayAmount": 40, "type": null, "id": 1774364814533, "received": 40, "cambio": 2}]	29	20	\N
1681	V2880	55	2026-03-24 15:09:43.030428	PAID	3	[{"method": "EFECTIVO", "amount": 55, "displayAmount": 505, "type": null, "id": 1774535282869, "received": 505, "cambio": 450}]	69	14	20
1680	V4994	30	2026-03-24 15:09:16.001935	PAID	3	[{"method": "EFECTIVO", "amount": 30, "received": 30, "cambio": 0, "displayAmount": 30, "type": null, "id": 1774489394116}]	35	4	3
1694	V4004	55	2026-03-24 16:07:25.636734	PAID	3	[{"method": "EFECTIVO", "amount": 55, "displayAmount": 100, "type": null, "id": 1774368464726, "received": 100, "cambio": 45}]	29	17	20
1696	V3971	83	2026-03-24 16:29:37.32238	PAID	3	[{"method": "EFECTIVO", "amount": 83, "displayAmount": 103, "type": null, "id": 1774369799594, "received": 103, "cambio": 20}]	29	17	20
1699	V8377	83	2026-03-24 17:37:06.7988	PAID	2	[{"method": "EFECTIVO", "amount": 83, "displayAmount": 100, "type": null, "id": 1774373824812, "received": 100, "cambio": 17}]	29	20	\N
1651	V4065	29	2026-03-24 14:25:03.432162	PAID	3	[{"method": "EFECTIVO", "amount": 29, "displayAmount": 29, "type": null, "id": 1774374288298, "received": 29, "cambio": 0}]	29	20	20
1679	V8875	51	2026-03-24 15:07:46.762515	PAID	3	[{"method": "EFECTIVO", "amount": 51, "displayAmount": 51, "type": null, "id": 1774374300469, "received": 51, "cambio": 0}]	29	17	20
1688	V1528	77	2026-03-24 15:23:08.296779	PAID	3	[{"method": "EFECTIVO", "amount": 77, "received": 77, "cambio": 0, "displayAmount": 77, "type": null, "id": 1774374333036}]	29	20	20
1652	V3203	43	2026-03-24 14:25:38.470266	PAID	5	[{"method": "EFECTIVO", "amount": 43, "displayAmount": 43, "type": null, "id": 1774374423484, "received": 43, "cambio": 0}]	29	16	20
1695	V4095	40	2026-03-24 16:25:53.824505	PAID	5	[{"method": "EFECTIVO", "amount": 40, "displayAmount": 40, "type": null, "id": 1774374493264, "received": 40, "cambio": 0}]	29	16	20
1698	V9396	20	2026-03-24 17:35:08.111175	PAID	5	[{"method": "EFECTIVO", "amount": 20, "displayAmount": 20, "type": null, "id": 1774374502389, "received": 20, "cambio": 0}]	29	16	20
1677	V6578	24	2026-03-24 15:01:45.509106	PAID	4	[{"method": "EFECTIVO", "amount": 24, "displayAmount": 24, "type": null, "id": 1774374560330, "received": 24, "cambio": 0}]	29	16	20
1692	V3831	23	2026-03-24 15:48:38.874131	PAID	5	[{"method": "EFECTIVO", "amount": 23, "displayAmount": 23, "type": null, "id": 1774374573734, "received": 23, "cambio": 0}]	29	16	20
1684	V5052	17	2026-03-24 15:17:13.640131	PAID	4	[{"method": "EFECTIVO", "amount": 1, "displayAmount": 1, "type": null, "id": 1774374588032, "received": 1, "cambio": 0}, {"method": "EFECTIVO", "amount": 16, "displayAmount": 17, "type": null, "id": 1774374599871, "received": 17, "cambio": 1}]	29	16	20
1700	V2003	40	2026-03-24 17:50:29.837501	PAID	2	[{"method": "EFECTIVO", "amount": 40, "displayAmount": 40, "type": null, "id": 1774374630535, "received": 40, "cambio": 0}]	29	20	\N
1701	V3488	99	2026-03-24 18:25:01.652414	PAID	2	[{"method": "EFECTIVO", "amount": 99, "displayAmount": 99, "type": null, "id": 1774376704410, "received": 99, "cambio": 0}]	29	20	\N
1709	V9113	32	2026-03-24 20:19:50.293234	PAID	3	[{"method": "EFECTIVO", "amount": 32, "received": 32, "cambio": 0, "displayAmount": 32, "type": null, "id": 1774576004601}]	70	4	1
1710	V8332	87	2026-03-24 20:28:32.821681	PAID	5	[{"method": "EFECTIVO", "amount": 87, "received": 200, "cambio": 113, "displayAmount": 200, "type": null, "id": 1774384139543}]	29	9	20
1702	V4610	34	2026-03-24 19:07:55.996083	PAID	5	[{"method": "EFECTIVO", "amount": 34, "received": 34, "cambio": 0, "displayAmount": 34, "type": null, "id": 1774384176902}]	29	16	20
1704	V8833	67	2026-03-24 19:11:08.783168	PAID	5	[{"method": "EFECTIVO", "amount": 67, "received": 67, "cambio": 0, "displayAmount": 67, "type": null, "id": 1774384190644}]	29	16	20
1707	V8946	245	2026-03-24 19:58:11.501298	PAID	5	[{"method": "EFECTIVO", "amount": 245, "received": 245, "cambio": 0, "displayAmount": 245, "type": null, "id": 1774384231166}]	29	15	20
1703	V9491	50	2026-03-24 19:08:46.39951	PAID	5	[{"method": "EFECTIVO", "amount": 50, "received": 50, "cambio": 0, "displayAmount": 50, "type": null, "id": 1774384183210}]	29	16	20
1708	V8503	48	2026-03-24 20:00:53.907354	PAID	5	[{"method": "EFECTIVO", "amount": 48, "received": 48, "cambio": 0, "displayAmount": 48, "type": null, "id": 1774384305827}]	29	15	20
1711	V4273	9	2026-03-24 20:31:51.954219	PAID	5	[{"method": "EFECTIVO", "amount": 9, "received": 9, "cambio": 0, "displayAmount": 9, "type": null, "id": 1774384704816}]	29	9	20
1714	V8076	49	2026-03-24 20:46:03.978019	PAID	3	[{"method": "EFECTIVO", "amount": 49, "received": 200, "cambio": 151, "displayAmount": 200, "type": null, "id": 1774385185280}]	29	20	20
2383	V3605	39	2026-03-26 21:12:08.464087	PAID	5	[{"method": "EFECTIVO", "amount": 39, "received": 50, "cambio": 11, "displayAmount": 50, "type": null, "id": 1774559534898}]	70	4	1
1719	V2594	76	2026-03-24 21:11:35.101738	PAID	5	[{"method": "EFECTIVO", "amount": 76, "received": 76, "cambio": 0, "displayAmount": 76, "type": null, "id": 1774386728286}]	29	9	20
1713	V7231	77	2026-03-24 20:45:13.054759	PAID	3	[{"method": "EFECTIVO", "amount": 77, "received": 77, "cambio": 0, "displayAmount": 77, "type": null, "id": 1774387245238}]	29	20	20
1726	V7286	51	2026-03-24 21:43:52.732319	PAID	5	[{"method": "EFECTIVO", "amount": 51, "received": 51, "cambio": 0, "displayAmount": 51, "type": null, "id": 1774388649294}]	29	9	20
1727	V5870	38	2026-03-24 21:56:31.62119	PAID	5	[{"method": "EFECTIVO", "amount": 38, "received": 50, "cambio": 12, "displayAmount": 50, "type": null, "id": 1774389470915}]	29	9	20
1731	V1141	82	2026-03-24 22:05:42.107074	PAID	3	[{"method": "EFECTIVO", "amount": 82, "received": 82, "cambio": 0, "displayAmount": 82, "type": null, "id": 1774390063258}]	29	13	20
1739	V2644	98	2026-03-24 22:23:03.778831	PAID	3	[{"method": "EFECTIVO", "amount": 98, "received": 100, "cambio": 2, "displayAmount": 100, "type": null, "id": 1774391003386}]	29	13	20
1740	V5364	180	2026-03-24 22:24:08.941399	PAID	5	[{"method": "EFECTIVO", "amount": 180, "received": 500, "cambio": 320, "displayAmount": 500, "type": null, "id": 1774391062643}]	29	8	20
1743	V9326	36	2026-03-24 22:29:47.849689	PAID	5	[{"method": "EFECTIVO", "amount": 36, "received": 50, "cambio": 14, "displayAmount": 50, "type": null, "id": 1774391417147}]	29	13	20
1744	V6167	25	2026-03-24 22:33:00.532314	PAID	3	[{"method": "EFECTIVO", "amount": 25, "received": 50, "cambio": 25, "displayAmount": 50, "type": null, "id": 1774391588820}]	29	13	20
1748	V1122	76	2026-03-24 22:41:41.366058	PAID	5	[{"method": "EFECTIVO", "amount": 76, "received": 100, "cambio": 24, "displayAmount": 100, "type": null, "id": 1774392172071}]	29	13	20
1759	V2317	32	2026-03-24 23:15:27.707083	PAID	3	[{"method": "EFECTIVO", "amount": 32, "received": 32, "cambio": 0, "displayAmount": 32, "type": null, "id": 1774394968705}]	29	13	20
1762	V9165	32	2026-03-24 23:31:14.670043	PAID	5	[{"method": "EFECTIVO", "amount": 32, "received": 50, "cambio": 18, "displayAmount": 50, "type": null, "id": 1774395096850}]	29	9	20
1751	V3731	14	2026-03-24 22:49:39.640557	PAID	3	[{"method": "EFECTIVO", "amount": 14, "received": 14, "cambio": 0, "displayAmount": 14, "type": null, "id": 1774396004445}]	29	13	20
1774	V6818	119	2026-03-24 23:54:23.285758	PAID	4	[{"method": "EFECTIVO", "amount": 119, "received": 200, "cambio": 81, "displayAmount": 200, "type": null, "id": 1774396495134}]	29	8	20
1776	V6789	206	2026-03-24 23:55:52.042297	PAID	3	[{"method": "EFECTIVO", "amount": 206, "received": 206, "cambio": 0, "displayAmount": 206, "type": null, "id": 1774396577152}]	29	4	20
1771	V3871	56	2026-03-24 23:50:26.214234	PAID	4	[{"method": "EFECTIVO", "amount": 56, "received": 500, "cambio": 444, "displayAmount": 500, "type": null, "id": 1774396658499}]	29	8	20
7	V8843	41	2026-03-13 20:17:52.822758	PAID	3	[{"method": "EFECTIVO", "amount": 41, "received": 41, "cambio": 0, "displayAmount": 41, "type": null, "id": 1774397298074}]	29	8	20
1789	V5198	64	2026-03-25 00:14:28.658265	PAID	3	[{"method": "EFECTIVO", "amount": 64, "received": 64, "cambio": 0, "displayAmount": 64, "type": null, "id": 1774397804830}]	30	13	3
1788	V1079	82	2026-03-25 00:12:34.069275	PAID	3	[{"method": "EFECTIVO", "amount": 82, "received": 82, "cambio": 0, "displayAmount": 82, "type": null, "id": 1774397813139}]	30	13	3
1753	V8007	86	2026-03-24 22:52:59.685194	PAID	3	[{"method": "EFECTIVO", "amount": 86, "displayAmount": 86, "type": null, "id": 1774542380715, "received": 86, "cambio": 0}]	69	15	20
1705	V1915	67	2026-03-24 19:15:28.610551	PAID	5	[{"method": "EFECTIVO", "amount": 67, "received": 67, "cambio": 0, "displayAmount": 67, "type": null, "id": 1774407813381}]	30	8	3
2375	V7590	130	2026-03-26 20:22:08.2727	PAID	3	[{"method": "EFECTIVO", "amount": 130, "displayAmount": 130, "type": null, "id": 1774557774671, "received": 130, "cambio": 0}]	69	24	20
1717	V1967	70	2026-03-24 21:01:54.771069	PAID	5	[{"method": "EFECTIVO", "amount": 70, "displayAmount": 70, "type": null, "id": 1774449634644, "received": 70, "cambio": 0}]	31	16	20
2374	V7727	50	2026-03-26 20:16:37.475603	PAID	3	[{"method": "EFECTIVO", "amount": 50, "displayAmount": 50, "type": null, "id": 1774557781996, "received": 50, "cambio": 0}]	69	24	20
2377	V9138	248	2026-03-26 20:59:40.448826	PAID	3	[{"method": "EFECTIVO", "amount": 248, "received": 248, "cambio": 0, "displayAmount": 248, "type": null, "id": 1774558804876}]	69	24	20
2379	V9230	168	2026-03-26 21:04:31.664175	PAID	3	[{"method": "EFECTIVO", "amount": 168, "received": 500, "cambio": 332, "displayAmount": 500, "type": null, "id": 1774559078208}]	69	24	20
2381	V8822	64	2026-03-26 21:09:43.871617	PAID	5	[{"method": "EFECTIVO", "amount": 64, "received": 64, "cambio": 0, "displayAmount": 64, "type": null, "id": 1774559461816}]	70	4	1
2384	V8511	80	2026-03-26 21:20:23.555147	PAID	5	[{"method": "EFECTIVO", "amount": 80, "received": 500, "cambio": 420, "displayAmount": 500, "type": null, "id": 1774560048880}]	70	4	1
2386	V4307	97	2026-03-26 22:01:21.870436	PAID	5	[{"method": "EFECTIVO", "amount": 97, "received": 100, "cambio": 3, "displayAmount": 100, "type": null, "id": 1774562490753}]	70	13	1
1359	V1469	258	2026-03-23 20:08:10.45466	PAID	3	[{"method": "EFECTIVO", "amount": 258, "received": 258, "cambio": 0, "displayAmount": 258, "type": null, "id": 1774618836732}]	71	20	20
2585	V3990	173	2026-03-27 13:49:38.562377	PAID	5	[{"method": "EFECTIVO", "amount": 173, "displayAmount": 500, "type": null, "id": 1774619398242, "received": 500, "cambio": 327}]	71	15	20
2586	V6111	32	2026-03-27 13:50:28.432439	PAID	5	[{"method": "EFECTIVO", "amount": 32, "displayAmount": 32, "type": null, "id": 1774619440035, "received": 32, "cambio": 0}]	71	15	20
1706	V4539	16	2026-03-24 19:51:42.323096	PAID	5	[{"method": "EFECTIVO", "amount": 16, "received": 16, "cambio": 0, "displayAmount": 16, "type": null, "id": 1774384216060}]	29	16	20
1715	V6604	84	2026-03-24 20:47:17.062657	PAID	3	[{"method": "EFECTIVO", "amount": 84, "received": 500, "cambio": 416, "displayAmount": 500, "type": null, "id": 1774385245350}]	29	20	20
1716	V7821	73	2026-03-24 20:55:14.139559	PAID	5	[{"method": "EFECTIVO", "amount": 73, "received": 200, "cambio": 127, "displayAmount": 200, "type": null, "id": 1774385740597}]	29	9	20
1721	V4659	95	2026-03-24 21:20:11.03367	PAID	3	[{"method": "EFECTIVO", "amount": 95, "received": 95, "cambio": 0, "displayAmount": 95, "type": null, "id": 1774387235328}]	29	9	20
1722	V9062	95	2026-03-24 21:22:35.481325	PAID	3	[{"method": "EFECTIVO", "amount": 95, "received": 100, "cambio": 5, "displayAmount": 100, "type": null, "id": 1774387366641}]	29	8	20
1724	V7407	74	2026-03-24 21:34:39.895246	PAID	3	[{"method": "EFECTIVO", "amount": 74, "received": 74, "cambio": 0, "displayAmount": 74, "type": null, "id": 1774388087997}]	29	3	20
1729	V3167	38	2026-03-24 22:02:38.32346	PAID	3	[{"method": "EFECTIVO", "amount": 38, "displayAmount": 40, "type": null, "id": 1774389779191, "received": 40, "cambio": 2}]	29	13	20
1737	V2373	41	2026-03-24 22:17:49.08362	PAID	3	[{"method": "EFECTIVO", "amount": 41, "received": 50, "cambio": 9, "displayAmount": 50, "type": null, "id": 1774390691106}]	29	13	20
1738	V4643	35	2026-03-24 22:19:09.716653	PAID	3	[{"method": "EFECTIVO", "amount": 35, "received": 200, "cambio": 165, "displayAmount": 200, "type": null, "id": 1774390772054}]	29	13	20
1742	V9555	123	2026-03-24 22:29:32.725342	PAID	3	[{"method": "EFECTIVO", "amount": 123, "received": 200, "cambio": 77, "displayAmount": 200, "type": null, "id": 1774391383080}]	29	8	20
1752	V2963	39	2026-03-24 22:49:51.878203	PAID	3	[{"method": "EFECTIVO", "amount": 39, "displayAmount": 50, "type": null, "id": 1774392598450, "received": 50, "cambio": 11}]	29	13	20
1758	V9736	27	2026-03-24 23:12:11.133545	PAID	3	[{"method": "EFECTIVO", "amount": 27, "displayAmount": 100, "type": null, "id": 1774393937825, "received": 100, "cambio": 73}]	29	13	20
1778	V3929	58	2026-03-24 23:59:17.416095	PAID	4	[{"method": "EFECTIVO", "amount": 58, "received": 100, "cambio": 42, "displayAmount": 100, "type": null, "id": 1774485650589}]	35	8	3
1763	V7697	105	2026-03-24 23:31:25.683517	PAID	3	[{"method": "EFECTIVO", "amount": 105, "received": 105, "cambio": 0, "displayAmount": 105, "type": null, "id": 1774395133195}]	29	13	20
1767	V1267	142	2026-03-24 23:46:54.003926	PAID	5	[{"method": "EFECTIVO", "amount": 142, "received": 200, "cambio": 58, "displayAmount": 200, "type": null, "id": 1774396046921}]	29	9	20
1775	V4085	34	2026-03-24 23:55:26.476944	PAID	4	[{"method": "EFECTIVO", "amount": 34, "received": 34, "cambio": 0, "displayAmount": 34, "type": null, "id": 1774396548090}]	29	8	20
2362	V9325	59	2026-03-26 16:57:20.711891	PAID	4	[{"method": "EFECTIVO", "amount": 59, "displayAmount": 59, "type": null, "id": 1774557652182, "received": 59, "cambio": 0}]	69	20	20
1779	V5175	42	2026-03-25 00:00:44.227212	PAID	4	[{"method": "EFECTIVO", "amount": 42, "received": 50, "cambio": 8, "displayAmount": 50, "type": null, "id": 1774396859867}]	29	8	20
1782	V7508	52	2026-03-25 00:04:32.715443	PAID	5	[{"method": "EFECTIVO", "amount": 52, "received": 200, "cambio": 148, "displayAmount": 200, "type": null, "id": 1774397100357}]	29	9	20
1003	V5536	129	2026-03-22 15:18:09.959924	PAID	6	[{"method": "EFECTIVO", "amount": 129, "displayAmount": 129, "type": null, "id": 1774557677307, "received": 129, "cambio": 0}]	69	20	20
2376	V6656	37	2026-03-26 20:38:37.443592	PAID	3	[{"method": "EFECTIVO", "amount": 37, "displayAmount": 37, "type": null, "id": 1774557713945, "received": 37, "cambio": 0}]	69	24	20
1786	V8183	57	2026-03-25 00:08:16.167109	PAID	4	[{"method": "EFECTIVO", "amount": 57, "displayAmount": 57, "type": null, "id": 1774622806293, "received": 57, "cambio": 0}]	71	17	20
1783	V1418	59	2026-03-25 00:06:09.1143	PAID	5	[{"method": "EFECTIVO", "amount": 59, "received": 200, "cambio": 141, "displayAmount": 200, "type": null, "id": 1774399984734}]	30	13	3
1732	V4634	63	2026-03-24 22:06:40.456729	PAID	3	[{"method": "EFECTIVO", "amount": 63, "received": 100, "cambio": 37, "displayAmount": 100, "type": null, "id": 1774401187768}]	30	4	3
2382	V5244	66	2026-03-26 21:10:18.569231	PAID	5	[{"method": "EFECTIVO", "amount": 66, "received": 66, "cambio": 0, "displayAmount": 66, "type": null, "id": 1774559492156}]	70	4	1
2385	V2238	75	2026-03-26 21:57:34.435111	PAID	3	[{"method": "EFECTIVO", "amount": 75, "received": 100, "cambio": 25, "displayAmount": 100, "type": null, "id": 1774562273852}]	70	24	1
2602	V1787	35	2026-03-27 14:24:42.730007	PAID	3	[{"method": "EFECTIVO", "amount": 35, "displayAmount": 100, "type": null, "id": 1774621494071, "received": 100, "cambio": 65}]	71	15	20
1757	V7789	39	2026-03-24 23:11:28.564356	PAID	3	[{"method": "EFECTIVO", "amount": 39, "displayAmount": 50, "type": null, "id": 1774618659736, "received": 50, "cambio": 11}]	71	20	20
2587	V1756	14	2026-03-27 13:52:18.441523	PAID	5	[{"method": "EFECTIVO", "amount": 14, "displayAmount": 14, "type": null, "id": 1774619551160, "received": 14, "cambio": 0}]	71	15	20
2593	V9487	76	2026-03-27 14:08:45.22734	PAID	3	[{"method": "EFECTIVO", "amount": 76, "displayAmount": 100, "type": null, "id": 1774620535612, "received": 100, "cambio": 24}]	71	15	20
2596	V1750	126	2026-03-27 14:16:10.389176	PAID	2	[{"method": "TARJETA", "amount": 126, "displayAmount": 126, "type": "DEBITO", "id": 1774620969129}]	71	20	\N
2599	V3584	50	2026-03-27 14:22:19.990494	PAID	4	[{"method": "EFECTIVO", "amount": 50, "displayAmount": 200, "type": null, "id": 1774621356892, "received": 200, "cambio": 150}]	71	16	20
2603	V5334	47	2026-03-27 14:27:39.543759	PAID	3	[{"method": "EFECTIVO", "amount": 47, "displayAmount": 100, "type": null, "id": 1774621665894, "received": 100, "cambio": 53}]	71	15	20
2610	V9886	27	2026-03-27 14:39:26.302075	PAID	4	[{"method": "EFECTIVO", "amount": 27, "displayAmount": 27, "type": null, "id": 1774622542155, "received": 27, "cambio": 0}]	71	16	20
864	V5680	70	2026-03-22 02:05:20.496903	PAID	5	[{"method": "EFECTIVO", "amount": 70, "displayAmount": 70, "type": null, "id": 1774622547768, "received": 70, "cambio": 0}]	71	15	20
2618	V8454	39	2026-03-27 14:52:15.958935	PAID	5	[{"method": "EFECTIVO", "amount": 39, "displayAmount": 200, "type": null, "id": 1774623157116, "received": 200, "cambio": 161}]	71	15	20
2620	V2756	79	2026-03-27 14:57:11.106316	PAID	3	[{"method": "EFECTIVO", "amount": 79, "displayAmount": 80, "type": null, "id": 1774623454387, "received": 80, "cambio": 1}]	71	17	20
1712	V7941	180	2026-03-24 20:36:14.20782	PAID	3	[{"method": "EFECTIVO", "amount": 180, "displayAmount": 200, "type": null, "id": 1774384585721, "received": 200, "cambio": 20}]	29	20	20
1718	V7248	125	2026-03-24 21:02:26.782575	PAID	3	[{"method": "EFECTIVO", "amount": 125, "received": 125, "cambio": 0, "displayAmount": 125, "type": null, "id": 1774386280769}]	29	8	20
1741	V5016	24	2026-03-24 22:26:28.251072	PAID	3	[{"method": "EFECTIVO", "amount": 24, "displayAmount": 100, "type": null, "id": 1774391195595, "received": 100, "cambio": 76}]	29	13	20
1747	V8637	79	2026-03-24 22:41:32.238746	PAID	3	[{"method": "EFECTIVO", "amount": 79, "received": 200, "cambio": 121, "displayAmount": 200, "type": null, "id": 1774392132968}]	29	8	20
2378	V2057	82	2026-03-26 21:02:13.182833	PAID	5	[{"method": "EFECTIVO", "amount": 82, "received": 100, "cambio": 18, "displayAmount": 100, "type": null, "id": 1774558979945}]	69	4	20
1755	V3376	26	2026-03-24 23:00:54.91107	PAID	3	[{"method": "EFECTIVO", "amount": 26, "displayAmount": 26, "type": null, "id": 1774393262632, "received": 26, "cambio": 0}]	29	13	20
1760	V9456	18	2026-03-24 23:24:25.505485	PAID	3	[{"method": "EFECTIVO", "amount": 18, "displayAmount": 18, "type": null, "id": 1774394676830, "received": 18, "cambio": 0}]	29	13	20
1761	V3607	65	2026-03-24 23:29:28.587543	PAID	3	[{"method": "EFECTIVO", "amount": 65, "received": 200, "cambio": 135, "displayAmount": 200, "type": null, "id": 1774394979801}]	29	13	20
1768	V8818	14	2026-03-24 23:47:19.323622	PAID	3	[{"method": "EFECTIVO", "amount": 14, "received": 14, "cambio": 0, "displayAmount": 14, "type": null, "id": 1774396093598}]	29	13	20
1773	V6777	51	2026-03-24 23:54:07.810946	PAID	5	[{"method": "EFECTIVO", "amount": 51, "received": 51, "cambio": 0, "displayAmount": 51, "type": null, "id": 1774396473562}]	29	9	20
1784	V5137	48	2026-03-25 00:06:45.0993	PAID	3	[{"method": "EFECTIVO", "amount": 48, "received": 50, "cambio": 2, "displayAmount": 50, "type": null, "id": 1774397224724}]	29	13	20
1754	V7700	32	2026-03-24 22:53:54.059301	PAID	5	[{"method": "EFECTIVO", "amount": 32, "displayAmount": 100, "type": null, "id": 1774448943434, "received": 100, "cambio": 68}]	31	14	20
2380	V2385	89	2026-03-26 21:07:25.850408	PAID	5	[{"method": "EFECTIVO", "amount": 89, "received": 100, "cambio": 11, "displayAmount": 100, "type": null, "id": 1774559263061}]	69	4	20
2644	V2701	93	2026-03-27 15:49:08.693368	PAID	3	[{"method": "EFECTIVO", "amount": 93, "displayAmount": 100, "type": null, "id": 1774626555049, "received": 100, "cambio": 7}]	71	17	20
1745	V6074	96	2026-03-24 22:38:51.931961	PAID	5	[{"method": "TARJETA", "amount": 96, "displayAmount": 96, "type": "DEBITO", "id": 1774618368236}]	71	17	20
2606	V1548	114	2026-03-27 14:31:30.633758	PAID	5	[{"method": "EFECTIVO", "amount": 114, "displayAmount": 120, "type": null, "id": 1774621908510, "received": 120, "cambio": 6}]	71	15	20
2607	V7501	71	2026-03-27 14:32:01.002162	PAID	3	[{"method": "EFECTIVO", "amount": 71, "displayAmount": 200, "type": null, "id": 1774621939049, "received": 200, "cambio": 129}]	71	15	20
2605	V7061	45	2026-03-27 14:30:34.3226	PAID	3	[{"method": "EFECTIVO", "amount": 45, "displayAmount": 45, "type": null, "id": 1774622029347, "received": 45, "cambio": 0}]	71	15	20
2613	V3449	44	2026-03-27 14:43:11.647953	PAID	5	[{"method": "EFECTIVO", "amount": 44, "displayAmount": 500, "type": null, "id": 1774622602565, "received": 500, "cambio": 456}]	71	15	20
2614	V9730	53	2026-03-27 14:44:43.479764	PAID	5	[{"method": "EFECTIVO", "amount": 53, "received": 53, "cambio": 0, "displayAmount": 53, "type": null, "id": 1774622693562}]	71	15	20
2158	V6801	36	2026-03-26 01:03:20.512246	PAID	5	[{"method": "EFECTIVO", "amount": 36, "displayAmount": 50, "type": null, "id": 1774622855002, "received": 50, "cambio": 14}]	71	15	20
2615	V9379	33	2026-03-27 14:47:51.707193	PAID	5	[{"method": "EFECTIVO", "amount": 33, "displayAmount": 50, "type": null, "id": 1774622903714, "received": 50, "cambio": 17}]	71	15	20
2622	V2209	26	2026-03-27 15:01:52.224147	PAID	5	[{"method": "EFECTIVO", "amount": 26, "displayAmount": 500, "type": null, "id": 1774623751167, "received": 500, "cambio": 474}]	71	15	20
2630	V8153	45	2026-03-27 15:13:46.998823	PAID	6	[{"method": "EFECTIVO", "amount": 45, "displayAmount": 45, "type": null, "id": 1774624639535, "received": 45, "cambio": 0}]	71	17	20
2631	V4313	25	2026-03-27 15:15:41.953986	PAID	3	[{"method": "EFECTIVO", "amount": 25, "displayAmount": 25, "type": null, "id": 1774624656092, "received": 25, "cambio": 0}]	71	15	20
2634	V2709	33	2026-03-27 15:23:36.307321	PAID	5	[{"method": "EFECTIVO", "amount": 33, "displayAmount": 33, "type": null, "id": 1774625103166, "received": 33, "cambio": 0}]	71	17	20
2640	V2884	93	2026-03-27 15:45:03.60462	PAID	3	[{"method": "EFECTIVO", "amount": 93, "displayAmount": 500, "type": null, "id": 1774626316687, "received": 500, "cambio": 407}]	71	17	20
2641	V2685	70	2026-03-27 15:45:37.412352	PAID	5	[{"method": "EFECTIVO", "amount": 70, "displayAmount": 200, "type": null, "id": 1774626348594, "received": 200, "cambio": 130}]	71	17	20
2643	V8617	44	2026-03-27 15:48:36.986894	PAID	4	[{"method": "EFECTIVO", "amount": 44, "displayAmount": 50, "type": null, "id": 1774626528175, "received": 50, "cambio": 6}]	71	15	20
2648	V6881	65	2026-03-27 16:00:47.584972	PAID	1	[{"method": "EFECTIVO", "amount": 65, "displayAmount": 200, "type": null, "id": 1774627266135, "received": 200, "cambio": 135}]	71	20	20
2649	V5635	63	2026-03-27 16:02:10.727561	PAID	3	[{"method": "EFECTIVO", "amount": 63, "displayAmount": 63, "type": null, "id": 1774627360873, "received": 63, "cambio": 0}]	71	17	20
1844	V9739	170	2026-03-25 01:19:52.70354	PAID	3	[{"method": "EFECTIVO", "amount": 170, "received": 200, "cambio": 30, "displayAmount": 200, "type": null, "id": 1774628170916}]	71	17	20
2653	V8353	56	2026-03-27 16:24:50.11729	PAID	3	[{"method": "EFECTIVO", "amount": 56, "displayAmount": 56, "type": null, "id": 1774632659732, "received": 56, "cambio": 0}]	71	17	20
2623	V6397	14	2026-03-27 15:02:55.277436	PAID	5	[{"method": "EFECTIVO", "amount": 14, "displayAmount": 14, "type": null, "id": 1774632702328, "received": 14, "cambio": 0}]	71	15	20
2655	V5753	73	2026-03-27 16:41:55.844095	PAID	5	[{"method": "EFECTIVO", "amount": 73, "displayAmount": 73, "type": null, "id": 1774632709601, "received": 73, "cambio": 0}]	71	15	20
2636	V9689	25	2026-03-27 15:26:10.574815	PAID	1	[{"method": "EFECTIVO", "amount": 25, "displayAmount": 25, "type": null, "id": 1774632753679, "received": 25, "cambio": 0}]	71	20	20
2660	V1711	60	2026-03-27 17:47:26.610394	PAID	5	[{"method": "EFECTIVO", "amount": 60, "displayAmount": 60, "type": null, "id": 1774634603744, "received": 60, "cambio": 0}]	71	15	20
1720	V9552	128	2026-03-24 21:12:19.539549	PAID	3	[{"method": "EFECTIVO", "amount": 128, "received": 128, "cambio": 0, "displayAmount": 128, "type": null, "id": 1774386812736}]	29	8	20
1723	V6371	205	2026-03-24 21:32:34.726114	PAID	5	[{"method": "EFECTIVO", "amount": 205, "received": 205, "cambio": 0, "displayAmount": 205, "type": null, "id": 1774388076471}]	29	9	20
1725	V1357	74	2026-03-24 21:40:26.284752	PAID	5	[{"method": "EFECTIVO", "amount": 74, "received": 500, "cambio": 426, "displayAmount": 500, "type": null, "id": 1774388442409}]	29	9	20
1728	V6491	120	2026-03-24 22:01:26.275265	PAID	4	[{"method": "EFECTIVO", "amount": 120, "received": 200, "cambio": 80, "displayAmount": 200, "type": null, "id": 1774389718181}]	29	8	20
1730	V3972	120	2026-03-24 22:04:03.324785	PAID	5	[{"method": "EFECTIVO", "amount": 120, "received": 500, "cambio": 380, "displayAmount": 500, "type": null, "id": 1774389894423}]	29	9	20
1733	V9460	80	2026-03-24 22:06:58.668601	PAID	4	[{"method": "EFECTIVO", "amount": 80, "received": 80, "cambio": 0, "displayAmount": 80, "type": null, "id": 1774390047542}]	29	8	20
1734	V2557	168	2026-03-24 22:12:57.593961	PAID	3	[{"method": "EFECTIVO", "amount": 168, "received": 500, "cambio": 332, "displayAmount": 500, "type": null, "id": 1774390389637}]	29	13	20
1735	V5254	36	2026-03-24 22:13:19.821011	PAID	4	[{"method": "EFECTIVO", "amount": 36, "received": 100, "cambio": 64, "displayAmount": 100, "type": null, "id": 1774390467248}]	29	8	20
1736	V6055	62	2026-03-24 22:15:07.182297	PAID	3	[{"method": "EFECTIVO", "amount": 62, "received": 62, "cambio": 0, "displayAmount": 62, "type": null, "id": 1774391447664}]	29	13	20
1746	V5388	120	2026-03-24 22:39:10.443281	PAID	3	[{"method": "EFECTIVO", "amount": 120, "displayAmount": 120, "type": null, "id": 1774391991525, "received": 120, "cambio": 0}]	29	8	20
1749	V7747	103	2026-03-24 22:47:19.691345	PAID	3	[{"method": "EFECTIVO", "amount": 103, "displayAmount": 105, "type": null, "id": 1774392448064, "received": 105, "cambio": 2}]	29	13	20
1764	V6493	23	2026-03-24 23:32:02.318401	PAID	4	[{"method": "EFECTIVO", "amount": 23, "received": 23, "cambio": 0, "displayAmount": 23, "type": null, "id": 1774395159222}]	29	24	20
1765	V1697	107	2026-03-24 23:42:43.405579	PAID	3	[{"method": "EFECTIVO", "amount": 107, "displayAmount": 150, "type": null, "id": 1774395822520, "received": 150, "cambio": 43}]	29	13	20
1756	V5242	23	2026-03-24 23:09:25.449297	PAID	3	[{"method": "EFECTIVO", "amount": 23, "received": 23, "cambio": 0, "displayAmount": 23, "type": null, "id": 1774395995843}]	29	13	20
1766	V5050	33	2026-03-24 23:46:41.586908	PAID	3	[{"method": "EFECTIVO", "amount": 33, "displayAmount": 50, "type": null, "id": 1774617350076, "received": 50, "cambio": 17}]	71	15	20
1770	V9314	54	2026-03-24 23:48:48.811087	PAID	4	[{"method": "EFECTIVO", "amount": 54, "received": 104, "cambio": 50, "displayAmount": 104, "type": null, "id": 1774396143383}]	29	8	20
1769	V9554	186	2026-03-24 23:48:46.752628	PAID	5	[{"method": "EFECTIVO", "amount": 186, "received": 200, "cambio": 14, "displayAmount": 200, "type": null, "id": 1774396172947}]	29	9	20
1772	V4157	79	2026-03-24 23:50:53.675354	PAID	3	[{"method": "EFECTIVO", "amount": 79, "received": 79, "cambio": 0, "displayAmount": 79, "type": null, "id": 1774396306730}]	29	13	20
1777	V4384	68	2026-03-24 23:57:50.416661	PAID	3	[{"method": "EFECTIVO", "amount": 68, "received": 100, "cambio": 32, "displayAmount": 100, "type": null, "id": 1774396710186}]	29	4	20
1780	V4129	293	2026-03-25 00:00:57.987318	PAID	5	[{"method": "EFECTIVO", "amount": 293, "received": 500, "cambio": 207, "displayAmount": 500, "type": null, "id": 1774396888595}]	29	9	20
1790	V8805	44	2026-03-25 00:17:37.589802	PAID	3	[{"method": "EFECTIVO", "amount": 44, "received": 50, "cambio": 6, "displayAmount": 50, "type": null, "id": 1774397873900}]	30	13	3
1781	V5481	274	2026-03-25 00:01:11.182143	PAID	6	[{"method": "EFECTIVO", "amount": 274, "received": 300, "cambio": 26, "displayAmount": 300, "type": null, "id": 1774396968210}]	29	13	20
1785	V1954	26	2026-03-25 00:06:46.295622	PAID	5	[{"method": "EFECTIVO", "amount": 26, "received": 100, "cambio": 74, "displayAmount": 100, "type": null, "id": 1774397246806}]	29	9	20
1750	V1686	34	2026-03-24 22:48:58.154939	PAID	3	[{"method": "EFECTIVO", "amount": 34, "received": 34, "cambio": 0, "displayAmount": 34, "type": null, "id": 1774397279987}]	29	13	20
1787	V8903	56	2026-03-25 00:09:30.807375	PAID	3	[{"method": "EFECTIVO", "amount": 56, "displayAmount": 100, "type": null, "id": 1774624262449, "received": 100, "cambio": 44}]	71	15	20
1792	V1133	73	2026-03-25 00:19:06.756038	PAID	3	[{"method": "EFECTIVO", "amount": 73, "received": 200, "cambio": 127, "displayAmount": 200, "type": null, "id": 1774397963389}]	30	13	3
1791	V5132	154	2026-03-25 00:18:59.939685	PAID	5	[{"method": "EFECTIVO", "amount": 154, "received": 200, "cambio": 46, "displayAmount": 200, "type": null, "id": 1774398000275}]	30	9	3
1793	V9809	20	2026-03-25 00:20:22.996055	PAID	4	[{"method": "EFECTIVO", "amount": 20, "received": 20, "cambio": 0, "displayAmount": 20, "type": null, "id": 1774495282993}]	35	18	3
1795	V1059	50	2026-03-25 00:22:30.472516	PAID	5	[{"method": "EFECTIVO", "amount": 50, "received": 50, "cambio": 0, "displayAmount": 50, "type": null, "id": 1774398240600}]	30	9	3
1797	V5375	106	2026-03-25 00:24:09.140915	PAID	4	[{"method": "EFECTIVO", "amount": 106, "received": 200, "cambio": 94, "displayAmount": 200, "type": null, "id": 1774398266158}]	30	8	3
1796	V8018	120	2026-03-25 00:23:53.227782	PAID	3	[{"method": "EFECTIVO", "amount": 120, "received": 500, "cambio": 380, "displayAmount": 500, "type": null, "id": 1774398296806}]	30	13	3
1798	V1387	86	2026-03-25 00:29:20.369235	PAID	3	[{"method": "EFECTIVO", "amount": 86, "displayAmount": 100, "type": null, "id": 1774398567844, "received": 100, "cambio": 14}]	30	13	3
1799	V9176	67	2026-03-25 00:30:39.547703	PAID	3	[{"method": "EFECTIVO", "amount": 67, "displayAmount": 100, "type": null, "id": 1774398646773, "received": 100, "cambio": 33}]	30	13	3
1800	V3579	69	2026-03-25 00:31:11.791534	PAID	4	[{"method": "EFECTIVO", "amount": 69, "displayAmount": 70, "type": null, "id": 1774398734761, "received": 70, "cambio": 1}]	30	9	3
1801	V2554	54	2026-03-25 00:33:46.386357	PAID	3	[{"method": "EFECTIVO", "amount": 54, "received": 200, "cambio": 146, "displayAmount": 200, "type": null, "id": 1774398843892}]	30	13	3
1802	V2300	32	2026-03-25 00:36:05.305914	PAID	3	[{"method": "EFECTIVO", "amount": 32, "displayAmount": 100, "type": null, "id": 1774398972632, "received": 100, "cambio": 68}]	30	13	3
1803	V2271	20	2026-03-25 00:37:59.461774	PAID	3	[{"method": "EFECTIVO", "amount": 20, "received": 50, "cambio": 30, "displayAmount": 50, "type": null, "id": 1774399091118}]	30	13	3
1808	V6044	158	2026-03-25 00:49:52.81744	PAID	3	[{"method": "EFECTIVO", "amount": 158, "received": 158, "cambio": 0, "displayAmount": 158, "type": null, "id": 1774399802254}]	30	13	3
1809	V9727	130	2026-03-25 00:51:40.075065	PAID	5	[{"method": "EFECTIVO", "amount": 130, "received": 140, "cambio": 10, "displayAmount": 140, "type": null, "id": 1774399936769}]	30	9	3
1817	V8114	124	2026-03-25 01:00:54.246632	PAID	3	[{"method": "EFECTIVO", "amount": 124, "received": 124, "cambio": 0, "displayAmount": 124, "type": null, "id": 1774400475538}]	30	13	3
1822	V4124	126	2026-03-25 01:04:29.524946	PAID	5	[{"method": "EFECTIVO", "amount": 126, "received": 500, "cambio": 374, "displayAmount": 500, "type": null, "id": 1774400710325}]	30	9	3
1821	V3856	57	2026-03-25 01:04:23.56139	PAID	4	[{"method": "EFECTIVO", "amount": 57, "received": 100, "cambio": 43, "displayAmount": 100, "type": null, "id": 1774400748030}]	30	8	3
1824	V5356	56	2026-03-25 01:06:48.144516	PAID	3	[{"method": "EFECTIVO", "amount": 56, "displayAmount": 60, "type": null, "id": 1774400823722, "received": 60, "cambio": 4}]	30	13	3
1827	V3662	50	2026-03-25 01:07:59.9398	PAID	4	[{"method": "EFECTIVO", "amount": 50, "displayAmount": 100, "type": null, "id": 1774400900880, "received": 100, "cambio": 50}]	30	9	3
1832	V8992	78	2026-03-25 01:10:19.800569	PAID	5	[{"method": "EFECTIVO", "amount": 78, "received": 100, "cambio": 22, "displayAmount": 100, "type": null, "id": 1774401076724}]	30	9	3
1835	V6895	90	2026-03-25 01:11:43.434947	PAID	4	[{"method": "EFECTIVO", "amount": 90, "received": 90, "cambio": 0, "displayAmount": 90, "type": null, "id": 1774401171526}]	30	9	3
1841	V9677	83	2026-03-25 01:17:55.759479	PAID	5	[{"method": "EFECTIVO", "amount": 83, "received": 83, "cambio": 0, "displayAmount": 83, "type": null, "id": 1774401492829}]	30	8	3
1856	V8625	53	2026-03-25 01:27:26.855816	PAID	5	[{"method": "EFECTIVO", "amount": 53, "received": 53, "cambio": 0, "displayAmount": 53, "type": null, "id": 1774402070653}]	30	8	3
1861	V5273	91	2026-03-25 01:32:38.109764	PAID	5	[{"method": "EFECTIVO", "amount": 91, "received": 100, "cambio": 9, "displayAmount": 100, "type": null, "id": 1774402416716}]	30	8	3
1870	V3433	41	2026-03-25 01:38:30.247767	PAID	3	[{"method": "EFECTIVO", "amount": 41, "received": 41, "cambio": 0, "displayAmount": 41, "type": null, "id": 1774402751019}]	30	13	3
2412	V3211	18	2026-03-26 23:49:23.761697	PAID	3	[{"method": "EFECTIVO", "amount": 18, "received": 18, "cambio": 0, "displayAmount": 18, "type": null, "id": 1774569999898}]	70	13	1
1877	V3555	141	2026-03-25 01:45:46.608195	PAID	3	[{"method": "EFECTIVO", "amount": 141, "received": 200, "cambio": 59, "displayAmount": 200, "type": null, "id": 1774403161169}]	30	13	3
1878	V3120	108	2026-03-25 01:46:14.472573	PAID	5	[{"method": "EFECTIVO", "amount": 108, "received": 208, "cambio": 100, "displayAmount": 208, "type": null, "id": 1774403206824}]	30	8	3
1885	V5611	116	2026-03-25 01:48:54.650408	PAID	3	[{"method": "EFECTIVO", "amount": 116, "received": 116, "cambio": 0, "displayAmount": 116, "type": null, "id": 1774403465950}]	30	13	3
1893	V5913	95	2026-03-25 01:56:25.571425	PAID	6	[{"method": "EFECTIVO", "amount": 95, "received": 100, "cambio": 5, "displayAmount": 100, "type": null, "id": 1774403855490}]	30	4	3
1880	V5894	43	2026-03-25 01:46:49.174617	PAID	3	[{"method": "EFECTIVO", "amount": 43, "received": 43, "cambio": 0, "displayAmount": 43, "type": null, "id": 1774404020558}]	30	13	3
1866	V6058	97	2026-03-25 01:34:58.937165	PAID	5	[{"method": "EFECTIVO", "amount": 97, "received": 97, "cambio": 0, "displayAmount": 97, "type": null, "id": 1774404069038}]	30	8	3
1859	V3908	15	2026-03-25 01:31:42.353582	PAID	4	[{"method": "EFECTIVO", "amount": 15, "received": 15, "cambio": 0, "displayAmount": 15, "type": null, "id": 1774404090292}]	30	9	3
2388	V3153	215	2026-03-26 22:46:47.047897	PAID	5	[{"method": "EFECTIVO", "amount": 215, "received": 500, "cambio": 285, "displayAmount": 500, "type": null, "id": 1774565249031}]	70	9	1
2393	V3411	252	2026-03-26 23:04:49.624692	PAID	5	[{"method": "EFECTIVO", "amount": 252, "received": 255, "cambio": 3, "displayAmount": 255, "type": null, "id": 1774566336054}]	70	9	1
1806	V3294	32	2026-03-25 00:43:41.443972	PAID	5	[{"method": "EFECTIVO", "amount": 32, "received": 32, "cambio": 0, "displayAmount": 32, "type": null, "id": 1774480054043}]	35	18	3
2395	V2748	92	2026-03-26 23:12:48.275917	PAID	3	[{"method": "EFECTIVO", "amount": 92, "received": 200, "cambio": 108, "displayAmount": 200, "type": null, "id": 1774566805392}]	70	13	1
2396	V3057	88	2026-03-26 23:17:19.50772	PAID	3	[{"method": "EFECTIVO", "amount": 88, "displayAmount": 200, "type": null, "id": 1774567045863, "received": 200, "cambio": 112}]	70	13	1
2404	V7177	39	2026-03-26 23:37:29.514331	PAID	5	[{"method": "EFECTIVO", "amount": 39, "received": 200, "cambio": 161, "displayAmount": 200, "type": null, "id": 1774568259147}]	70	24	1
2405	V6996	79	2026-03-26 23:38:15.945475	PAID	6	[{"method": "EFECTIVO", "amount": 79, "received": 79, "cambio": 0, "displayAmount": 79, "type": null, "id": 1774568376950}]	70	4	1
2414	V9344	70	2026-03-26 23:51:43.002388	PAID	3	[{"method": "EFECTIVO", "amount": 70, "received": 500, "cambio": 430, "displayAmount": 500, "type": null, "id": 1774569138344}]	70	13	1
2415	V7310	64	2026-03-26 23:52:21.431002	PAID	5	[{"method": "EFECTIVO", "amount": 64, "received": 200, "cambio": 136, "displayAmount": 200, "type": null, "id": 1774569181810}]	70	4	1
1873	V2628	65	2026-03-25 01:41:22.513713	PAID	5	[{"method": "EFECTIVO", "amount": 65, "received": 500, "cambio": 435, "displayAmount": 500, "type": null, "id": 1774569420084}]	70	24	1
2417	V7446	113	2026-03-27 00:02:18.303305	PAID	3	[{"method": "EFECTIVO", "amount": 113, "displayAmount": 200, "type": null, "id": 1774569749021, "received": 200, "cambio": 87}]	70	24	1
2423	V7787	148	2026-03-27 00:13:20.439233	PAID	5	[{"method": "EFECTIVO", "amount": 148, "received": 200, "cambio": 52, "displayAmount": 200, "type": null, "id": 1774570409308}]	70	24	1
2420	V3276	27	2026-03-27 00:08:09.66213	PAID	3	[{"method": "EFECTIVO", "amount": 27, "received": 27, "cambio": 0, "displayAmount": 27, "type": null, "id": 1774571200877}]	70	13	1
2429	V1759	45	2026-03-27 00:24:46.861876	PAID	3	[{"method": "EFECTIVO", "amount": 45, "received": 45, "cambio": 0, "displayAmount": 45, "type": null, "id": 1774571206473}]	70	13	1
1804	V9076	79	2026-03-25 00:40:32.702149	PAID	3	[{"method": "EFECTIVO", "amount": 79, "received": 79, "cambio": 0, "displayAmount": 79, "type": null, "id": 1774399246423}]	30	13	3
1805	V4186	168	2026-03-25 00:43:22.26356	PAID	3	[{"method": "EFECTIVO", "amount": 168, "received": 200, "cambio": 32, "displayAmount": 200, "type": null, "id": 1774399412056}]	30	13	3
1807	V6186	74	2026-03-25 00:49:06.085667	PAID	5	[{"method": "EFECTIVO", "amount": 74, "received": 500, "cambio": 426, "displayAmount": 500, "type": null, "id": 1774399766716}]	30	9	3
1810	V1110	61	2026-03-25 00:53:39.730696	PAID	5	[{"method": "EFECTIVO", "amount": 61, "received": 101, "cambio": 40, "displayAmount": 101, "type": null, "id": 1774400049378}]	30	9	3
1812	V3111	76	2026-03-25 00:55:54.154779	PAID	3	[{"method": "EFECTIVO", "amount": 76, "received": 100, "cambio": 24, "displayAmount": 100, "type": null, "id": 1774400168982}]	30	13	3
1813	V1003	69	2026-03-25 00:56:07.257386	PAID	4	[{"method": "EFECTIVO", "amount": 69, "received": 69, "cambio": 0, "displayAmount": 69, "type": null, "id": 1774400234569}]	30	8	3
1816	V5271	41	2026-03-25 00:59:30.790267	PAID	3	[{"method": "EFECTIVO", "amount": 41, "received": 41, "cambio": 0, "displayAmount": 41, "type": null, "id": 1774400395067}]	30	13	3
1818	V6444	82	2026-03-25 01:01:00.337186	PAID	4	[{"method": "EFECTIVO", "amount": 82, "received": 82, "cambio": 0, "displayAmount": 82, "type": null, "id": 1774400537250}]	30	8	3
1829	V4185	47	2026-03-25 01:08:56.059985	PAID	3	[{"method": "EFECTIVO", "amount": 47, "received": 47, "cambio": 0, "displayAmount": 47, "type": null, "id": 1774400950213}]	30	24	3
1830	V7613	29	2026-03-25 01:09:05.54672	PAID	6	[{"method": "EFECTIVO", "amount": 29, "received": 29, "cambio": 0, "displayAmount": 29, "type": null, "id": 1774400988092}]	30	4	3
1825	V4809	38	2026-03-25 01:07:30.319242	PAID	5	[{"method": "EFECTIVO", "amount": 38, "received": 38, "cambio": 0, "displayAmount": 38, "type": null, "id": 1774400998561}]	30	9	3
1833	V5856	71	2026-03-25 01:10:30.767687	PAID	3	[{"method": "EFECTIVO", "amount": 71, "received": 200, "cambio": 129, "displayAmount": 200, "type": null, "id": 1774401094191}]	30	24	3
1838	V6879	139	2026-03-25 01:13:36.726405	PAID	5	[{"method": "EFECTIVO", "amount": 139, "received": 200, "cambio": 61, "displayAmount": 200, "type": null, "id": 1774401234801}]	30	8	3
1839	V8006	72	2026-03-25 01:16:59.393419	PAID	3	[{"method": "EFECTIVO", "amount": 72, "received": 200, "cambio": 128, "displayAmount": 200, "type": null, "id": 1774401450114}]	30	13	3
1850	V7602	23	2026-03-25 01:23:02.790723	PAID	4	[{"method": "EFECTIVO", "amount": 23, "received": 23, "cambio": 0, "displayAmount": 23, "type": null, "id": 1774401850983}]	30	9	3
1851	V3235	91	2026-03-25 01:24:15.65118	PAID	3	[{"method": "EFECTIVO", "amount": 91, "received": 100, "cambio": 9, "displayAmount": 100, "type": null, "id": 1774401873428}]	30	13	3
1852	V4338	83	2026-03-25 01:24:32.448736	PAID	4	[{"method": "EFECTIVO", "amount": 83, "received": 200, "cambio": 117, "displayAmount": 200, "type": null, "id": 1774401904686}]	30	9	3
1855	V8207	87	2026-03-25 01:26:54.192102	PAID	6	[{"method": "EFECTIVO", "amount": 87, "received": 100, "cambio": 13, "displayAmount": 100, "type": null, "id": 1774402147281}]	30	4	3
1865	V8402	36	2026-03-25 01:34:01.593588	PAID	3	[{"method": "EFECTIVO", "amount": 36, "received": 36, "cambio": 0, "displayAmount": 36, "type": null, "id": 1774402599051}]	30	13	3
1868	V2703	116	2026-03-25 01:37:39.213183	PAID	3	[{"method": "EFECTIVO", "amount": 116, "received": 200, "cambio": 84, "displayAmount": 200, "type": null, "id": 1774402677370}]	30	13	3
1869	V8132	62	2026-03-25 01:38:19.768961	PAID	6	[{"method": "EFECTIVO", "amount": 62, "received": 62, "cambio": 0, "displayAmount": 62, "type": null, "id": 1774402770570}]	30	9	3
1871	V9216	63	2026-03-25 01:40:29.048954	PAID	6	[{"method": "EFECTIVO", "amount": 63, "received": 100, "cambio": 37, "displayAmount": 100, "type": null, "id": 1774402887340}]	30	9	3
1886	V6565	52	2026-03-25 01:49:44.548576	PAID	6	[{"method": "EFECTIVO", "amount": 52, "received": 100, "cambio": 48, "displayAmount": 100, "type": null, "id": 1774403541476}]	30	9	3
1887	V7296	49	2026-03-25 01:51:33.115059	PAID	5	[{"method": "EFECTIVO", "amount": 49, "received": 500, "cambio": 451, "displayAmount": 500, "type": null, "id": 1774403576279}]	30	8	3
1888	V2137	76	2026-03-25 01:53:20.84231	PAID	5	[{"method": "EFECTIVO", "amount": 76, "received": 76, "cambio": 0, "displayAmount": 76, "type": null, "id": 1774403667852}]	30	8	3
1890	V2335	64	2026-03-25 01:54:22.282931	PAID	6	[{"method": "EFECTIVO", "amount": 64, "received": 64, "cambio": 0, "displayAmount": 64, "type": null, "id": 1774403700360}]	30	4	3
1879	V7082	77	2026-03-25 01:46:44.668839	PAID	4	[{"method": "EFECTIVO", "amount": 77, "received": 77, "cambio": 0, "displayAmount": 77, "type": null, "id": 1774405044248}]	30	24	3
2389	V7427	58	2026-03-26 22:47:18.195805	PAID	3	[{"method": "EFECTIVO", "amount": 58, "received": 100, "cambio": 42, "displayAmount": 100, "type": null, "id": 1774565282698}]	70	13	1
2391	V8286	53	2026-03-26 22:49:43.627635	PAID	5	[{"method": "EFECTIVO", "amount": 53, "received": 200, "cambio": 147, "displayAmount": 200, "type": null, "id": 1774565396060}]	70	9	1
2397	V6011	125	2026-03-26 23:23:14.837089	PAID	3	[{"method": "EFECTIVO", "amount": 125, "displayAmount": 200, "type": null, "id": 1774567400419, "received": 200, "cambio": 75}]	70	13	1
2399	V6013	80	2026-03-26 23:27:41.834088	PAID	3	[{"method": "EFECTIVO", "amount": 80, "received": 200, "cambio": 120, "displayAmount": 200, "type": null, "id": 1774567689610}]	70	13	1
2401	V1740	47	2026-03-26 23:35:42.169011	PAID	3	[{"method": "EFECTIVO", "amount": 47, "displayAmount": 50, "type": null, "id": 1774568146266, "received": 50, "cambio": 3}]	70	13	1
2406	V2705	43	2026-03-26 23:38:58.882095	PAID	3	[{"method": "EFECTIVO", "amount": 43, "received": 43, "cambio": 0, "displayAmount": 43, "type": null, "id": 1774568475013}]	70	13	1
2402	V3029	65	2026-03-26 23:36:11.180175	PAID	5	[{"method": "EFECTIVO", "amount": 65, "received": 65, "cambio": 0, "displayAmount": 65, "type": null, "id": 1774568484966}]	70	24	1
2410	V8639	63	2026-03-26 23:47:25.422998	PAID	3	[{"method": "EFECTIVO", "amount": 63, "displayAmount": 100, "type": null, "id": 1774568851382, "received": 100, "cambio": 37}]	70	13	1
2409	V1243	29	2026-03-26 23:47:16.610218	PAID	5	[{"method": "EFECTIVO", "amount": 29, "displayAmount": 100, "type": null, "id": 1774568881055, "received": 100, "cambio": 71}]	70	4	1
1811	V6387	44	2026-03-25 00:55:46.010727	PAID	5	[{"method": "EFECTIVO", "amount": 44, "received": 100, "cambio": 56, "displayAmount": 100, "type": null, "id": 1774400198635}]	30	9	3
1814	V6760	72	2026-03-25 00:57:20.529474	PAID	5	[{"method": "EFECTIVO", "amount": 72, "received": 100, "cambio": 28, "displayAmount": 100, "type": null, "id": 1774400254167}]	30	9	3
1815	V6159	45	2026-03-25 00:58:36.407826	PAID	5	[{"method": "EFECTIVO", "amount": 45, "received": 100, "cambio": 55, "displayAmount": 100, "type": null, "id": 1774400332779}]	30	9	3
1819	V8251	65	2026-03-25 01:01:45.140405	PAID	5	[{"method": "EFECTIVO", "amount": 65, "received": 65, "cambio": 0, "displayAmount": 65, "type": null, "id": 1774400596343}]	30	9	3
1820	V7319	55	2026-03-25 01:02:53.049678	PAID	3	[{"method": "EFECTIVO", "amount": 55, "received": 55, "cambio": 0, "displayAmount": 55, "type": null, "id": 1774400612659}]	30	13	3
1823	V8432	59	2026-03-25 01:05:35.704543	PAID	3	[{"method": "EFECTIVO", "amount": 59, "received": 100, "cambio": 41, "displayAmount": 100, "type": null, "id": 1774400775906}]	30	13	3
1828	V1176	42	2026-03-25 01:08:00.441922	PAID	6	[{"method": "EFECTIVO", "amount": 42, "received": 50, "cambio": 8, "displayAmount": 50, "type": null, "id": 1774400918837}]	30	4	3
1831	V4325	66	2026-03-25 01:09:14.870499	PAID	4	[{"method": "EFECTIVO", "amount": 66, "received": 200, "cambio": 134, "displayAmount": 200, "type": null, "id": 1774401052282}]	30	9	3
1794	V6847	49	2026-03-25 00:21:28.035528	PAID	3	[{"method": "EFECTIVO", "amount": 49, "received": 49, "cambio": 0, "displayAmount": 49, "type": null, "id": 1774401551483}]	30	13	3
1842	V7716	44	2026-03-25 01:19:00.91271	PAID	3	[{"method": "EFECTIVO", "amount": 44, "received": 50, "cambio": 6, "displayAmount": 50, "type": null, "id": 1774401563086}]	30	13	3
1837	V2743	21	2026-03-25 01:12:34.454699	PAID	3	[{"method": "EFECTIVO", "amount": 21, "received": 21, "cambio": 0, "displayAmount": 21, "type": null, "id": 1774401595443}]	30	24	3
1845	V6094	21	2026-03-25 01:20:45.76572	PAID	3	[{"method": "EFECTIVO", "amount": 21, "received": 21, "cambio": 0, "displayAmount": 21, "type": null, "id": 1774401680245}]	30	13	3
1847	V3647	199	2026-03-25 01:21:31.707861	PAID	5	[{"method": "EFECTIVO", "amount": 199, "received": 199, "cambio": 0, "displayAmount": 199, "type": null, "id": 1774401749864}]	30	8	3
1848	V1209	95	2026-03-25 01:22:10.999711	PAID	4	[{"method": "EFECTIVO", "amount": 95, "received": 200, "cambio": 105, "displayAmount": 200, "type": null, "id": 1774401821294}]	30	9	3
1854	V3133	189	2026-03-25 01:25:00.29365	PAID	5	[{"method": "EFECTIVO", "amount": 189, "received": 200, "cambio": 11, "displayAmount": 200, "type": null, "id": 1774401927842}]	30	8	3
1858	V9041	116	2026-03-25 01:31:05.576176	PAID	5	[{"method": "EFECTIVO", "amount": 116, "received": 200, "cambio": 84, "displayAmount": 200, "type": null, "id": 1774402277710}]	30	8	3
1863	V5833	107	2026-03-25 01:33:17.858727	PAID	4	[{"method": "EFECTIVO", "amount": 107, "received": 200, "cambio": 93, "displayAmount": 200, "type": null, "id": 1774402448689}]	30	9	3
1862	V9376	49	2026-03-25 01:33:11.8678	PAID	3	[{"method": "EFECTIVO", "amount": 49, "received": 49, "cambio": 0, "displayAmount": 49, "type": null, "id": 1774402500090}]	30	13	3
1853	V7320	9	2026-03-25 01:24:43.914825	PAID	3	[{"method": "EFECTIVO", "amount": 9, "received": 9, "cambio": 0, "displayAmount": 9, "type": null, "id": 1774402590541}]	30	13	3
1834	V5605	108	2026-03-25 01:11:03.233353	PAID	1	[{"method": "EFECTIVO", "amount": 108, "received": 108, "cambio": 0, "displayAmount": 108, "type": null, "id": 1774402763889}]	30	13	3
1867	V5037	50	2026-03-25 01:37:17.662771	PAID	6	[{"method": "EFECTIVO", "amount": 50, "received": 50, "cambio": 0, "displayAmount": 50, "type": null, "id": 1774402784568}]	30	9	3
1872	V1270	99	2026-03-25 01:40:32.855245	PAID	3	[{"method": "EFECTIVO", "amount": 99, "received": 200, "cambio": 101, "displayAmount": 200, "type": null, "id": 1774402858310}]	30	13	3
1875	V5110	177	2026-03-25 01:44:14.156944	PAID	4	[{"method": "EFECTIVO", "amount": 177, "received": 500, "cambio": 323, "displayAmount": 500, "type": null, "id": 1774403080466}]	30	24	3
1892	V7493	81	2026-03-25 01:56:01.018151	PAID	3	[{"method": "EFECTIVO", "amount": 81, "received": 100, "cambio": 19, "displayAmount": 100, "type": null, "id": 1774403824910}]	30	13	3
1864	V9158	23	2026-03-25 01:33:40.144394	PAID	6	[{"method": "EFECTIVO", "amount": 23, "received": 23, "cambio": 0, "displayAmount": 23, "type": null, "id": 1774405050662}]	30	4	3
1882	V8314	109	2026-03-25 01:48:21.273314	PAID	1	[{"method": "EFECTIVO", "amount": 109, "received": 109, "cambio": 0, "displayAmount": 109, "type": null, "id": 1774406155587}]	30	4	3
2390	V5329	57	2026-03-26 22:49:04.228622	PAID	3	[{"method": "EFECTIVO", "amount": 57, "received": 100, "cambio": 43, "displayAmount": 100, "type": null, "id": 1774565360751}]	70	13	1
1826	V5748	34	2026-03-25 01:07:49.27091	PAID	3	[{"method": "EFECTIVO", "amount": 34, "received": 35, "cambio": 1, "displayAmount": 35, "type": null, "id": 1774479899470}]	35	8	3
2387	V9725	38	2026-03-26 22:43:29.989157	PAID	5	[{"method": "EFECTIVO", "amount": 38, "received": 38, "cambio": 0, "displayAmount": 38, "type": null, "id": 1774565474711}]	70	9	1
2392	V3585	56	2026-03-26 22:51:06.909639	PAID	3	[{"method": "EFECTIVO", "amount": 56, "received": 100, "cambio": 44, "displayAmount": 100, "type": null, "id": 1774565480939}]	70	13	1
2394	V5472	51	2026-03-26 23:08:30.887662	PAID	3	[{"method": "EFECTIVO", "amount": 51, "received": 100, "cambio": 49, "displayAmount": 100, "type": null, "id": 1774566552563}]	70	13	1
2398	V9595	108	2026-03-26 23:26:19.560302	PAID	5	[{"method": "EFECTIVO", "amount": 108, "received": 108, "cambio": 0, "displayAmount": 108, "type": null, "id": 1774567603323}]	70	4	1
2403	V8836	50	2026-03-26 23:36:58.104668	PAID	6	[{"method": "EFECTIVO", "amount": 50, "received": 50, "cambio": 0, "displayAmount": 50, "type": null, "id": 1774568234756}]	70	4	1
2407	V2427	74	2026-03-26 23:39:03.580007	PAID	5	[{"method": "EFECTIVO", "amount": 74, "received": 74, "cambio": 0, "displayAmount": 74, "type": null, "id": 1774568455877}]	70	24	1
2408	V7161	50	2026-03-26 23:39:21.471634	PAID	6	[{"method": "EFECTIVO", "amount": 50, "received": 50, "cambio": 0, "displayAmount": 50, "type": null, "id": 1774568513077}]	70	9	1
2411	V2114	42	2026-03-26 23:48:21.516187	PAID	5	[{"method": "EFECTIVO", "amount": 42, "received": 42, "cambio": 0, "displayAmount": 42, "type": null, "id": 1774569056245}]	70	4	1
2413	V5888	108	2026-03-26 23:49:55.527295	PAID	5	[{"method": "EFECTIVO", "amount": 108, "received": 108, "cambio": 0, "displayAmount": 108, "type": null, "id": 1774570071370}]	70	4	1
1836	V6301	43	2026-03-25 01:11:46.40497	PAID	3	[{"method": "EFECTIVO", "amount": 43, "received": 200, "cambio": 157, "displayAmount": 200, "type": null, "id": 1774401136550}]	30	24	3
1843	V8719	74	2026-03-25 01:19:40.694351	PAID	4	[{"method": "EFECTIVO", "amount": 74, "received": 100, "cambio": 26, "displayAmount": 100, "type": null, "id": 1774401617632}]	30	9	3
2416	V4448	74	2026-03-26 23:53:11.24488	PAID	3	[{"method": "TARJETA", "amount": 74, "displayAmount": 74, "type": "DEBITO", "id": 1774639609803}]	71	20	20
1840	V3741	40	2026-03-25 01:17:45.509188	PAID	3	[{"method": "EFECTIVO", "amount": 40, "received": 40, "cambio": 0, "displayAmount": 40, "type": null, "id": 1774401695243}]	30	13	3
1846	V5035	23	2026-03-25 01:21:24.266186	PAID	3	[{"method": "EFECTIVO", "amount": 23, "received": 50, "cambio": 27, "displayAmount": 50, "type": null, "id": 1774401773121}]	30	13	3
1849	V1190	31	2026-03-25 01:22:12.835372	PAID	3	[{"method": "EFECTIVO", "amount": 31, "received": 31, "cambio": 0, "displayAmount": 31, "type": null, "id": 1774401810360}]	30	13	3
1857	V4623	123	2026-03-25 01:30:08.531525	PAID	3	[{"method": "EFECTIVO", "amount": 123, "received": 200, "cambio": 77, "displayAmount": 200, "type": null, "id": 1774402233539}]	30	13	3
1860	V2284	54	2026-03-25 01:32:11.716824	PAID	6	[{"method": "EFECTIVO", "amount": 54, "displayAmount": 54, "type": null, "id": 1774449607731, "received": 54, "cambio": 0}]	31	16	20
1874	V9470	146	2026-03-25 01:43:22.295043	PAID	3	[{"method": "EFECTIVO", "amount": 146, "received": 200, "cambio": 54, "displayAmount": 200, "type": null, "id": 1774403015885}]	30	13	3
1876	V7618	73	2026-03-25 01:44:22.407001	PAID	5	[{"method": "EFECTIVO", "amount": 73, "received": 500, "cambio": 427, "displayAmount": 500, "type": null, "id": 1774403115885}]	30	8	3
1881	V2572	144	2026-03-25 01:47:25.755517	PAID	6	[{"method": "EFECTIVO", "amount": 144, "received": 200, "cambio": 56, "displayAmount": 200, "type": null, "id": 1774403302069}]	30	9	3
1883	V8532	41	2026-03-25 01:48:44.501556	PAID	5	[{"method": "EFECTIVO", "amount": 41, "received": 100, "cambio": 59, "displayAmount": 100, "type": null, "id": 1774403347817}]	30	8	3
1884	V8335	70	2026-03-25 01:48:53.308479	PAID	4	[{"method": "EFECTIVO", "amount": 70, "received": 100, "cambio": 30, "displayAmount": 100, "type": null, "id": 1774403413349}]	30	24	3
1891	V2655	118	2026-03-25 01:54:57.483518	PAID	4	[{"method": "EFECTIVO", "amount": 118, "received": 500, "cambio": 382, "displayAmount": 500, "type": null, "id": 1774403746097}]	30	24	3
1894	V4070	38	2026-03-25 01:57:23.182186	PAID	3	[{"method": "EFECTIVO", "amount": 38, "received": 50, "cambio": 12, "displayAmount": 50, "type": null, "id": 1774403876114}]	30	13	3
1889	V5456	140	2026-03-25 01:53:29.03579	PAID	3	[{"method": "EFECTIVO", "amount": 140, "received": 140, "cambio": 0, "displayAmount": 140, "type": null, "id": 1774404026211}]	30	13	3
1896	V7194	113	2026-03-25 02:00:15.209561	PAID	4	[{"method": "EFECTIVO", "amount": 113, "received": 200, "cambio": 87, "displayAmount": 200, "type": null, "id": 1774404038023}]	30	24	3
1895	V1685	2	2026-03-25 01:59:27.589735	PAID	5	[{"method": "EFECTIVO", "amount": 2, "received": 2, "cambio": 0, "displayAmount": 2, "type": null, "id": 1774404082536}]	30	8	3
1897	V9152	52	2026-03-25 02:01:48.515815	PAID	4	[{"method": "EFECTIVO", "amount": 52, "received": 100, "cambio": 48, "displayAmount": 100, "type": null, "id": 1774404123095}]	30	24	3
1898	V1415	53	2026-03-25 02:01:58.540357	PAID	3	[{"method": "EFECTIVO", "amount": 53, "received": 53, "cambio": 0, "displayAmount": 53, "type": null, "id": 1774404157926}]	30	13	3
1899	V3381	133	2026-03-25 02:02:55.226043	PAID	5	[{"method": "EFECTIVO", "amount": 133, "received": 150, "cambio": 17, "displayAmount": 150, "type": null, "id": 1774404193680}]	30	8	3
1900	V9547	62	2026-03-25 02:03:44.620252	PAID	3	[{"method": "EFECTIVO", "amount": 62, "received": 200, "cambio": 138, "displayAmount": 200, "type": null, "id": 1774404239959}]	30	13	3
1902	V1781	103	2026-03-25 02:05:14.617485	PAID	5	[{"method": "EFECTIVO", "amount": 103, "received": 200, "cambio": 97, "displayAmount": 200, "type": null, "id": 1774404335824}]	30	8	3
1901	V8764	102	2026-03-25 02:05:07.202052	PAID	4	[{"method": "EFECTIVO", "amount": 102, "received": 102, "cambio": 0, "displayAmount": 102, "type": null, "id": 1774404367787}]	30	24	3
1904	V3067	65	2026-03-25 02:07:49.970349	PAID	5	[{"method": "EFECTIVO", "amount": 65, "received": 100, "cambio": 35, "displayAmount": 100, "type": null, "id": 1774404482768}]	30	8	3
1903	V2573	157	2026-03-25 02:07:39.74249	PAID	3	[{"method": "EFECTIVO", "amount": 157, "received": 500, "cambio": 343, "displayAmount": 500, "type": null, "id": 1774404506562}]	30	13	3
1905	V3482	133	2026-03-25 02:08:10.960936	PAID	6	[{"method": "EFECTIVO", "amount": 133, "received": 133, "cambio": 0, "displayAmount": 133, "type": null, "id": 1774404553926}]	30	4	3
1906	V3896	628	2026-03-25 02:08:17.649723	PAID	4	[{"method": "EFECTIVO", "amount": 628, "received": 628, "cambio": 0, "displayAmount": 628, "type": null, "id": 1774404596633}]	30	9	3
1907	V4676	51	2026-03-25 02:08:58.653173	PAID	3	[{"method": "EFECTIVO", "amount": 51, "received": 200, "cambio": 149, "displayAmount": 200, "type": null, "id": 1774404636014}]	30	13	3
1909	V5310	59	2026-03-25 02:10:04.452621	PAID	5	[{"method": "EFECTIVO", "amount": 59, "received": 59, "cambio": 0, "displayAmount": 59, "type": null, "id": 1774404679440}]	30	8	3
1908	V3717	35	2026-03-25 02:09:49.634696	PAID	6	[{"method": "EFECTIVO", "amount": 35, "received": 50, "cambio": 15, "displayAmount": 50, "type": null, "id": 1774404693671}]	30	9	3
1911	V9967	58	2026-03-25 02:10:30.780066	PAID	1	[{"method": "EFECTIVO", "amount": 58, "received": 200, "cambio": 142, "displayAmount": 200, "type": null, "id": 1774404733738}]	30	4	3
1910	V7962	130	2026-03-25 02:10:08.825908	PAID	3	[{"method": "EFECTIVO", "amount": 130, "received": 130, "cambio": 0, "displayAmount": 130, "type": null, "id": 1774404766086}]	30	13	3
1913	V7596	102	2026-03-25 02:11:20.703551	PAID	4	[{"method": "EFECTIVO", "amount": 102, "received": 200, "cambio": 98, "displayAmount": 200, "type": null, "id": 1774404849569}]	30	24	3
1914	V1427	26	2026-03-25 02:11:34.673859	PAID	3	[{"method": "EFECTIVO", "amount": 26, "received": 50, "cambio": 24, "displayAmount": 50, "type": null, "id": 1774404890696}]	30	13	3
1912	V7516	17	2026-03-25 02:10:34.192616	PAID	5	[{"method": "EFECTIVO", "amount": 17, "received": 17, "cambio": 0, "displayAmount": 17, "type": null, "id": 1774404896332}]	30	8	3
1915	V9372	38	2026-03-25 02:11:55.453024	PAID	5	[{"method": "EFECTIVO", "amount": 38, "received": 38, "cambio": 0, "displayAmount": 38, "type": null, "id": 1774404904691}]	30	8	3
1919	V6670	62	2026-03-25 02:15:24.536269	PAID	4	[{"method": "EFECTIVO", "amount": 62, "received": 62, "cambio": 0, "displayAmount": 62, "type": null, "id": 1774405009821}]	30	4	3
1926	V4321	20	2026-03-25 02:22:01.029598	PAID	4	[{"method": "EFECTIVO", "amount": 20, "received": 20, "cambio": 0, "displayAmount": 20, "type": null, "id": 1774405371961}]	30	9	3
1927	V1295	68	2026-03-25 02:22:27.670601	PAID	3	[{"method": "EFECTIVO", "amount": 68, "received": 100, "cambio": 32, "displayAmount": 100, "type": null, "id": 1774405389644}]	30	13	3
1929	V5854	32	2026-03-25 02:24:41.328191	PAID	5	[{"method": "EFECTIVO", "amount": 32, "received": 32, "cambio": 0, "displayAmount": 32, "type": null, "id": 1774405492297}]	30	8	3
1930	V8422	129	2026-03-25 02:25:22.320206	PAID	3	[{"method": "EFECTIVO", "amount": 129, "received": 200, "cambio": 71, "displayAmount": 200, "type": null, "id": 1774405537293}]	30	13	3
1934	V8769	61	2026-03-25 02:30:54.407888	PAID	5	[{"method": "EFECTIVO", "amount": 61, "received": 100, "cambio": 39, "displayAmount": 100, "type": null, "id": 1774405874834}]	30	8	3
1938	V5007	11	2026-03-25 02:34:57.407204	PAID	5	[{"method": "EFECTIVO", "amount": 11, "received": 11, "cambio": 0, "displayAmount": 11, "type": null, "id": 1774406132441}]	30	8	3
1949	V9319	56	2026-03-25 02:45:19.503774	PAID	5	[{"method": "EFECTIVO", "amount": 56, "received": 100, "cambio": 44, "displayAmount": 100, "type": null, "id": 1774406730954}]	30	8	3
1951	V6752	40	2026-03-25 02:46:37.533756	PAID	5	[{"method": "EFECTIVO", "amount": 40, "received": 40, "cambio": 0, "displayAmount": 40, "type": null, "id": 1774406825699}]	30	8	3
1954	V2639	112	2026-03-25 02:50:19.488472	PAID	5	[{"method": "EFECTIVO", "amount": 112, "received": 200, "cambio": 88, "displayAmount": 200, "type": null, "id": 1774407028671}]	30	8	3
1956	V9217	54	2026-03-25 02:55:29.689324	PAID	5	[{"method": "EFECTIVO", "amount": 54, "received": 54, "cambio": 0, "displayAmount": 54, "type": null, "id": 1774407388263}]	30	8	3
1959	V9931	37	2026-03-25 02:58:17.777443	PAID	3	[{"method": "EFECTIVO", "amount": 37, "received": 37, "cambio": 0, "displayAmount": 37, "type": null, "id": 1774407513106}]	30	13	3
1960	V9822	44	2026-03-25 02:59:22.355974	PAID	5	[{"method": "EFECTIVO", "amount": 44, "received": 100, "cambio": 56, "displayAmount": 100, "type": null, "id": 1774407580374}]	30	8	3
1965	V6577	23	2026-03-25 03:08:59.385331	PAID	5	[{"method": "EFECTIVO", "amount": 23, "received": 23, "cambio": 0, "displayAmount": 23, "type": null, "id": 1774408153822}]	30	8	3
1967	V4687	48	2026-03-25 03:16:46.766877	PAID	5	[{"method": "EFECTIVO", "amount": 48, "received": 100, "cambio": 52, "displayAmount": 100, "type": null, "id": 1774408635445}]	30	8	3
1969	V2430	93	2026-03-25 03:29:48.03135	PAID	3	[{"method": "EFECTIVO", "amount": 93, "received": 100, "cambio": 7, "displayAmount": 100, "type": null, "id": 1774409402046}]	30	13	3
2418	V6574	54	2026-03-27 00:02:23.406277	PAID	5	[{"method": "EFECTIVO", "amount": 54, "displayAmount": 504, "type": null, "id": 1774569786402, "received": 504, "cambio": 450}]	70	4	1
2426	V7211	80	2026-03-27 00:20:01.553328	PAID	3	[{"method": "EFECTIVO", "amount": 80, "displayAmount": 100, "type": null, "id": 1774570808466, "received": 100, "cambio": 20}]	70	13	1
2428	V6396	108	2026-03-27 00:24:02.823894	PAID	5	[{"method": "EFECTIVO", "amount": 108, "received": 120, "cambio": 12, "displayAmount": 120, "type": null, "id": 1774571056931}]	70	24	1
2421	V7337	30	2026-03-27 00:11:10.441643	PAID	5	[{"method": "EFECTIVO", "amount": 30, "received": 30, "cambio": 0, "displayAmount": 30, "type": null, "id": 1774571213697}]	70	24	1
2427	V7217	35	2026-03-27 00:20:35.241032	PAID	5	[{"method": "EFECTIVO", "amount": 35, "received": 35, "cambio": 0, "displayAmount": 35, "type": null, "id": 1774571222036}]	70	24	1
2432	V6626	32	2026-03-27 00:28:14.494408	PAID	5	[{"method": "EFECTIVO", "amount": 32, "received": 50, "cambio": 18, "displayAmount": 50, "type": null, "id": 1774571311039}]	70	4	1
2434	V7404	57	2026-03-27 00:30:29.235323	PAID	3	[{"method": "EFECTIVO", "amount": 57, "received": 57, "cambio": 0, "displayAmount": 57, "type": null, "id": 1774571439123}]	70	13	1
2431	V1511	44	2026-03-27 00:27:36.619523	PAID	3	[{"method": "EFECTIVO", "amount": 44, "received": 44, "cambio": 0, "displayAmount": 44, "type": null, "id": 1774571958777}]	70	13	1
2435	V9895	32	2026-03-27 00:31:26.513418	PAID	3	[{"method": "EFECTIVO", "amount": 32, "received": 32, "cambio": 0, "displayAmount": 32, "type": null, "id": 1774572302436}]	70	13	1
2439	V6243	102	2026-03-27 00:46:07.466183	PAID	5	[{"method": "EFECTIVO", "amount": 102, "received": 102, "cambio": 0, "displayAmount": 102, "type": null, "id": 1774572409717}]	70	24	1
2440	V2744	20	2026-03-27 00:46:26.989103	PAID	3	[{"method": "EFECTIVO", "amount": 20, "received": 100, "cambio": 80, "displayAmount": 100, "type": null, "id": 1774572429355}]	70	13	1
2448	V1007	71	2026-03-27 00:51:54.694403	PAID	3	[{"method": "EFECTIVO", "amount": 71, "received": 500, "cambio": 429, "displayAmount": 500, "type": null, "id": 1774572727202}]	70	13	1
2442	V2024	59	2026-03-27 00:49:18.608448	PAID	5	[{"method": "EFECTIVO", "amount": 59, "received": 59, "cambio": 0, "displayAmount": 59, "type": null, "id": 1774572853989}]	70	24	1
2452	V1783	104	2026-03-27 00:55:55.228595	PAID	3	[{"method": "EFECTIVO", "amount": 104, "received": 104, "cambio": 0, "displayAmount": 104, "type": null, "id": 1774572978064}]	70	13	1
2455	V5521	147	2026-03-27 00:58:27.487668	PAID	5	[{"method": "EFECTIVO", "amount": 147, "received": 147, "cambio": 0, "displayAmount": 147, "type": null, "id": 1774573174445}]	70	24	1
2464	V4505	79	2026-03-27 01:04:02.445501	PAID	6	[{"method": "EFECTIVO", "amount": 79, "received": 500, "cambio": 421, "displayAmount": 500, "type": null, "id": 1774573452539}]	70	8	1
2462	V4854	60	2026-03-27 01:03:58.589954	PAID	5	[{"method": "EFECTIVO", "amount": 60, "received": 100, "cambio": 40, "displayAmount": 100, "type": null, "id": 1774573484039}]	70	24	1
2467	V3610	85	2026-03-27 01:09:06.824067	PAID	3	[{"method": "EFECTIVO", "amount": 85, "received": 200, "cambio": 115, "displayAmount": 200, "type": null, "id": 1774573761924}]	70	13	1
2445	V3061	18	2026-03-27 00:50:14.047046	PAID	5	[{"method": "EFECTIVO", "amount": 18, "received": 18, "cambio": 0, "displayAmount": 18, "type": null, "id": 1774573818480}]	70	24	1
2466	V3595	70	2026-03-27 01:05:36.131917	PAID	6	[{"method": "EFECTIVO", "amount": 70, "received": 70, "cambio": 0, "displayAmount": 70, "type": null, "id": 1774574687942}]	70	13	1
1916	V5243	100	2026-03-25 02:13:58.774067	PAID	4	[{"method": "EFECTIVO", "amount": 100, "received": 100, "cambio": 0, "displayAmount": 100, "type": null, "id": 1774404921864}]	30	4	3
1920	V7816	47	2026-03-25 02:16:04.819217	PAID	3	[{"method": "EFECTIVO", "amount": 47, "received": 100, "cambio": 53, "displayAmount": 100, "type": null, "id": 1774405018556}]	30	13	3
1921	V3853	112	2026-03-25 02:17:38.187655	PAID	5	[{"method": "EFECTIVO", "amount": 112, "received": 112, "cambio": 0, "displayAmount": 112, "type": null, "id": 1774405144682}]	30	24	3
1923	V6570	110	2026-03-25 02:18:59.635204	PAID	3	[{"method": "EFECTIVO", "amount": 110, "received": 112, "cambio": 2, "displayAmount": 112, "type": null, "id": 1774405159983}]	30	13	3
1925	V7629	37	2026-03-25 02:21:00.349464	PAID	4	[{"method": "EFECTIVO", "amount": 37, "received": 37, "cambio": 0, "displayAmount": 37, "type": null, "id": 1774405350821}]	30	9	3
1931	V7545	36	2026-03-25 02:25:29.865251	PAID	4	[{"method": "EFECTIVO", "amount": 36, "received": 200, "cambio": 164, "displayAmount": 200, "type": null, "id": 1774405562706}]	30	4	3
1937	V1536	45	2026-03-25 02:33:56.177836	PAID	5	[{"method": "EFECTIVO", "amount": 45, "received": 50, "cambio": 5, "displayAmount": 50, "type": null, "id": 1774406051681}]	30	8	3
1932	V5001	30	2026-03-25 02:27:02.408387	PAID	3	[{"method": "EFECTIVO", "amount": 30, "received": 30, "cambio": 0, "displayAmount": 30, "type": null, "id": 1774406124197}]	30	13	3
1950	V4734	120	2026-03-25 02:46:16.576184	PAID	3	[{"method": "EFECTIVO", "amount": 120, "received": 500, "cambio": 380, "displayAmount": 500, "type": null, "id": 1774406790299}]	30	13	3
1958	V8607	52	2026-03-25 02:57:39.880623	PAID	5	[{"method": "EFECTIVO", "amount": 52, "received": 200, "cambio": 148, "displayAmount": 200, "type": null, "id": 1774407470346}]	30	8	3
1963	V4373	86	2026-03-25 03:05:17.088256	PAID	5	[{"method": "EFECTIVO", "amount": 86, "received": 200, "cambio": 114, "displayAmount": 200, "type": null, "id": 1774407928070}]	30	8	3
1964	V3301	70	2026-03-25 03:07:35.090981	PAID	5	[{"method": "EFECTIVO", "amount": 70, "received": 100, "cambio": 30, "displayAmount": 100, "type": null, "id": 1774408072181}]	30	8	3
2419	V6083	21	2026-03-27 00:06:47.496301	PAID	3	[{"method": "EFECTIVO", "amount": 21, "received": 21, "cambio": 0, "displayAmount": 21, "type": null, "id": 1774570063250}]	70	13	1
1917	V4141	34	2026-03-25 02:15:06.935849	PAID	3	[{"method": "EFECTIVO", "amount": 34, "displayAmount": 34, "type": null, "id": 1774446727754, "received": 34, "cambio": 0}]	31	16	20
1968	V4972	16	2026-03-25 03:28:52.171618	PAID	3	[{"method": "EFECTIVO", "amount": 16, "displayAmount": 16, "type": null, "id": 1774447185344, "received": 16, "cambio": 0}]	31	13	20
2425	V2258	81	2026-03-27 00:15:18.062266	PAID	5	[{"method": "EFECTIVO", "amount": 81, "received": 100, "cambio": 19, "displayAmount": 100, "type": null, "id": 1774570533748}]	70	24	1
2430	V6039	67	2026-03-27 00:26:07.56911	PAID	5	[{"method": "EFECTIVO", "amount": 67, "received": 100, "cambio": 33, "displayAmount": 100, "type": null, "id": 1774571177569}]	70	24	1
2433	V7582	85	2026-03-27 00:29:55.12443	PAID	5	[{"method": "EFECTIVO", "amount": 85, "received": 200, "cambio": 115, "displayAmount": 200, "type": null, "id": 1774571408759}]	70	24	1
2437	V9673	242	2026-03-27 00:36:38.378441	PAID	4	[{"method": "EFECTIVO", "amount": 242, "received": 242, "cambio": 0, "displayAmount": 242, "type": null, "id": 1774571840281}]	70	4	1
2438	V7794	110	2026-03-27 00:44:54.242507	PAID	3	[{"method": "EFECTIVO", "amount": 110, "received": 110, "cambio": 0, "displayAmount": 110, "type": null, "id": 1774572310284}]	70	13	1
2441	V1576	56	2026-03-27 00:47:23.211196	PAID	5	[{"method": "EFECTIVO", "amount": 56, "received": 56, "cambio": 0, "displayAmount": 56, "type": null, "id": 1774572495238}]	70	24	1
2449	V8399	80	2026-03-27 00:52:24.864923	PAID	5	[{"method": "EFECTIVO", "amount": 80, "received": 100, "cambio": 20, "displayAmount": 100, "type": null, "id": 1774572768588}]	70	24	1
2454	V9283	101	2026-03-27 00:57:34.036187	PAID	3	[{"method": "EFECTIVO", "amount": 101, "received": 101, "cambio": 0, "displayAmount": 101, "type": null, "id": 1774578530422}]	70	13	1
2459	V3109	75	2026-03-27 01:01:48.418394	PAID	6	[{"method": "EFECTIVO", "amount": 75, "received": 100, "cambio": 25, "displayAmount": 100, "type": null, "id": 1774573323117}]	70	8	1
2460	V6586	36	2026-03-27 01:02:36.97492	PAID	6	[{"method": "EFECTIVO", "amount": 36, "received": 500, "cambio": 464, "displayAmount": 500, "type": null, "id": 1774573374217}]	70	8	1
2461	V6374	62	2026-03-27 01:02:44.665637	PAID	5	[{"method": "EFECTIVO", "amount": 62, "received": 100, "cambio": 38, "displayAmount": 100, "type": null, "id": 1774573408573}]	70	24	1
2463	V4709	130	2026-03-27 01:03:58.825028	PAID	3	[{"method": "EFECTIVO", "amount": 130, "received": 130, "cambio": 0, "displayAmount": 130, "type": null, "id": 1774573808380}]	70	13	1
2469	V4229	46	2026-03-27 01:11:53.250128	PAID	5	[{"method": "EFECTIVO", "amount": 46, "received": 50, "cambio": 4, "displayAmount": 50, "type": null, "id": 1774573944674}]	70	4	1
2473	V6310	83	2026-03-27 01:16:04.232508	PAID	3	[{"method": "EFECTIVO", "amount": 83, "received": 200, "cambio": 117, "displayAmount": 200, "type": null, "id": 1774574193881}]	70	13	1
2474	V2290	63	2026-03-27 01:16:38.635556	PAID	6	[{"method": "EFECTIVO", "amount": 63, "received": 63, "cambio": 0, "displayAmount": 63, "type": null, "id": 1774574222934}]	70	24	1
2422	V7293	45	2026-03-27 00:11:40.272954	PAID	3	[{"method": "EFECTIVO", "amount": 45, "received": 200, "cambio": 155, "displayAmount": 200, "type": null, "id": 1774574240444}]	70	4	1
2483	V9162	40	2026-03-27 01:27:48.479911	PAID	3	[{"method": "EFECTIVO", "amount": 40, "received": 40, "cambio": 0, "displayAmount": 40, "type": null, "id": 1774575013895}]	70	13	1
2481	V8066	97	2026-03-27 01:26:08.500468	PAID	3	[{"method": "EFECTIVO", "amount": 97, "received": 97, "cambio": 0, "displayAmount": 97, "type": null, "id": 1774575120885}]	70	13	1
2480	V4698	32	2026-03-27 01:25:53.685995	PAID	5	[{"method": "EFECTIVO", "amount": 32, "received": 100, "cambio": 68, "displayAmount": 100, "type": null, "id": 1774575278440}]	70	4	1
2494	V1880	79	2026-03-27 01:34:58.584759	PAID	6	[{"method": "EFECTIVO", "amount": 79, "received": 90, "cambio": 11, "displayAmount": 90, "type": null, "id": 1774575405503}]	70	24	1
2475	V2393	44	2026-03-27 01:17:46.137118	PAID	6	[{"method": "EFECTIVO", "amount": 44, "received": 44, "cambio": 0, "displayAmount": 44, "type": null, "id": 1774575656191}]	70	24	1
2482	V2139	92	2026-03-27 01:27:21.871943	PAID	5	[{"method": "EFECTIVO", "amount": 92, "received": 92, "cambio": 0, "displayAmount": 92, "type": null, "id": 1774577120995}]	70	4	1
1918	V4311	88	2026-03-25 02:15:15.29605	PAID	5	[{"method": "EFECTIVO", "amount": 88, "received": 100, "cambio": 12, "displayAmount": 100, "type": null, "id": 1774404961717}]	30	24	3
1922	V8841	148	2026-03-25 02:18:01.471217	PAID	6	[{"method": "EFECTIVO", "amount": 148, "received": 148, "cambio": 0, "displayAmount": 148, "type": null, "id": 1774405190394}]	30	9	3
1933	V6605	153	2026-03-25 02:27:05.560201	PAID	5	[{"method": "EFECTIVO", "amount": 153, "received": 153, "cambio": 0, "displayAmount": 153, "type": null, "id": 1774405701580}]	30	8	3
1936	V6928	44	2026-03-25 02:32:50.861447	PAID	3	[{"method": "EFECTIVO", "amount": 44, "received": 50, "cambio": 6, "displayAmount": 50, "type": null, "id": 1774405991963}]	30	13	3
1939	V9139	51	2026-03-25 02:36:53.569141	PAID	5	[{"method": "EFECTIVO", "amount": 51, "received": 100, "cambio": 49, "displayAmount": 100, "type": null, "id": 1774406224113}]	30	8	3
1940	V5064	38	2026-03-25 02:37:14.207385	PAID	4	[{"method": "EFECTIVO", "amount": 38, "received": 50, "cambio": 12, "displayAmount": 50, "type": null, "id": 1774406258231}]	30	9	3
1941	V3841	40	2026-03-25 02:37:46.786591	PAID	5	[{"method": "EFECTIVO", "amount": 40, "received": 40, "cambio": 0, "displayAmount": 40, "type": null, "id": 1774406279938}]	30	8	3
1942	V7537	77	2026-03-25 02:39:41.191338	PAID	5	[{"method": "EFECTIVO", "amount": 77, "received": 200, "cambio": 123, "displayAmount": 200, "type": null, "id": 1774406389412}]	30	8	3
1945	V4015	29	2026-03-25 02:40:30.753651	PAID	5	[{"method": "EFECTIVO", "amount": 29, "received": 50, "cambio": 21, "displayAmount": 50, "type": null, "id": 1774406487645}]	30	8	3
1947	V4598	44	2026-03-25 02:44:03.161153	PAID	5	[{"method": "EFECTIVO", "amount": 44, "received": 500, "cambio": 456, "displayAmount": 500, "type": null, "id": 1774406660351}]	30	8	3
1948	V6795	111	2026-03-25 02:44:20.760834	PAID	3	[{"method": "EFECTIVO", "amount": 111, "received": 211, "cambio": 100, "displayAmount": 211, "type": null, "id": 1774406691748}]	30	13	3
1953	V2652	24	2026-03-25 02:49:44.616806	PAID	3	[{"method": "EFECTIVO", "amount": 24, "received": 25, "cambio": 1, "displayAmount": 25, "type": null, "id": 1774407001832}]	30	13	3
1961	V3683	11	2026-03-25 03:03:21.016092	PAID	4	[{"method": "EFECTIVO", "amount": 11, "received": 11, "cambio": 0, "displayAmount": 11, "type": null, "id": 1774407838930}]	30	9	3
1966	V5367	102	2026-03-25 03:09:09.724082	PAID	3	[{"method": "EFECTIVO", "amount": 102, "received": 102, "cambio": 0, "displayAmount": 102, "type": null, "id": 1774408167379}]	30	13	3
1970	V6067	125	2026-03-25 03:31:01.050931	PAID	3	[{"method": "EFECTIVO", "amount": 125, "received": 150, "cambio": 25, "displayAmount": 150, "type": null, "id": 1774409484313}]	30	13	3
2444	V1195	40	2026-03-27 00:50:10.98675	PAID	3	[{"method": "EFECTIVO", "amount": 40, "received": 40, "cambio": 0, "displayAmount": 40, "type": null, "id": 1774572639149}]	70	13	1
2446	V2307	62	2026-03-27 00:50:39.113516	PAID	1	[{"method": "EFECTIVO", "amount": 62, "received": 100, "cambio": 38, "displayAmount": 100, "type": null, "id": 1774572662925}]	70	8	1
2447	V1099	90	2026-03-27 00:51:12.730212	PAID	5	[{"method": "EFECTIVO", "amount": 90, "received": 200, "cambio": 110, "displayAmount": 200, "type": null, "id": 1774572699852}]	70	24	1
2443	V2718	122	2026-03-27 00:49:26.314639	PAID	6	[{"method": "EFECTIVO", "amount": 122, "received": 122, "cambio": 0, "displayAmount": 122, "type": null, "id": 1774572805092}]	70	9	1
2450	V7423	87	2026-03-27 00:53:52.167245	PAID	3	[{"method": "EFECTIVO", "amount": 87, "received": 500, "cambio": 413, "displayAmount": 500, "type": null, "id": 1774572898340}]	70	13	1
2453	V9716	193	2026-03-27 00:55:56.539346	PAID	1	[{"method": "EFECTIVO", "amount": 193, "received": 200, "cambio": 7, "displayAmount": 200, "type": null, "id": 1774573059011}]	70	8	1
2457	V7563	124	2026-03-27 00:59:41.319027	PAID	3	[{"method": "EFECTIVO", "amount": 124, "received": 130, "cambio": 6, "displayAmount": 130, "type": null, "id": 1774573201494}]	70	13	1
2456	V2587	91	2026-03-27 00:59:06.081975	PAID	1	[{"method": "EFECTIVO", "amount": 91, "received": 500, "cambio": 409, "displayAmount": 500, "type": null, "id": 1774573222665}]	70	8	1
2465	V5984	74	2026-03-27 01:04:59.744302	PAID	5	[{"method": "EFECTIVO", "amount": 74, "received": 200, "cambio": 126, "displayAmount": 200, "type": null, "id": 1774578567686}]	70	4	1
1413	V6959	34	2026-03-23 23:42:40.911136	PAID	3	[{"method": "EFECTIVO", "amount": 34, "received": 34, "cambio": 0, "displayAmount": 34, "type": null, "id": 1774573715040}]	70	24	1
2436	V1046	75	2026-03-27 00:32:13.228895	PAID	6	[{"method": "EFECTIVO", "amount": 75, "received": 75, "cambio": 0, "displayAmount": 75, "type": null, "id": 1774573844333}]	70	9	1
2451	V7176	51	2026-03-27 00:54:09.60083	PAID	6	[{"method": "EFECTIVO", "amount": 51, "received": 51, "cambio": 0, "displayAmount": 51, "type": null, "id": 1774574072735}]	70	9	1
2476	V6249	39	2026-03-27 01:17:56.490092	PAID	5	[{"method": "EFECTIVO", "amount": 39, "received": 100, "cambio": 61, "displayAmount": 100, "type": null, "id": 1774574311900}]	70	4	1
2477	V2729	38	2026-03-27 01:20:43.630639	PAID	5	[{"method": "EFECTIVO", "amount": 38, "received": 40, "cambio": 2, "displayAmount": 40, "type": null, "id": 1774574562110}]	70	4	1
1067	V5342	62	2026-03-22 18:07:35.836338	PAID	5	[{"method": "EFECTIVO", "amount": 62, "received": 100, "cambio": 38, "displayAmount": 100, "type": null, "id": 1774574731803}]	70	13	1
2489	V7181	118	2026-03-27 01:32:42.220302	PAID	1	[{"method": "EFECTIVO", "amount": 118, "received": 118, "cambio": 0, "displayAmount": 118, "type": null, "id": 1774575262616}]	70	9	1
2491	V5350	51	2026-03-27 01:33:18.351429	PAID	5	[{"method": "EFECTIVO", "amount": 51, "received": 51, "cambio": 0, "displayAmount": 51, "type": null, "id": 1774575308375}]	70	4	1
2496	V2073	121	2026-03-27 01:37:23.933122	PAID	5	[{"method": "EFECTIVO", "amount": 121, "received": 121, "cambio": 0, "displayAmount": 121, "type": null, "id": 1774575461390}]	70	4	1
2495	V9770	35	2026-03-27 01:36:39.219517	PAID	3	[{"method": "EFECTIVO", "amount": 35, "received": 35, "cambio": 0, "displayAmount": 35, "type": null, "id": 1774575502181}]	70	13	1
2487	V3285	44	2026-03-27 01:31:11.529598	PAID	1	[{"method": "EFECTIVO", "amount": 44, "received": 44, "cambio": 0, "displayAmount": 44, "type": null, "id": 1774575511983}]	70	9	1
2493	V4262	32	2026-03-27 01:34:38.069767	PAID	3	[{"method": "EFECTIVO", "amount": 32, "received": 50, "cambio": 18, "displayAmount": 50, "type": null, "id": 1774575627375}]	70	13	1
2612	V7349	62	2026-03-27 14:40:33.568269	PAID	3	[{"method": "EFECTIVO", "amount": 62, "displayAmount": 200, "type": null, "id": 1774622446874, "received": 200, "cambio": 138}]	71	15	20
1924	V7132	94	2026-03-25 02:20:55.031199	PAID	3	[{"method": "EFECTIVO", "amount": 94, "received": 100, "cambio": 6, "displayAmount": 100, "type": null, "id": 1774405316504}]	30	13	3
1928	V1214	55	2026-03-25 02:23:54.044899	PAID	5	[{"method": "EFECTIVO", "amount": 55, "received": 55, "cambio": 0, "displayAmount": 55, "type": null, "id": 1774405445969}]	30	24	3
1935	V2399	32	2026-03-25 02:32:24.873261	PAID	5	[{"method": "EFECTIVO", "amount": 32, "received": 200, "cambio": 168, "displayAmount": 200, "type": null, "id": 1774405958981}]	30	8	3
1944	V3920	73	2026-03-25 02:39:52.126864	PAID	3	[{"method": "EFECTIVO", "amount": 73, "received": 200, "cambio": 127, "displayAmount": 200, "type": null, "id": 1774406428818}]	30	13	3
1943	V3005	112	2026-03-25 02:39:46.509093	PAID	4	[{"method": "EFECTIVO", "amount": 112, "received": 512, "cambio": 400, "displayAmount": 512, "type": null, "id": 1774406460772}]	30	9	3
1946	V9447	41	2026-03-25 02:43:15.486811	PAID	5	[{"method": "EFECTIVO", "amount": 41, "received": 41, "cambio": 0, "displayAmount": 41, "type": null, "id": 1774406625467}]	30	8	3
1952	V2896	36	2026-03-25 02:49:12.484545	PAID	3	[{"method": "EFECTIVO", "amount": 36, "received": 100, "cambio": 64, "displayAmount": 100, "type": null, "id": 1774406970663}]	30	13	3
1955	V2883	92	2026-03-25 02:54:18.351447	PAID	3	[{"method": "EFECTIVO", "amount": 92, "received": 100, "cambio": 8, "displayAmount": 100, "type": null, "id": 1774407281805}]	30	13	3
1957	V3307	104	2026-03-25 02:56:32.814515	PAID	3	[{"method": "EFECTIVO", "amount": 104, "received": 104, "cambio": 0, "displayAmount": 104, "type": null, "id": 1774407417678}]	30	13	3
1962	V4632	84	2026-03-25 03:03:43.896393	PAID	3	[{"method": "EFECTIVO", "amount": 84, "received": 84, "cambio": 0, "displayAmount": 84, "type": null, "id": 1774569993441}]	70	13	1
2458	V1638	11	2026-03-27 01:00:13.369286	PAID	3	[{"method": "EFECTIVO", "amount": 11, "received": 11, "cambio": 0, "displayAmount": 11, "type": null, "id": 1774573800864}]	70	13	1
1981	V6143	126	2026-03-25 13:23:22.792293	PAID	3	[{"method": "EFECTIVO", "amount": 126, "displayAmount": 126, "type": null, "id": 1774618766427, "received": 126, "cambio": 0}]	71	20	20
2001	V1454	86	2026-03-25 13:52:26.404221	PAID	3	[{"method": "EFECTIVO", "amount": 86, "displayAmount": 200, "type": null, "id": 1774446768862, "received": 200, "cambio": 114}]	31	14	20
2002	V4219	45	2026-03-25 13:53:15.819961	PAID	3	[{"method": "EFECTIVO", "amount": 45, "displayAmount": 45, "type": null, "id": 1774446821666, "received": 45, "cambio": 0}]	31	14	20
1971	V9137	23	2026-03-25 13:10:46.403378	PAID	3	[{"method": "EFECTIVO", "amount": 23, "displayAmount": 23, "type": null, "id": 1774446890651, "received": 23, "cambio": 0}]	31	16	20
1972	V6204	25	2026-03-25 13:11:12.186487	PAID	3	[{"method": "EFECTIVO", "amount": 25, "displayAmount": 25, "type": null, "id": 1774446902528, "received": 25, "cambio": 0}]	31	16	20
2005	V4176	17	2026-03-25 13:58:09.659395	PAID	5	[{"method": "EFECTIVO", "amount": 17, "displayAmount": 17, "type": null, "id": 1774447174539, "received": 17, "cambio": 0}]	31	16	20
1974	V1525	32	2026-03-25 13:15:07.97284	PAID	3	[{"method": "EFECTIVO", "amount": 32, "displayAmount": 32, "type": null, "id": 1774447276990, "received": 32, "cambio": 0}]	31	16	20
1975	V7478	18	2026-03-25 13:15:55.09497	PAID	3	[{"method": "EFECTIVO", "amount": 18, "displayAmount": 18, "type": null, "id": 1774447284478, "received": 18, "cambio": 0}]	31	16	20
1978	V4488	75	2026-03-25 13:18:59.319571	PAID	3	[{"method": "EFECTIVO", "amount": 75, "displayAmount": 75, "type": null, "id": 1774447301393, "received": 75, "cambio": 0}]	31	16	20
1979	V2982	30	2026-03-25 13:19:55.850828	PAID	3	[{"method": "EFECTIVO", "amount": 30, "displayAmount": 30, "type": null, "id": 1774447308200, "received": 30, "cambio": 0}]	31	16	20
1984	V4537	67	2026-03-25 13:25:13.283741	PAID	3	[{"method": "EFECTIVO", "amount": 67, "received": 67, "cambio": 0, "displayAmount": 67, "type": null, "id": 1774447334360}]	31	14	20
1996	V1900	45	2026-03-25 13:44:52.42393	PAID	3	[{"method": "EFECTIVO", "amount": 45, "displayAmount": 45, "type": null, "id": 1774447344103, "received": 45, "cambio": 0}]	31	16	20
2007	V2443	38	2026-03-25 14:02:30.581567	PAID	3	[{"method": "EFECTIVO", "amount": 38, "displayAmount": 38, "type": null, "id": 1774447420913, "received": 38, "cambio": 0}]	31	16	20
2008	V9558	70	2026-03-25 14:03:30.71281	PAID	4	[{"method": "EFECTIVO", "amount": 70, "displayAmount": 500, "type": null, "id": 1774447435928, "received": 500, "cambio": 430}]	31	14	20
2009	V3557	46	2026-03-25 14:04:55.880478	PAID	4	[{"method": "EFECTIVO", "amount": 46, "displayAmount": 50, "type": null, "id": 1774447514911, "received": 50, "cambio": 4}]	31	14	20
2010	V1312	73	2026-03-25 14:05:47.630854	PAID	3	[{"method": "EFECTIVO", "amount": 73, "displayAmount": 100, "type": null, "id": 1774447578103, "received": 100, "cambio": 27}]	31	16	20
1973	V2283	51	2026-03-25 13:14:59.065392	PAID	5	[{"method": "EFECTIVO", "amount": 51, "displayAmount": 51, "type": null, "id": 1774448174717, "received": 51, "cambio": 0}]	31	14	20
1982	V6478	28	2026-03-25 13:24:45.211192	PAID	5	[{"method": "EFECTIVO", "amount": 28, "displayAmount": 28, "type": null, "id": 1774448804646, "received": 28, "cambio": 0}]	31	16	20
1985	V6765	32	2026-03-25 13:25:45.592689	PAID	5	[{"method": "EFECTIVO", "amount": 32, "displayAmount": 32, "type": null, "id": 1774449155947, "received": 32, "cambio": 0}]	31	16	20
1988	V5642	46	2026-03-25 13:29:39.906472	PAID	5	[{"method": "EFECTIVO", "amount": 46, "displayAmount": 46, "type": null, "id": 1774449178102, "received": 46, "cambio": 0}]	31	16	20
1994	V7584	38	2026-03-25 13:36:04.664589	PAID	5	[{"method": "EFECTIVO", "amount": 38, "received": 38, "cambio": 0, "displayAmount": 38, "type": null, "id": 1774449288932}]	31	16	20
1989	V2998	93	2026-03-25 13:29:52.347225	PAID	4	[{"method": "EFECTIVO", "amount": 93, "displayAmount": 93, "type": null, "id": 1774449394921, "received": 93, "cambio": 0}]	31	14	20
1991	V3135	44	2026-03-25 13:32:59.678375	PAID	4	[{"method": "EFECTIVO", "amount": 44, "displayAmount": 44, "type": null, "id": 1774449407682, "received": 44, "cambio": 0}]	31	14	20
2003	V3726	55	2026-03-25 13:57:19.342963	PAID	4	[{"method": "EFECTIVO", "amount": 55, "displayAmount": 55, "type": null, "id": 1774449425357, "received": 55, "cambio": 0}]	31	14	20
2006	V4928	51	2026-03-25 13:59:13.744614	PAID	4	[{"method": "EFECTIVO", "amount": 51, "displayAmount": 51, "type": null, "id": 1774449521831, "received": 51, "cambio": 0}]	31	14	20
2011	V2126	27	2026-03-25 14:06:57.991551	PAID	3	[{"method": "EFECTIVO", "amount": 27, "displayAmount": 30, "type": null, "id": 1774447646489, "received": 30, "cambio": 3}]	31	16	20
2012	V2657	51	2026-03-25 14:12:13.654212	PAID	3	[{"method": "EFECTIVO", "amount": 51, "displayAmount": 100, "type": null, "id": 1774447949241, "received": 100, "cambio": 49}]	31	16	20
2013	V7225	43	2026-03-25 14:14:35.102028	PAID	3	[{"method": "EFECTIVO", "amount": 43, "displayAmount": 50, "type": null, "id": 1774448099926, "received": 50, "cambio": 7}]	31	16	20
2019	V9167	109	2026-03-25 14:24:09.603135	PAID	1	[{"method": "EFECTIVO", "amount": 109, "received": 500, "cambio": 391, "displayAmount": 500, "type": null, "id": 1774448705663}]	31	20	20
1980	V7002	27	2026-03-25 13:20:03.297911	PAID	5	[{"method": "EFECTIVO", "amount": 27, "displayAmount": 27, "type": null, "id": 1774449128853, "received": 27, "cambio": 0}]	31	14	20
1986	V3330	37	2026-03-25 13:27:39.104814	PAID	5	[{"method": "EFECTIVO", "amount": 37, "received": 37, "cambio": 0, "displayAmount": 37, "type": null, "id": 1774449169644}]	31	16	20
2027	V6639	86	2026-03-25 14:33:01.937102	PAID	1	[{"method": "EFECTIVO", "amount": 86, "displayAmount": 100, "type": null, "id": 1774449195795, "received": 100, "cambio": 14}]	31	20	20
2028	V8029	47	2026-03-25 14:33:16.088673	PAID	3	[{"method": "EFECTIVO", "amount": 47, "displayAmount": 100, "type": null, "id": 1774449222363, "received": 100, "cambio": 53}]	31	14	20
1983	V9451	17	2026-03-25 13:25:04.327544	PAID	5	[{"method": "EFECTIVO", "amount": 17, "displayAmount": 17, "type": null, "id": 1774449268793, "received": 17, "cambio": 0}]	31	16	20
1990	V8940	29	2026-03-25 13:32:04.953742	PAID	4	[{"method": "EFECTIVO", "amount": 29, "displayAmount": 29, "type": null, "id": 1774449401843, "received": 29, "cambio": 0}]	31	14	20
1995	V5199	62	2026-03-25 13:43:52.522326	PAID	5	[{"method": "EFECTIVO", "amount": 62, "displayAmount": 62, "type": null, "id": 1774449420046, "received": 62, "cambio": 0}]	31	16	20
2004	V8179	54	2026-03-25 13:58:09.606613	PAID	4	[{"method": "EFECTIVO", "amount": 54, "displayAmount": 54, "type": null, "id": 1774449432473, "received": 54, "cambio": 0}]	31	14	20
2029	V7197	48	2026-03-25 14:38:14.079162	PAID	3	[{"method": "EFECTIVO", "amount": 48, "displayAmount": 50, "type": null, "id": 1774449504413, "received": 50, "cambio": 2}]	31	20	20
2030	V3290	27	2026-03-25 14:39:25.774592	PAID	3	[{"method": "EFECTIVO", "amount": 27, "displayAmount": 100, "type": null, "id": 1774449579904, "received": 100, "cambio": 73}]	31	20	20
2025	V7812	45	2026-03-25 14:31:54.717588	PAID	1	[{"method": "EFECTIVO", "amount": 45, "displayAmount": 45, "type": null, "id": 1774449615824, "received": 45, "cambio": 0}]	31	20	20
1992	V3645	72	2026-03-25 13:34:01.852557	PAID	5	[{"method": "EFECTIVO", "amount": 72, "displayAmount": 72, "type": null, "id": 1774449628102, "received": 72, "cambio": 0}]	31	16	20
2035	V6265	42	2026-03-25 14:45:48.716004	PAID	3	[{"method": "EFECTIVO", "amount": 42, "displayAmount": 45, "type": null, "id": 1774449976676, "received": 45, "cambio": 3}]	31	16	20
2033	V8196	29	2026-03-25 14:42:56.437791	PAID	3	[{"method": "EFECTIVO", "amount": 29, "displayAmount": 29, "type": null, "id": 1774450114621, "received": 29, "cambio": 0}]	31	14	20
2040	V1523	88	2026-03-25 14:54:35.428255	PAID	3	[{"method": "EFECTIVO", "amount": 88, "displayAmount": 100, "type": null, "id": 1774450525465, "received": 100, "cambio": 12}]	31	16	20
2041	V5579	45	2026-03-25 14:55:22.650594	PAID	4	[{"method": "EFECTIVO", "amount": 45, "displayAmount": 100, "type": null, "id": 1774450543802, "received": 100, "cambio": 55}]	31	15	20
2050	V1315	15	2026-03-25 15:07:31.028012	PAID	3	[{"method": "EFECTIVO", "amount": 15, "displayAmount": 15, "type": null, "id": 1774452031045, "received": 15, "cambio": 0}]	31	16	20
2061	V9481	46	2026-03-25 15:28:15.894394	PAID	2	[{"method": "EFECTIVO", "amount": 46, "displayAmount": 46, "type": null, "id": 1774452495920, "received": 46, "cambio": 0}]	31	20	\N
127	V4925	12	2026-03-19 13:50:34.175599	PAID	4	[{"method": "EFECTIVO", "amount": 12, "received": 12, "cambio": 0, "displayAmount": 12, "type": null, "id": 1774573830986}]	70	8	1
2468	V1777	106	2026-03-27 01:11:01.187077	PAID	3	[{"method": "EFECTIVO", "amount": 106, "received": 110, "cambio": 4, "displayAmount": 110, "type": null, "id": 1774573905376}]	70	13	1
2470	V5432	80	2026-03-27 01:12:47.128063	PAID	3	[{"method": "EFECTIVO", "amount": 80, "received": 100, "cambio": 20, "displayAmount": 100, "type": null, "id": 1774574029684}]	70	13	1
2471	V6780	32	2026-03-27 01:13:04.439882	PAID	5	[{"method": "EFECTIVO", "amount": 32, "received": 100, "cambio": 68, "displayAmount": 100, "type": null, "id": 1774574052972}]	70	4	1
2472	V8672	113	2026-03-27 01:15:13.51127	PAID	6	[{"method": "EFECTIVO", "amount": 113, "received": 200, "cambio": 87, "displayAmount": 200, "type": null, "id": 1774574130000}]	70	24	1
2021	V2101	155	2026-03-25 14:26:41.782324	PAID	3	[{"method": "EFECTIVO", "amount": 155, "received": 200, "cambio": 45, "displayAmount": 200, "type": null, "id": 1774574158945}]	70	4	1
2478	V6550	51	2026-03-27 01:21:10.838519	PAID	3	[{"method": "EFECTIVO", "amount": 51, "received": 200, "cambio": 149, "displayAmount": 200, "type": null, "id": 1774574506343}]	70	13	1
1160	V8979	72	2026-03-22 23:37:49.104957	PAID	5	[{"method": "EFECTIVO", "amount": 72, "received": 100, "cambio": 28, "displayAmount": 100, "type": null, "id": 1774574698153}]	70	4	1
2484	V6727	22	2026-03-27 01:29:06.928006	PAID	3	[{"method": "EFECTIVO", "amount": 22, "received": 22, "cambio": 0, "displayAmount": 22, "type": null, "id": 1774575130997}]	70	13	1
2486	V9776	62	2026-03-27 01:30:23.32157	PAID	3	[{"method": "EFECTIVO", "amount": 62, "received": 200, "cambio": 138, "displayAmount": 200, "type": null, "id": 1774576835500}]	70	9	1
2488	V3867	116	2026-03-27 01:32:21.497472	PAID	5	[{"method": "EFECTIVO", "amount": 116, "received": 116, "cambio": 0, "displayAmount": 116, "type": null, "id": 1774575158796}]	70	4	1
2492	V7771	122	2026-03-27 01:33:33.65035	PAID	3	[{"method": "EFECTIVO", "amount": 122, "received": 500, "cambio": 378, "displayAmount": 500, "type": null, "id": 1774575325621}]	70	13	1
1999	V3031	93	2026-03-25 13:47:05.255158	PAID	3	[{"method": "EFECTIVO", "amount": 93, "received": 100, "cambio": 7, "displayAmount": 100, "type": null, "id": 1774575436216}]	70	9	1
2485	V8777	36	2026-03-27 01:29:13.301098	PAID	1	[{"method": "EFECTIVO", "amount": 36, "received": 36, "cambio": 0, "displayAmount": 36, "type": null, "id": 1774575521083}]	70	9	1
2497	V3382	101	2026-03-27 01:38:31.141083	PAID	5	[{"method": "EFECTIVO", "amount": 101, "received": 105, "cambio": 4, "displayAmount": 105, "type": null, "id": 1774575529885}]	70	4	1
1977	V1985	57	2026-03-25 13:17:47.253344	PAID	3	[{"method": "EFECTIVO", "amount": 57, "displayAmount": 57, "type": null, "id": 1774448128454, "received": 57, "cambio": 0}]	31	16	20
1987	V8616	52	2026-03-25 13:28:25.7283	PAID	5	[{"method": "EFECTIVO", "amount": 52, "displayAmount": 52, "type": null, "id": 1774448215979, "received": 52, "cambio": 0}]	31	16	20
2014	V8302	52	2026-03-25 14:16:05.825366	PAID	3	[{"method": "EFECTIVO", "amount": 52, "displayAmount": 52, "type": null, "id": 1774448245688, "received": 52, "cambio": 0}]	31	16	20
2015	V3107	32	2026-03-25 14:17:54.139527	PAID	3	[{"method": "EFECTIVO", "amount": 32, "displayAmount": 32, "type": null, "id": 1774448303679, "received": 32, "cambio": 0}]	31	16	20
2016	V1320	89	2026-03-25 14:20:13.620729	PAID	3	[{"method": "EFECTIVO", "amount": 89, "displayAmount": 100, "type": null, "id": 1774448425200, "received": 100, "cambio": 11}]	31	16	20
2017	V1907	45	2026-03-25 14:20:42.632652	PAID	1	[{"method": "EFECTIVO", "amount": 45, "displayAmount": 100, "type": null, "id": 1774448455997, "received": 100, "cambio": 55}]	31	20	20
1189	V3343	48	2026-03-23 00:40:14.12547	PAID	3	[{"method": "EFECTIVO", "amount": 48, "displayAmount": 48, "type": null, "id": 1774448747071, "received": 48, "cambio": 0}]	31	16	20
2020	V2179	36	2026-03-25 14:25:39.278833	PAID	3	[{"method": "EFECTIVO", "amount": 36, "displayAmount": 36, "type": null, "id": 1774448783074, "received": 36, "cambio": 0}]	31	16	20
2022	V3471	93	2026-03-25 14:28:01.533415	PAID	1	[{"method": "EFECTIVO", "amount": 93, "displayAmount": 100, "type": null, "id": 1774448894602, "received": 100, "cambio": 7}]	31	20	20
2023	V9971	39	2026-03-25 14:30:21.613099	PAID	3	[{"method": "EFECTIVO", "amount": 39, "displayAmount": 100, "type": null, "id": 1774449035378, "received": 100, "cambio": 61}]	31	14	20
1976	V4480	97	2026-03-25 13:17:05.38578	PAID	5	[{"method": "EFECTIVO", "amount": 97, "displayAmount": 97, "type": null, "id": 1774449115959, "received": 97, "cambio": 0}]	31	14	20
2024	V6202	48	2026-03-25 14:31:19.456611	PAID	3	[{"method": "EFECTIVO", "amount": 48, "displayAmount": 48, "type": null, "id": 1774449297574, "received": 48, "cambio": 0}]	31	14	20
1998	V3462	84	2026-03-25 13:46:28.639144	PAID	4	[{"method": "EFECTIVO", "amount": 84, "displayAmount": 84, "type": null, "id": 1774449622130, "received": 84, "cambio": 0}]	31	14	20
2034	V7080	36	2026-03-25 14:43:30.080637	PAID	2	[{"method": "EFECTIVO", "amount": 36, "displayAmount": 200, "type": null, "id": 1774449809418, "received": 200, "cambio": 164}]	31	20	\N
2036	V9345	26	2026-03-25 14:46:04.873299	PAID	5	[{"method": "EFECTIVO", "amount": 26, "displayAmount": 100, "type": null, "id": 1774450002409, "received": 100, "cambio": 74}]	31	15	20
2038	V1361	68	2026-03-25 14:48:56.06422	PAID	3	[{"method": "EFECTIVO", "amount": 68, "displayAmount": 200, "type": null, "id": 1774450145303, "received": 200, "cambio": 132}]	31	16	20
2039	V5951	108	2026-03-25 14:53:58.74699	PAID	3	[{"method": "EFECTIVO", "amount": 108, "displayAmount": 120, "type": null, "id": 1774450450333, "received": 120, "cambio": 12}]	31	16	20
2048	V7772	91	2026-03-25 15:07:00.340682	PAID	3	[{"method": "EFECTIVO", "amount": 91, "displayAmount": 91, "type": null, "id": 1774467256602, "received": 91, "cambio": 0}]	31	16	20
2044	V5017	53	2026-03-25 15:00:05.647832	PAID	3	[{"method": "EFECTIVO", "amount": 53, "displayAmount": 200, "type": null, "id": 1774450814957, "received": 200, "cambio": 147}]	31	16	20
2045	V5625	38	2026-03-25 15:00:47.534621	PAID	3	[{"method": "EFECTIVO", "amount": 38, "displayAmount": 500, "type": null, "id": 1774450857532, "received": 500, "cambio": 462}]	31	16	20
2046	V7233	38	2026-03-25 15:02:37.61327	PAID	3	[{"method": "EFECTIVO", "amount": 38, "displayAmount": 38, "type": null, "id": 1774450970796, "received": 38, "cambio": 0}]	31	16	20
2047	V1541	84	2026-03-25 15:04:01.145168	PAID	3	[{"method": "EFECTIVO", "amount": 84, "displayAmount": 200, "type": null, "id": 1774451051282, "received": 200, "cambio": 116}]	31	16	20
2052	V4479	56	2026-03-25 15:11:03.415082	PAID	3	[{"method": "EFECTIVO", "amount": 56, "displayAmount": 106, "type": null, "id": 1774451488562, "received": 106, "cambio": 50}]	31	16	20
2053	V1293	24	2026-03-25 15:12:00.296018	PAID	3	[{"method": "EFECTIVO", "amount": 24, "displayAmount": 50, "type": null, "id": 1774451531022, "received": 50, "cambio": 26}]	31	16	20
2051	V9843	41	2026-03-25 15:08:47.678711	PAID	5	[{"method": "EFECTIVO", "amount": 41, "received": 41, "cambio": 0, "displayAmount": 41, "type": null, "id": 1774451691564}]	31	16	20
2059	V7048	55	2026-03-25 15:26:03.29512	PAID	5	[{"method": "EFECTIVO", "amount": 55, "displayAmount": 60, "type": null, "id": 1774452383331, "received": 60, "cambio": 5}]	31	16	20
2063	V8582	34	2026-03-25 15:31:39.368139	PAID	2	[{"method": "EFECTIVO", "amount": 34, "displayAmount": 50, "type": null, "id": 1774452700212, "received": 50, "cambio": 16}]	31	20	\N
2064	V4760	58	2026-03-25 15:32:10.88316	PAID	5	[{"method": "EFECTIVO", "amount": 58, "received": 59, "cambio": 1, "displayAmount": 59, "type": null, "id": 1774452743848}]	31	16	20
2055	V9008	15	2026-03-25 15:19:09.006725	PAID	5	[{"method": "EFECTIVO", "amount": 15, "displayAmount": 15, "type": null, "id": 1774464496887, "received": 15, "cambio": 0}]	31	16	20
2057	V6935	12	2026-03-25 15:22:27.10459	PAID	5	[{"method": "EFECTIVO", "amount": 12, "received": 12, "cambio": 0, "displayAmount": 12, "type": null, "id": 1774464514371}]	31	16	20
2060	V7295	20	2026-03-25 15:26:31.848957	PAID	5	[{"method": "EFECTIVO", "amount": 20, "displayAmount": 20, "type": null, "id": 1774465212454, "received": 20, "cambio": 0}]	31	16	20
2066	V2992	20	2026-03-25 15:33:45.553594	PAID	5	[{"method": "EFECTIVO", "amount": 20, "displayAmount": 20, "type": null, "id": 1774467266856, "received": 20, "cambio": 0}]	31	16	20
2043	V8039	65	2026-03-25 14:58:03.255323	PAID	3	[{"method": "EFECTIVO", "amount": 65, "displayAmount": 65, "type": null, "id": 1774467362540, "received": 65, "cambio": 0}]	31	16	20
2000	V1791	42	2026-03-25 13:52:23.178597	PAID	5	[{"method": "EFECTIVO", "amount": 42, "received": 42, "cambio": 0, "displayAmount": 42, "type": null, "id": 1774542375529}]	69	15	20
2498	V3140	84	2026-03-27 01:38:54.494419	PAID	3	[{"method": "EFECTIVO", "amount": 84, "received": 200, "cambio": 116, "displayAmount": 200, "type": null, "id": 1774575551497}]	70	13	1
2499	V7107	120	2026-03-27 01:39:09.784727	PAID	6	[{"method": "EFECTIVO", "amount": 120, "received": 150, "cambio": 30, "displayAmount": 150, "type": null, "id": 1774575591905}]	70	8	1
2018	V7484	40	2026-03-25 14:21:21.943333	PAID	3	[{"method": "EFECTIVO", "amount": 40, "displayAmount": 40, "type": null, "id": 1774448509957, "received": 40, "cambio": 0}]	31	16	20
2026	V2640	35	2026-03-25 14:32:02.313162	PAID	3	[{"method": "EFECTIVO", "amount": 35, "displayAmount": 35, "type": null, "id": 1774449141834, "received": 35, "cambio": 0}]	31	14	20
1993	V8372	14	2026-03-25 13:35:18.730041	PAID	5	[{"method": "EFECTIVO", "amount": 14, "displayAmount": 14, "type": null, "id": 1774449281674, "received": 14, "cambio": 0}]	31	16	20
1997	V8296	41	2026-03-25 13:45:14.601263	PAID	4	[{"method": "EFECTIVO", "amount": 41, "displayAmount": 41, "type": null, "id": 1774449413821, "received": 41, "cambio": 0}]	31	14	20
2032	V1702	29	2026-03-25 14:41:44.904094	PAID	3	[{"method": "EFECTIVO", "amount": 29, "displayAmount": 50, "type": null, "id": 1774449717844, "received": 50, "cambio": 21}]	31	14	20
2037	V4965	32	2026-03-25 14:47:08.3117	PAID	6	[{"method": "EFECTIVO", "amount": 32, "received": 32, "cambio": 0, "displayAmount": 32, "type": null, "id": 1774577114184}]	70	4	1
2042	V9512	58	2026-03-25 14:57:25.144546	PAID	5	[{"method": "EFECTIVO", "amount": 58, "received": 58, "cambio": 0, "displayAmount": 58, "type": null, "id": 1774450662035}]	31	15	20
2054	V9540	9	2026-03-25 15:12:14.287955	PAID	3	[{"method": "EFECTIVO", "amount": 9, "displayAmount": 9, "type": null, "id": 1774451664823, "received": 9, "cambio": 0}]	31	16	20
2056	V9624	112	2026-03-25 15:20:49.715609	PAID	4	[{"method": "EFECTIVO", "amount": 112, "displayAmount": 200, "type": null, "id": 1774452061102, "received": 200, "cambio": 88}]	31	20	20
2058	V2418	51	2026-03-25 15:25:40.212285	PAID	2	[{"method": "EFECTIVO", "amount": 51, "displayAmount": 52, "type": null, "id": 1774452341297, "received": 52, "cambio": 1}]	31	20	\N
2076	V9944	69	2026-03-25 16:26:42.731	PAID	5	[{"method": "EFECTIVO", "amount": 69, "displayAmount": 69, "type": null, "id": 1774467296677, "received": 69, "cambio": 0}]	31	14	20
2070	V7420	25	2026-03-25 15:45:01.637333	PAID	3	[{"method": "EFECTIVO", "amount": 25, "displayAmount": 25, "type": null, "id": 1774453524747, "received": 25, "cambio": 0}]	31	16	20
2068	V1605	34	2026-03-25 15:44:03.583568	PAID	3	[{"method": "EFECTIVO", "amount": 34, "displayAmount": 34, "type": null, "id": 1774453535342, "received": 34, "cambio": 0}]	31	16	20
456	V3495	29	2026-03-21 02:52:00.77432	PAID	6	[{"method": "EFECTIVO", "amount": 29, "displayAmount": 100, "type": null, "id": 1774453731454, "received": 100, "cambio": 71}]	31	20	20
2078	V7347	58	2026-03-25 16:54:26.735376	PAID	4	[{"method": "EFECTIVO", "amount": 58, "received": 100, "cambio": 42, "displayAmount": 100, "type": null, "id": 1774493796916}]	35	8	3
2049	V1366	15	2026-03-25 15:07:18.265856	PAID	3	[{"method": "EFECTIVO", "amount": 15, "displayAmount": 15, "type": null, "id": 1774464449389, "received": 15, "cambio": 0}]	31	16	20
2069	V5560	17	2026-03-25 15:44:21.860718	PAID	3	[{"method": "EFECTIVO", "amount": 17, "displayAmount": 17, "type": null, "id": 1774464459551, "received": 17, "cambio": 0}]	31	16	20
2071	V2981	23	2026-03-25 15:45:30.345636	PAID	3	[{"method": "EFECTIVO", "amount": 23, "displayAmount": 23, "type": null, "id": 1774464470567, "received": 23, "cambio": 0}]	31	16	20
2072	V4284	6	2026-03-25 15:45:55.559323	PAID	3	[{"method": "EFECTIVO", "amount": 6, "received": 6, "cambio": 0, "displayAmount": 6, "type": null, "id": 1774464488412}]	31	16	20
2062	V3093	26	2026-03-25 15:28:22.778734	PAID	5	[{"method": "EFECTIVO", "amount": 26, "displayAmount": 26, "type": null, "id": 1774465221953, "received": 26, "cambio": 0}]	31	16	20
2065	V6140	18	2026-03-25 15:32:57.75355	PAID	5	[{"method": "EFECTIVO", "amount": 18, "received": 18, "cambio": 0, "displayAmount": 18, "type": null, "id": 1774492043164}]	35	24	3
2081	V1207	85	2026-03-25 19:01:35.895164	PAID	2	[{"method": "EFECTIVO", "amount": 85, "displayAmount": 200, "type": null, "id": 1774465295855, "received": 200, "cambio": 115}]	31	20	\N
2082	V8159	1550	2026-03-25 19:27:55.550564	PAID	4	[{"method": "EFECTIVO", "amount": 1550, "displayAmount": 1550, "type": null, "id": 1774466890779, "received": 1550, "cambio": 0}]	31	20	20
2073	V5543	58	2026-03-25 15:51:41.591164	PAID	5	[{"method": "EFECTIVO", "amount": 58, "displayAmount": 58, "type": null, "id": 1774467279154, "received": 58, "cambio": 0}]	31	14	20
2077	V6888	30	2026-03-25 16:44:36.603513	PAID	5	[{"method": "EFECTIVO", "amount": 30, "displayAmount": 30, "type": null, "id": 1774467307513, "received": 30, "cambio": 0}]	31	16	20
2079	V1477	78	2026-03-25 18:46:48.731135	PAID	5	[{"method": "EFECTIVO", "amount": 78, "displayAmount": 78, "type": null, "id": 1774467318393, "received": 78, "cambio": 0}]	31	16	20
2080	V9264	84	2026-03-25 18:54:22.960781	PAID	5	[{"method": "EFECTIVO", "amount": 84, "displayAmount": 84, "type": null, "id": 1774467325568, "received": 84, "cambio": 0}]	31	16	20
2075	V9352	48	2026-03-25 16:05:09.840543	PAID	4	[{"method": "EFECTIVO", "amount": 48, "displayAmount": 48, "type": null, "id": 1774467334974, "received": 48, "cambio": 0}]	31	20	20
2067	V1419	4	2026-03-25 15:34:48.625659	PAID	4	[{"method": "EFECTIVO", "amount": 4, "displayAmount": 4, "type": null, "id": 1774467344036, "received": 4, "cambio": 0}]	31	20	20
2083	V8890	34	2026-03-25 20:13:43.036671	PAID	3	[{"method": "EFECTIVO", "amount": 34, "displayAmount": 34, "type": null, "id": 1774470336975, "received": 34, "cambio": 0}]	32	8	20
2085	V4227	255	2026-03-25 20:29:57.074199	PAID	4	[{"method": "EFECTIVO", "amount": 255, "displayAmount": 255, "type": null, "id": 1774470597437, "received": 255, "cambio": 0}]	33	20	\N
2084	V8131	164	2026-03-25 20:27:42.570859	PAID	3	[{"method": "EFECTIVO", "amount": 164, "received": 164, "cambio": 0, "displayAmount": 164, "type": null, "id": 1774473018307}]	34	8	1
2086	V8162	95	2026-03-25 20:57:56.979001	PAID	3	[{"method": "EFECTIVO", "amount": 95, "received": 95, "cambio": 0, "displayAmount": 95, "type": null, "id": 1774473037159}]	34	8	1
2087	V8390	105	2026-03-25 21:06:02.079081	PAID	3	[{"method": "EFECTIVO", "amount": 105, "received": 105, "cambio": 0, "displayAmount": 105, "type": null, "id": 1774473046092}]	34	8	1
2088	V7761	81	2026-03-25 21:24:47.195054	PAID	5	[{"method": "EFECTIVO", "amount": 81, "received": 100, "cambio": 19, "displayAmount": 100, "type": null, "id": 1774473906278}]	34	8	1
2089	V5303	101	2026-03-25 21:24:58.49019	PAID	3	[{"method": "EFECTIVO", "amount": 101, "received": 501, "cambio": 400, "displayAmount": 501, "type": null, "id": 1774473930704}]	34	24	1
2090	V5445	45	2026-03-25 21:31:10.962259	PAID	5	[{"method": "EFECTIVO", "amount": 45, "received": 100, "cambio": 55, "displayAmount": 100, "type": null, "id": 1774474286232}]	34	8	1
2091	V9035	49	2026-03-25 21:38:27.025237	PAID	5	[{"method": "EFECTIVO", "amount": 49, "received": 49, "cambio": 0, "displayAmount": 49, "type": null, "id": 1774474767339}]	35	8	3
2094	V1595	119	2026-03-25 21:47:30.899044	PAID	5	[{"method": "EFECTIVO", "amount": 119, "received": 200, "cambio": 81, "displayAmount": 200, "type": null, "id": 1774475264342}]	35	8	3
2095	V4098	80	2026-03-25 21:52:30.769872	PAID	3	[{"method": "EFECTIVO", "amount": 80, "received": 100, "cambio": 20, "displayAmount": 100, "type": null, "id": 1774475565270}]	35	8	3
2097	V8346	20	2026-03-25 22:21:29.566014	PAID	5	[{"method": "EFECTIVO", "amount": 20, "received": 20, "cambio": 0, "displayAmount": 20, "type": null, "id": 1774477303548}]	35	18	3
2092	V5728	34	2026-03-25 21:40:28.968721	PAID	5	[{"method": "EFECTIVO", "amount": 34, "received": 34, "cambio": 0, "displayAmount": 34, "type": null, "id": 1774478073468}]	35	8	3
2099	V3941	32	2026-03-25 22:39:23.253937	PAID	3	[{"method": "EFECTIVO", "amount": 32, "received": 32, "cambio": 0, "displayAmount": 32, "type": null, "id": 1774479438926}]	35	24	3
2100	V2762	39	2026-03-25 22:43:44.348872	PAID	3	[{"method": "EFECTIVO", "amount": 39, "received": 39, "cambio": 0, "displayAmount": 39, "type": null, "id": 1774479453142}]	35	24	3
2093	V7215	21	2026-03-25 21:46:07.812499	PAID	5	[{"method": "EFECTIVO", "amount": 21, "received": 21, "cambio": 0, "displayAmount": 21, "type": null, "id": 1774479476653}]	35	8	3
2104	V3469	95	2026-03-25 23:03:44.174791	PAID	3	[{"method": "EFECTIVO", "amount": 95, "received": 500, "cambio": 405, "displayAmount": 500, "type": null, "id": 1774479945282}]	35	8	3
2109	V7752	171	2026-03-25 23:28:58.656634	PAID	5	[{"method": "EFECTIVO", "amount": 171, "received": 200, "cambio": 29, "displayAmount": 200, "type": null, "id": 1774481351389}]	35	18	3
2111	V6434	112	2026-03-25 23:33:52.740488	PAID	5	[{"method": "EFECTIVO", "amount": 112, "received": 200, "cambio": 88, "displayAmount": 200, "type": null, "id": 1774481664168}]	35	18	3
2114	V9056	88	2026-03-25 23:41:54.81128	PAID	3	[{"method": "EFECTIVO", "amount": 88, "received": 200, "cambio": 112, "displayAmount": 200, "type": null, "id": 1774482136592}]	35	18	3
2119	V8868	162	2026-03-25 23:49:23.647956	PAID	3	[{"method": "EFECTIVO", "amount": 162, "received": 500, "cambio": 338, "displayAmount": 500, "type": null, "id": 1774573081214}]	70	9	1
2107	V6608	32	2026-03-25 23:11:33.95231	PAID	3	[{"method": "EFECTIVO", "amount": 32, "received": 32, "cambio": 0, "displayAmount": 32, "type": null, "id": 1774482593682}]	35	18	3
2121	V9698	103	2026-03-25 23:52:13.232251	PAID	3	[{"method": "EFECTIVO", "amount": 103, "received": 504, "cambio": 401, "displayAmount": 504, "type": null, "id": 1774482784505}]	35	18	3
2122	V1715	72	2026-03-25 23:56:10.727807	PAID	3	[{"method": "EFECTIVO", "amount": 72, "received": 200, "cambio": 128, "displayAmount": 200, "type": null, "id": 1774483007745}]	35	18	3
2123	V7348	60	2026-03-25 23:56:34.270427	PAID	5	[{"method": "EFECTIVO", "amount": 60, "received": 60, "cambio": 0, "displayAmount": 60, "type": null, "id": 1774483106229}]	35	24	3
2131	V2565	45	2026-03-26 00:10:09.108143	PAID	3	[{"method": "EFECTIVO", "amount": 45, "received": 45, "cambio": 0, "displayAmount": 45, "type": null, "id": 1774483903559}]	35	18	3
2134	V5239	18	2026-03-26 00:13:19.398361	PAID	3	[{"method": "EFECTIVO", "amount": 18, "received": 50, "cambio": 32, "displayAmount": 50, "type": null, "id": 1774484028884}]	35	18	3
2135	V5688	109	2026-03-26 00:15:21.678395	PAID	3	[{"method": "EFECTIVO", "amount": 109, "received": 109, "cambio": 0, "displayAmount": 109, "type": null, "id": 1774484147918}]	35	18	3
2137	V1346	44	2026-03-26 00:16:21.926872	PAID	6	[{"method": "EFECTIVO", "amount": 44, "received": 45, "cambio": 1, "displayAmount": 45, "type": null, "id": 1774484233370}]	35	8	3
2142	V8097	72	2026-03-26 00:26:58.80418	PAID	6	[{"method": "EFECTIVO", "amount": 72, "received": 72, "cambio": 0, "displayAmount": 72, "type": null, "id": 1774571546863}]	70	24	1
2143	V4569	54	2026-03-26 00:29:24.13058	PAID	5	[{"method": "EFECTIVO", "amount": 54, "received": 500, "cambio": 446, "displayAmount": 500, "type": null, "id": 1774484970927}]	35	18	3
2145	V3709	61	2026-03-26 00:33:22.00847	PAID	5	[{"method": "EFECTIVO", "amount": 61, "received": 61, "cambio": 0, "displayAmount": 61, "type": null, "id": 1774485222750}]	35	18	3
2146	V8523	170	2026-03-26 00:34:26.663059	PAID	3	[{"method": "EFECTIVO", "amount": 170, "received": 200, "cambio": 30, "displayAmount": 200, "type": null, "id": 1774485277699}]	35	8	3
2150	V2724	98	2026-03-26 00:43:15.106357	PAID	3	[{"method": "EFECTIVO", "amount": 98, "received": 100, "cambio": 2, "displayAmount": 100, "type": null, "id": 1774485817621}]	35	8	3
2151	V1101	118	2026-03-26 00:44:51.280955	PAID	5	[{"method": "EFECTIVO", "amount": 118, "received": 120, "cambio": 2, "displayAmount": 120, "type": null, "id": 1774485916388}]	35	24	3
2153	V6357	80	2026-03-26 00:46:38.496893	PAID	6	[{"method": "EFECTIVO", "amount": 80, "received": 100, "cambio": 20, "displayAmount": 100, "type": null, "id": 1774486017072}]	35	18	3
2162	V3002	54	2026-03-26 01:09:14.549659	PAID	3	[{"method": "EFECTIVO", "amount": 54, "received": 100, "cambio": 46, "displayAmount": 100, "type": null, "id": 1774487362850}]	35	24	3
2105	V6920	93	2026-03-25 23:06:40.71455	PAID	3	[{"method": "EFECTIVO", "amount": 93, "received": 100, "cambio": 7, "displayAmount": 100, "type": null, "id": 1774486664391}]	35	18	3
2155	V5741	31	2026-03-26 00:52:51.126154	PAID	6	[{"method": "EFECTIVO", "amount": 31, "received": 31, "cambio": 0, "displayAmount": 31, "type": null, "id": 1774487300187}]	35	18	3
2163	V6085	17	2026-03-26 01:09:42.59604	PAID	3	[{"method": "EFECTIVO", "amount": 17, "received": 50, "cambio": 33, "displayAmount": 50, "type": null, "id": 1774487390312}]	35	24	3
2167	V2779	117	2026-03-26 01:19:00.531966	PAID	3	[{"method": "EFECTIVO", "amount": 117, "received": 117, "cambio": 0, "displayAmount": 117, "type": null, "id": 1774487998924}]	35	24	3
2168	V9842	32	2026-03-26 01:19:11.910598	PAID	6	[{"method": "EFECTIVO", "amount": 32, "received": 200, "cambio": 168, "displayAmount": 200, "type": null, "id": 1774488064136}]	35	18	3
2170	V1157	18	2026-03-26 01:19:38.321324	PAID	5	[{"method": "EFECTIVO", "amount": 18, "received": 18, "cambio": 0, "displayAmount": 18, "type": null, "id": 1774491668673}]	35	18	3
2096	V2550	35	2026-03-25 22:07:58.920731	PAID	5	[{"method": "EFECTIVO", "amount": 35, "received": 35, "cambio": 0, "displayAmount": 35, "type": null, "id": 1774476498170}]	35	18	3
2102	V2473	45	2026-03-25 22:54:06.013407	PAID	3	[{"method": "EFECTIVO", "amount": 45, "received": 45, "cambio": 0, "displayAmount": 45, "type": null, "id": 1774479464503}]	35	18	3
2106	V4621	101	2026-03-25 23:09:17.171411	PAID	3	[{"method": "EFECTIVO", "amount": 101, "received": 101, "cambio": 0, "displayAmount": 101, "type": null, "id": 1774480167088}]	35	8	3
2113	V5429	58	2026-03-25 23:37:40.157337	PAID	3	[{"method": "EFECTIVO", "amount": 58, "received": 58, "cambio": 0, "displayAmount": 58, "type": null, "id": 1774481875613}]	35	24	3
2115	V6980	80	2026-03-25 23:41:56.389488	PAID	5	[{"method": "EFECTIVO", "amount": 80, "received": 500, "cambio": 420, "displayAmount": 500, "type": null, "id": 1774482189913}]	35	24	3
2120	V2546	57	2026-03-25 23:51:27.188414	PAID	5	[{"method": "EFECTIVO", "amount": 57, "received": 200, "cambio": 143, "displayAmount": 200, "type": null, "id": 1774482730034}]	35	24	3
2124	V4622	50	2026-03-25 23:57:48.448442	PAID	3	[{"method": "EFECTIVO", "amount": 50, "received": 50, "cambio": 0, "displayAmount": 50, "type": null, "id": 1774483138978}]	35	18	3
2125	V4047	67	2026-03-26 00:01:57.928883	PAID	3	[{"method": "EFECTIVO", "amount": 67, "received": 70, "cambio": 3, "displayAmount": 70, "type": null, "id": 1774483355661}]	35	18	3
2126	V1659	45	2026-03-26 00:03:11.195841	PAID	5	[{"method": "EFECTIVO", "amount": 45, "received": 50, "cambio": 5, "displayAmount": 50, "type": null, "id": 1774483421283}]	35	24	3
2129	V3143	308	2026-03-26 00:08:21.490969	PAID	3	[{"method": "EFECTIVO", "amount": 308, "received": 310, "cambio": 2, "displayAmount": 310, "type": null, "id": 1774483784538}]	35	18	3
2130	V2318	60	2026-03-26 00:09:44.6253	PAID	5	[{"method": "EFECTIVO", "amount": 60, "received": 100, "cambio": 40, "displayAmount": 100, "type": null, "id": 1774483855883}]	35	24	3
2132	V5327	34	2026-03-26 00:10:35.806643	PAID	5	[{"method": "EFECTIVO", "amount": 34, "received": 200, "cambio": 166, "displayAmount": 200, "type": null, "id": 1774483937783}]	35	24	3
2133	V6745	59	2026-03-26 00:12:43.159672	PAID	3	[{"method": "EFECTIVO", "amount": 59, "received": 59, "cambio": 0, "displayAmount": 59, "type": null, "id": 1774484073260}]	35	18	3
2138	V1325	124	2026-03-26 00:17:19.646544	PAID	5	[{"method": "EFECTIVO", "amount": 124, "received": 500, "cambio": 376, "displayAmount": 500, "type": null, "id": 1774484256043}]	35	24	3
2139	V1408	78	2026-03-26 00:23:32.934606	PAID	3	[{"method": "EFECTIVO", "amount": 78, "received": 100, "cambio": 22, "displayAmount": 100, "type": null, "id": 1774484625297}]	35	24	3
2147	V6929	75	2026-03-26 00:34:48.840397	PAID	5	[{"method": "EFECTIVO", "amount": 75, "received": 100, "cambio": 25, "displayAmount": 100, "type": null, "id": 1774485313686}]	35	18	3
2149	V9805	24	2026-03-26 00:43:04.633145	PAID	5	[{"method": "EFECTIVO", "amount": 24, "received": 24, "cambio": 0, "displayAmount": 24, "type": null, "id": 1774485811265}]	35	24	3
2154	V2249	32	2026-03-26 00:48:18.111944	PAID	3	[{"method": "EFECTIVO", "amount": 32, "received": 100, "cambio": 68, "displayAmount": 100, "type": null, "id": 1774486116809}]	35	8	3
2157	V7623	74	2026-03-26 01:02:28.322918	PAID	5	[{"method": "EFECTIVO", "amount": 74, "received": 200, "cambio": 126, "displayAmount": 200, "type": null, "id": 1774486968946}]	35	18	3
2164	V6672	103	2026-03-26 01:14:45.592398	PAID	5	[{"method": "EFECTIVO", "amount": 103, "received": 103, "cambio": 0, "displayAmount": 103, "type": null, "id": 1774487696249}]	35	18	3
2165	V7078	214	2026-03-26 01:18:19.534681	PAID	5	[{"method": "EFECTIVO", "amount": 214, "received": 214, "cambio": 0, "displayAmount": 214, "type": null, "id": 1774487921316}]	35	18	3
2166	V8125	26	2026-03-26 01:18:23.307961	PAID	6	[{"method": "EFECTIVO", "amount": 26, "received": 100, "cambio": 74, "displayAmount": 100, "type": null, "id": 1774487940009}]	35	18	3
2171	V6747	23	2026-03-26 01:20:03.329197	PAID	6	[{"method": "EFECTIVO", "amount": 23, "received": 23, "cambio": 0, "displayAmount": 23, "type": null, "id": 1774488124545}]	35	18	3
2173	V5962	149	2026-03-26 01:21:55.539197	PAID	3	[{"method": "EFECTIVO", "amount": 149, "received": 200, "cambio": 51, "displayAmount": 200, "type": null, "id": 1774488139931}]	35	24	3
2490	V4706	32	2026-03-27 01:33:05.252959	PAID	6	[{"method": "EFECTIVO", "amount": 32, "received": 32, "cambio": 0, "displayAmount": 32, "type": null, "id": 1774575650181}]	70	24	1
2500	V5863	32	2026-03-27 01:40:02.606396	PAID	5	[{"method": "EFECTIVO", "amount": 32, "received": 32, "cambio": 0, "displayAmount": 32, "type": null, "id": 1774575661624}]	70	4	1
2501	V4041	32	2026-03-27 01:41:07.528502	PAID	5	[{"method": "EFECTIVO", "amount": 32, "received": 50, "cambio": 18, "displayAmount": 50, "type": null, "id": 1774575675513}]	70	4	1
2503	V2352	110	2026-03-27 01:42:13.176147	PAID	3	[{"method": "EFECTIVO", "amount": 110, "received": 110, "cambio": 0, "displayAmount": 110, "type": null, "id": 1774575809766}]	70	13	1
2504	V2885	61	2026-03-27 01:44:49.807105	PAID	5	[{"method": "EFECTIVO", "amount": 61, "received": 200, "cambio": 139, "displayAmount": 200, "type": null, "id": 1774575932163}]	70	4	1
2505	V1944	74	2026-03-27 01:47:41.746362	PAID	3	[{"method": "EFECTIVO", "amount": 74, "received": 74, "cambio": 0, "displayAmount": 74, "type": null, "id": 1774576092357}]	70	13	1
2506	V9568	93	2026-03-27 01:50:04.960304	PAID	3	[{"method": "EFECTIVO", "amount": 93, "received": 100, "cambio": 7, "displayAmount": 100, "type": null, "id": 1774576217532}]	70	13	1
2508	V4767	64	2026-03-27 01:53:51.459401	PAID	3	[{"method": "EFECTIVO", "amount": 64, "received": 64, "cambio": 0, "displayAmount": 64, "type": null, "id": 1774576449914}]	70	13	1
2479	V5989	35	2026-03-27 01:24:55.425559	PAID	5	[{"method": "EFECTIVO", "amount": 35, "received": 35, "cambio": 0, "displayAmount": 35, "type": null, "id": 1774576569394}]	70	4	1
2511	V2277	371	2026-03-27 02:01:33.408274	PAID	5	[{"method": "EFECTIVO", "amount": 371, "received": 500, "cambio": 129, "displayAmount": 500, "type": null, "id": 1774576917204}]	70	4	1
2515	V7534	48	2026-03-27 02:03:25.690062	PAID	3	[{"method": "EFECTIVO", "amount": 48, "received": 200, "cambio": 152, "displayAmount": 200, "type": null, "id": 1774577056486}]	70	13	1
2517	V6139	61	2026-03-27 02:06:00.01406	PAID	5	[{"method": "EFECTIVO", "amount": 61, "received": 200, "cambio": 139, "displayAmount": 200, "type": null, "id": 1774577170396}]	70	4	1
2516	V2799	42	2026-03-27 02:04:19.252503	PAID	5	[{"method": "EFECTIVO", "amount": 42, "received": 42, "cambio": 0, "displayAmount": 42, "type": null, "id": 1774577421195}]	70	4	1
2098	V4929	68	2026-03-25 22:37:39.02801	PAID	3	[{"method": "EFECTIVO", "amount": 68, "received": 68, "cambio": 0, "displayAmount": 68, "type": null, "id": 1774479420190}]	35	24	3
2101	V5994	149	2026-03-25 22:52:48.942171	PAID	3	[{"method": "EFECTIVO", "amount": 149, "received": 149, "cambio": 0, "displayAmount": 149, "type": null, "id": 1774479458899}]	35	18	3
2103	V4529	32	2026-03-25 22:56:46.379147	PAID	3	[{"method": "EFECTIVO", "amount": 32, "received": 32, "cambio": 0, "displayAmount": 32, "type": null, "id": 1774479470014}]	35	18	3
2108	V7983	38	2026-03-25 23:24:52.161414	PAID	5	[{"method": "EFECTIVO", "amount": 38, "received": 38, "cambio": 0, "displayAmount": 38, "type": null, "id": 1774481127967}]	35	18	3
2110	V5953	152	2026-03-25 23:32:32.311472	PAID	5	[{"method": "EFECTIVO", "amount": 152, "received": 152, "cambio": 0, "displayAmount": 152, "type": null, "id": 1774481590127}]	35	18	3
2112	V4993	113	2026-03-25 23:35:00.455362	PAID	3	[{"method": "EFECTIVO", "amount": 113, "received": 500, "cambio": 387, "displayAmount": 500, "type": null, "id": 1774481710416}]	35	24	3
2116	V5966	62	2026-03-25 23:42:46.187585	PAID	5	[{"method": "EFECTIVO", "amount": 62, "received": 62, "cambio": 0, "displayAmount": 62, "type": null, "id": 1774482229625}]	35	24	3
2117	V8049	59	2026-03-25 23:43:35.918696	PAID	3	[{"method": "EFECTIVO", "amount": 59, "received": 200, "cambio": 141, "displayAmount": 200, "type": null, "id": 1774482252457}]	35	18	3
2118	V2071	116	2026-03-25 23:43:37.319639	PAID	6	[{"method": "EFECTIVO", "amount": 116, "received": 200, "cambio": 84, "displayAmount": 200, "type": null, "id": 1774482283471}]	35	8	3
2127	V1276	38	2026-03-26 00:06:51.692627	PAID	5	[{"method": "EFECTIVO", "amount": 38, "received": 38, "cambio": 0, "displayAmount": 38, "type": null, "id": 1774575177089}]	70	4	1
2128	V7775	29	2026-03-26 00:08:21.358232	PAID	5	[{"method": "EFECTIVO", "amount": 29, "received": 50, "cambio": 21, "displayAmount": 50, "type": null, "id": 1774483815838}]	35	24	3
2136	V9878	128	2026-03-26 00:16:09.611938	PAID	3	[{"method": "EFECTIVO", "amount": 128, "received": 128, "cambio": 0, "displayAmount": 128, "type": null, "id": 1774484193953}]	35	18	3
2140	V9686	103	2026-03-26 00:24:06.382996	PAID	5	[{"method": "EFECTIVO", "amount": 103, "received": 200, "cambio": 97, "displayAmount": 200, "type": null, "id": 1774484661448}]	35	18	3
2141	V2463	210	2026-03-26 00:26:57.436613	PAID	5	[{"method": "EFECTIVO", "amount": 210, "received": 500, "cambio": 290, "displayAmount": 500, "type": null, "id": 1774484828890}]	35	18	3
2144	V4952	119	2026-03-26 00:30:14.028352	PAID	5	[{"method": "EFECTIVO", "amount": 119, "received": 119, "cambio": 0, "displayAmount": 119, "type": null, "id": 1774485062658}]	35	18	3
2148	V9692	48	2026-03-26 00:36:02.797509	PAID	3	[{"method": "EFECTIVO", "amount": 48, "received": 100, "cambio": 52, "displayAmount": 100, "type": null, "id": 1774485371450}]	35	8	3
2152	V6456	26	2026-03-26 00:46:03.197549	PAID	3	[{"method": "EFECTIVO", "amount": 26, "received": 26, "cambio": 0, "displayAmount": 26, "type": null, "id": 1774486154677}]	35	8	3
2156	V6892	46	2026-03-26 00:53:40.363908	PAID	3	[{"method": "EFECTIVO", "amount": 46, "received": 50, "cambio": 4, "displayAmount": 50, "type": null, "id": 1774486458900}]	35	24	3
2159	V1314	47	2026-03-26 01:05:37.524944	PAID	6	[{"method": "EFECTIVO", "amount": 47, "received": 60, "cambio": 13, "displayAmount": 60, "type": null, "id": 1774487169041}]	35	8	3
2161	V5988	69	2026-03-26 01:07:17.365216	PAID	3	[{"method": "EFECTIVO", "amount": 69, "received": 100, "cambio": 31, "displayAmount": 100, "type": null, "id": 1774487261754}]	35	24	3
2172	V5693	82	2026-03-26 01:21:54.728616	PAID	6	[{"method": "EFECTIVO", "amount": 82, "received": 100, "cambio": 18, "displayAmount": 100, "type": null, "id": 1774490091579}]	35	18	3
2174	V5495	158	2026-03-26 01:23:16.028256	PAID	5	[{"method": "EFECTIVO", "amount": 158, "received": 200, "cambio": 42, "displayAmount": 200, "type": null, "id": 1774488207603}]	35	8	3
2175	V3249	83	2026-03-26 01:23:31.481643	PAID	3	[{"method": "EFECTIVO", "amount": 83, "received": 200, "cambio": 117, "displayAmount": 200, "type": null, "id": 1774488230550}]	35	24	3
2176	V2771	32	2026-03-26 01:24:36.883188	PAID	5	[{"method": "EFECTIVO", "amount": 32, "received": 32, "cambio": 0, "displayAmount": 32, "type": null, "id": 1774488292787}]	35	8	3
2177	V6193	71	2026-03-26 01:25:21.327315	PAID	3	[{"method": "EFECTIVO", "amount": 71, "received": 200, "cambio": 129, "displayAmount": 200, "type": null, "id": 1774488338374}]	35	24	3
2178	V2686	78	2026-03-26 01:26:21.089147	PAID	6	[{"method": "EFECTIVO", "amount": 78, "received": 100, "cambio": 22, "displayAmount": 100, "type": null, "id": 1774488453139}]	35	3	3
2180	V8643	98	2026-03-26 01:26:51.779742	PAID	5	[{"method": "EFECTIVO", "amount": 98, "received": 98, "cambio": 0, "displayAmount": 98, "type": null, "id": 1774488487142}]	35	8	3
2182	V5278	63	2026-03-26 01:27:35.074062	PAID	3	[{"method": "EFECTIVO", "amount": 63, "received": 100, "cambio": 37, "displayAmount": 100, "type": null, "id": 1774488506809}]	35	24	3
2181	V8653	55	2026-03-26 01:27:33.183535	PAID	6	[{"method": "EFECTIVO", "amount": 55, "received": 500, "cambio": 445, "displayAmount": 500, "type": null, "id": 1774488550411}]	35	3	3
2183	V3448	62	2026-03-26 01:28:35.05555	PAID	3	[{"method": "EFECTIVO", "amount": 62, "received": 70, "cambio": 8, "displayAmount": 70, "type": null, "id": 1774488597936}]	35	24	3
2184	V4010	79	2026-03-26 01:29:15.108502	PAID	4	[{"method": "EFECTIVO", "amount": 79, "received": 200, "cambio": 121, "displayAmount": 200, "type": null, "id": 1774488678784}]	35	1	3
2185	V6885	57	2026-03-26 01:30:04.215911	PAID	3	[{"method": "EFECTIVO", "amount": 57, "received": 57, "cambio": 0, "displayAmount": 57, "type": null, "id": 1774488721198}]	35	24	3
2186	V6984	63	2026-03-26 01:30:23.67301	PAID	5	[{"method": "EFECTIVO", "amount": 63, "received": 200, "cambio": 137, "displayAmount": 200, "type": null, "id": 1774488753841}]	35	8	3
2187	V5739	26	2026-03-26 01:30:30.192846	PAID	4	[{"method": "EFECTIVO", "amount": 26, "received": 26, "cambio": 0, "displayAmount": 26, "type": null, "id": 1774488778689}]	35	1	3
2188	V5923	60	2026-03-26 01:32:52.689319	PAID	5	[{"method": "EFECTIVO", "amount": 60, "received": 100, "cambio": 40, "displayAmount": 100, "type": null, "id": 1774488859870}]	35	8	3
2502	V9012	36	2026-03-27 01:41:50.264354	PAID	5	[{"method": "EFECTIVO", "amount": 36, "received": 36, "cambio": 0, "displayAmount": 36, "type": null, "id": 1774576906948}]	70	4	1
2189	V1436	209	2026-03-26 01:32:55.17448	PAID	6	[{"method": "EFECTIVO", "amount": 209, "received": 220, "cambio": 11, "displayAmount": 220, "type": null, "id": 1774488891046}]	35	3	3
2197	V5191	40	2026-03-26 01:40:41.265406	PAID	3	[{"method": "EFECTIVO", "amount": 40, "received": 50, "cambio": 10, "displayAmount": 50, "type": null, "id": 1774489272294}]	35	4	3
2199	V9364	155	2026-03-26 01:41:57.269039	PAID	5	[{"method": "EFECTIVO", "amount": 155, "received": 500, "cambio": 345, "displayAmount": 500, "type": null, "id": 1774489332621}]	35	8	3
2198	V6974	26	2026-03-26 01:41:21.113577	PAID	4	[{"method": "EFECTIVO", "amount": 26, "received": 100, "cambio": 74, "displayAmount": 100, "type": null, "id": 1774489369891}]	35	9	3
2192	V8016	85	2026-03-26 01:37:31.165273	PAID	6	[{"method": "EFECTIVO", "amount": 85, "received": 85, "cambio": 0, "displayAmount": 85, "type": null, "id": 1774489419558}]	35	24	3
2521	V3319	28	2026-03-27 02:11:18.850903	PAID	5	[{"method": "EFECTIVO", "amount": 28, "received": 28, "cambio": 0, "displayAmount": 28, "type": null, "id": 1774577591535}]	70	4	1
2207	V5063	101	2026-03-26 01:51:33.303919	PAID	4	[{"method": "EFECTIVO", "amount": 101, "received": 101, "cambio": 0, "displayAmount": 101, "type": null, "id": 1774489925602}]	35	18	3
2210	V1894	32	2026-03-26 01:53:59.425396	PAID	3	[{"method": "EFECTIVO", "amount": 32, "received": 100, "cambio": 68, "displayAmount": 100, "type": null, "id": 1774490049302}]	35	8	3
2212	V1330	24	2026-03-26 01:57:59.853592	PAID	6	[{"method": "EFECTIVO", "amount": 24, "received": 24, "cambio": 0, "displayAmount": 24, "type": null, "id": 1774490384957}]	35	24	3
2216	V8922	71	2026-03-26 02:00:58.92733	PAID	3	[{"method": "EFECTIVO", "amount": 71, "received": 200, "cambio": 129, "displayAmount": 200, "type": null, "id": 1774490470256}]	35	8	3
2217	V2624	20	2026-03-26 02:03:14.29634	PAID	3	[{"method": "EFECTIVO", "amount": 20, "received": 50, "cambio": 30, "displayAmount": 50, "type": null, "id": 1774490608528}]	35	8	3
2223	V8663	65	2026-03-26 02:12:29.854927	PAID	5	[{"method": "EFECTIVO", "amount": 65, "received": 100, "cambio": 35, "displayAmount": 100, "type": null, "id": 1774491193804}]	35	4	3
2227	V3882	122	2026-03-26 02:15:24.640241	PAID	3	[{"method": "EFECTIVO", "amount": 122, "received": 200, "cambio": 78, "displayAmount": 200, "type": null, "id": 1774491335229}]	35	24	3
2226	V7529	85	2026-03-26 02:15:20.766722	PAID	5	[{"method": "EFECTIVO", "amount": 85, "received": 500, "cambio": 415, "displayAmount": 500, "type": null, "id": 1774491369540}]	35	4	3
2230	V5360	57	2026-03-26 02:20:59.519091	PAID	3	[{"method": "EFECTIVO", "amount": 57, "received": 57, "cambio": 0, "displayAmount": 57, "type": null, "id": 1774491677497}]	35	24	3
2232	V8425	26	2026-03-26 02:21:55.278551	PAID	3	[{"method": "EFECTIVO", "amount": 26, "received": 100, "cambio": 74, "displayAmount": 100, "type": null, "id": 1774491727683}]	35	24	3
2235	V1929	66	2026-03-26 02:23:24.643489	PAID	3	[{"method": "EFECTIVO", "amount": 66, "received": 500, "cambio": 434, "displayAmount": 500, "type": null, "id": 1774491821891}]	35	24	3
2236	V1504	39	2026-03-26 02:23:32.069535	PAID	5	[{"method": "EFECTIVO", "amount": 39, "received": 39, "cambio": 0, "displayAmount": 39, "type": null, "id": 1774491864569}]	35	4	3
2237	V5684	65	2026-03-26 02:24:16.614098	PAID	4	[{"method": "EFECTIVO", "amount": 65, "received": 65, "cambio": 0, "displayAmount": 65, "type": null, "id": 1774491874026}]	35	9	3
2238	V7261	62	2026-03-26 02:25:21.333858	PAID	5	[{"method": "EFECTIVO", "amount": 62, "received": 70, "cambio": 8, "displayAmount": 70, "type": null, "id": 1774491957145}]	35	4	3
2239	V3937	43	2026-03-26 02:26:45.231625	PAID	3	[{"method": "EFECTIVO", "amount": 43, "received": 43, "cambio": 0, "displayAmount": 43, "type": null, "id": 1774492032785}]	35	24	3
2240	V8934	135	2026-03-26 02:28:09.027746	PAID	5	[{"method": "EFECTIVO", "amount": 135, "received": 135, "cambio": 0, "displayAmount": 135, "type": null, "id": 1774492159950}]	35	18	3
2205	V7129	18	2026-03-26 01:48:55.160471	PAID	4	[{"method": "EFECTIVO", "amount": 18, "displayAmount": 200, "type": null, "id": 1774533543948, "received": 200, "cambio": 182}]	69	15	20
2524	V8059	49	2026-03-27 02:14:27.467032	PAID	5	[{"method": "EFECTIVO", "amount": 49, "received": 50, "cambio": 1, "displayAmount": 50, "type": null, "id": 1774577681774}]	70	4	1
2195	V4426	38	2026-03-26 01:39:58.50498	PAID	3	[{"method": "EFECTIVO", "amount": 38, "displayAmount": 50, "type": null, "id": 1774533904275, "received": 50, "cambio": 12}]	69	14	20
2507	V7066	68	2026-03-27 01:52:38.622331	PAID	3	[{"method": "EFECTIVO", "amount": 68, "received": 200, "cambio": 132, "displayAmount": 200, "type": null, "id": 1774576371169}]	70	13	1
2509	V3752	46	2026-03-27 01:59:06.499758	PAID	6	[{"method": "EFECTIVO", "amount": 46, "received": 50, "cambio": 4, "displayAmount": 50, "type": null, "id": 1774576767483}]	70	9	1
2510	V9753	25	2026-03-27 02:00:36.644413	PAID	3	[{"method": "EFECTIVO", "amount": 25, "received": 25, "cambio": 0, "displayAmount": 25, "type": null, "id": 1774576896464}]	70	13	1
2514	V5085	41	2026-03-27 02:03:05.347679	PAID	6	[{"method": "EFECTIVO", "amount": 41, "received": 101, "cambio": 60, "displayAmount": 101, "type": null, "id": 1774577031446}]	70	9	1
2519	V4224	93	2026-03-27 02:07:47.477477	PAID	3	[{"method": "EFECTIVO", "amount": 93, "received": 500, "cambio": 407, "displayAmount": 500, "type": null, "id": 1774577300215}]	70	13	1
2424	V5752	110	2026-03-27 00:13:55.151348	PAID	3	[{"method": "EFECTIVO", "amount": 110, "received": 110, "cambio": 0, "displayAmount": 110, "type": null, "id": 1774577429955}]	70	4	1
2526	V2793	37	2026-03-27 02:17:32.965651	PAID	3	[{"method": "EFECTIVO", "amount": 37, "received": 100, "cambio": 63, "displayAmount": 100, "type": null, "id": 1774577859669}]	70	24	1
2522	V8766	35	2026-03-27 02:12:08.41504	PAID	5	[{"method": "EFECTIVO", "amount": 35, "received": 35, "cambio": 0, "displayAmount": 35, "type": null, "id": 1774578063140}]	70	4	1
2523	V9222	116	2026-03-27 02:13:38.899393	PAID	5	[{"method": "EFECTIVO", "amount": 116, "received": 116, "cambio": 0, "displayAmount": 116, "type": null, "id": 1774578068669}]	70	4	1
2530	V3977	132	2026-03-27 02:23:15.765271	PAID	5	[{"method": "EFECTIVO", "amount": 132, "received": 132, "cambio": 0, "displayAmount": 132, "type": null, "id": 1774578231247}]	70	4	1
2533	V8193	94	2026-03-27 02:25:58.886693	PAID	5	[{"method": "EFECTIVO", "amount": 94, "received": 94, "cambio": 0, "displayAmount": 94, "type": null, "id": 1774578390681}]	70	4	1
2538	V3489	91	2026-03-27 02:35:23.978748	PAID	3	[{"method": "EFECTIVO", "amount": 91, "received": 91, "cambio": 0, "displayAmount": 91, "type": null, "id": 1774578981017}]	70	13	1
2191	V4489	77	2026-03-26 01:36:55.39777	PAID	3	[{"method": "EFECTIVO", "amount": 77, "received": 200, "cambio": 123, "displayAmount": 200, "type": null, "id": 1774489031017}]	35	4	3
2193	V6658	93	2026-03-26 01:37:44.034193	PAID	5	[{"method": "EFECTIVO", "amount": 93, "received": 100, "cambio": 7, "displayAmount": 100, "type": null, "id": 1774489092831}]	35	8	3
2194	V9935	85	2026-03-26 01:38:34.224247	PAID	3	[{"method": "EFECTIVO", "amount": 85, "received": 100, "cambio": 15, "displayAmount": 100, "type": null, "id": 1774489142094}]	35	4	3
2196	V2420	165	2026-03-26 01:40:19.787341	PAID	4	[{"method": "EFECTIVO", "amount": 165, "received": 200, "cambio": 35, "displayAmount": 200, "type": null, "id": 1774489250069}]	35	9	3
2200	V3038	88	2026-03-26 01:43:45.782883	PAID	4	[{"method": "EFECTIVO", "amount": 88, "received": 100, "cambio": 12, "displayAmount": 100, "type": null, "id": 1774489449137}]	35	18	3
2536	V9659	40	2026-03-27 02:30:42.638142	PAID	5	[{"method": "EFECTIVO", "amount": 40, "received": 100, "cambio": 60, "displayAmount": 100, "type": null, "id": 1774578682058}]	70	4	1
2213	V8365	151	2026-03-26 01:58:30.151326	PAID	3	[{"method": "EFECTIVO", "amount": 151, "received": 151, "cambio": 0, "displayAmount": 151, "type": null, "id": 1774490333821}]	35	8	3
2169	V6566	30	2026-03-26 01:19:14.784582	PAID	5	[{"method": "EFECTIVO", "amount": 30, "received": 30, "cambio": 0, "displayAmount": 30, "type": null, "id": 1774490372543}]	35	18	3
2214	V6170	50	2026-03-26 02:00:21.19391	PAID	4	[{"method": "EFECTIVO", "amount": 50, "received": 100, "cambio": 50, "displayAmount": 100, "type": null, "id": 1774490445572}]	35	18	3
2537	V4173	130	2026-03-27 02:35:19.324595	PAID	6	[{"method": "EFECTIVO", "amount": 130, "received": 500, "cambio": 370, "displayAmount": 500, "type": null, "id": 1774578938432}]	70	9	1
2219	V6320	135	2026-03-26 02:09:10.202052	PAID	5	[{"method": "EFECTIVO", "amount": 135, "received": 135, "cambio": 0, "displayAmount": 135, "type": null, "id": 1774490967737}]	35	18	3
2225	V4565	91	2026-03-26 02:13:29.152162	PAID	4	[{"method": "EFECTIVO", "amount": 91, "received": 91, "cambio": 0, "displayAmount": 91, "type": null, "id": 1774491450692}]	35	9	3
2229	V5414	139	2026-03-26 02:19:42.710025	PAID	3	[{"method": "EFECTIVO", "amount": 139, "received": 500, "cambio": 361, "displayAmount": 500, "type": null, "id": 1774491594247}]	35	24	3
2231	V8142	103	2026-03-26 02:21:17.419141	PAID	5	[{"method": "EFECTIVO", "amount": 103, "received": 103, "cambio": 0, "displayAmount": 103, "type": null, "id": 1774491705192}]	35	4	3
2234	V4906	53	2026-03-26 02:22:48.323888	PAID	6	[{"method": "EFECTIVO", "amount": 53, "received": 100, "cambio": 47, "displayAmount": 100, "type": null, "id": 1774491791579}]	35	8	3
2208	V8500	132	2026-03-26 01:52:29.295494	PAID	4	[{"method": "TARJETA", "amount": 132, "displayAmount": 132, "type": "DEBITO", "id": 1774554490788}]	69	20	20
2209	V1262	41	2026-03-26 01:52:58.51668	PAID	6	[{"method": "EFECTIVO", "amount": 41, "displayAmount": 41, "type": null, "id": 1774557757513, "received": 41, "cambio": 0}]	69	20	20
2540	V7510	198	2026-03-27 02:36:59.156217	PAID	5	[{"method": "EFECTIVO", "amount": 198, "received": 198, "cambio": 0, "displayAmount": 198, "type": null, "id": 1774579089058}]	70	4	1
2215	V8501	31	2026-03-26 02:00:51.718217	PAID	5	[{"method": "EFECTIVO", "amount": 31, "received": 31, "cambio": 0, "displayAmount": 31, "type": null, "id": 1774570009810}]	70	13	1
2512	V4653	55	2026-03-27 02:02:08.392515	PAID	6	[{"method": "EFECTIVO", "amount": 55, "received": 55, "cambio": 0, "displayAmount": 55, "type": null, "id": 1774576952966}]	70	9	1
2518	V6291	48	2026-03-27 02:07:33.870856	PAID	5	[{"method": "EFECTIVO", "amount": 48, "received": 50, "cambio": 2, "displayAmount": 50, "type": null, "id": 1774577277653}]	70	4	1
2520	V7558	38	2026-03-27 02:08:39.885707	PAID	6	[{"method": "EFECTIVO", "amount": 38, "received": 38, "cambio": 0, "displayAmount": 38, "type": null, "id": 1774577349173}]	70	9	1
2513	V9653	50	2026-03-27 02:02:56.449083	PAID	5	[{"method": "EFECTIVO", "amount": 50, "received": 50, "cambio": 0, "displayAmount": 50, "type": null, "id": 1774577436494}]	70	4	1
2527	V4550	212	2026-03-27 02:18:00.817605	PAID	6	[{"method": "EFECTIVO", "amount": 212, "received": 212, "cambio": 0, "displayAmount": 212, "type": null, "id": 1774577932260}]	70	9	1
2528	V2843	105	2026-03-27 02:19:19.638252	PAID	3	[{"method": "EFECTIVO", "amount": 105, "received": 105, "cambio": 0, "displayAmount": 105, "type": null, "id": 1774577991717}]	70	24	1
2531	V5851	85	2026-03-27 02:24:08.944657	PAID	3	[{"method": "EFECTIVO", "amount": 85, "received": 100, "cambio": 15, "displayAmount": 100, "type": null, "id": 1774578267816}]	70	13	1
2532	V4013	22	2026-03-27 02:24:10.492973	PAID	5	[{"method": "EFECTIVO", "amount": 22, "received": 22, "cambio": 0, "displayAmount": 22, "type": null, "id": 1774578355471}]	70	4	1
2534	V6175	71	2026-03-27 02:27:01.153544	PAID	3	[{"method": "EFECTIVO", "amount": 71, "received": 71, "cambio": 0, "displayAmount": 71, "type": null, "id": 1774578448942}]	70	13	1
2535	V2484	79	2026-03-27 02:30:33.625131	PAID	3	[{"method": "EFECTIVO", "amount": 79, "displayAmount": 200, "type": null, "id": 1774623721048, "received": 200, "cambio": 121}]	71	17	20
2541	V2833	29	2026-03-27 02:37:49.148653	PAID	5	[{"method": "EFECTIVO", "amount": 29, "received": 50, "cambio": 21, "displayAmount": 50, "type": null, "id": 1774579099035}]	70	4	1
2544	V2315	58	2026-03-27 02:38:43.021303	PAID	5	[{"method": "EFECTIVO", "amount": 58, "received": 100, "cambio": 42, "displayAmount": 100, "type": null, "id": 1774579168764}]	70	4	1
2545	V1888	33	2026-03-27 02:39:35.614335	PAID	6	[{"method": "EFECTIVO", "amount": 33, "received": 50, "cambio": 17, "displayAmount": 50, "type": null, "id": 1774579193655}]	70	24	1
2547	V1925	32	2026-03-27 02:55:27.7132	PAID	3	[{"method": "EFECTIVO", "amount": 32, "received": 32, "cambio": 0, "displayAmount": 32, "type": null, "id": 1774580687025}]	70	24	1
2548	V8357	51	2026-03-27 02:55:50.851642	PAID	3	[{"method": "EFECTIVO", "amount": 51, "received": 51, "cambio": 0, "displayAmount": 51, "type": null, "id": 1774580742678}]	70	24	1
2553	V8880	69	2026-03-27 03:05:08.880084	PAID	3	[{"method": "EFECTIVO", "amount": 69, "received": 69, "cambio": 0, "displayAmount": 69, "type": null, "id": 1774580786725}]	70	24	1
2555	V7365	19	2026-03-27 03:06:16.053702	PAID	3	[{"method": "EFECTIVO", "amount": 19, "received": 19, "cambio": 0, "displayAmount": 19, "type": null, "id": 1774580794525}]	70	24	1
2554	V4292	76	2026-03-27 03:05:45.215022	PAID	5	[{"method": "EFECTIVO", "amount": 76, "received": 76, "cambio": 0, "displayAmount": 76, "type": null, "id": 1774580837825}]	70	4	1
2190	V5845	56	2026-03-26 01:36:48.630277	PAID	6	[{"method": "EFECTIVO", "amount": 56, "received": 100, "cambio": 44, "displayAmount": 100, "type": null, "id": 1774489072761}]	35	9	3
2179	V6234	25	2026-03-26 01:26:33.238398	PAID	3	[{"method": "EFECTIVO", "amount": 25, "received": 25, "cambio": 0, "displayAmount": 25, "type": null, "id": 1774489200695}]	35	24	3
2201	V6594	93	2026-03-26 01:44:13.152482	PAID	5	[{"method": "EFECTIVO", "amount": 93, "received": 100, "cambio": 7, "displayAmount": 100, "type": null, "id": 1774489489226}]	35	4	3
2202	V3834	107	2026-03-26 01:44:24.050053	PAID	6	[{"method": "EFECTIVO", "amount": 107, "received": 500, "cambio": 393, "displayAmount": 500, "type": null, "id": 1774489509580}]	35	9	3
2203	V2056	124	2026-03-26 01:48:06.243769	PAID	3	[{"method": "EFECTIVO", "amount": 124, "received": 200, "cambio": 76, "displayAmount": 200, "type": null, "id": 1774489695481}]	35	8	3
2204	V4410	97	2026-03-26 01:48:10.238368	PAID	5	[{"method": "EFECTIVO", "amount": 97, "received": 100, "cambio": 3, "displayAmount": 100, "type": null, "id": 1774489720513}]	35	4	3
2206	V4639	93	2026-03-26 01:51:18.062985	PAID	3	[{"method": "EFECTIVO", "amount": 93, "received": 500, "cambio": 407, "displayAmount": 500, "type": null, "id": 1774489886262}]	35	8	3
2218	V4986	57	2026-03-26 02:05:45.773751	PAID	5	[{"method": "EFECTIVO", "amount": 57, "received": 60, "cambio": 3, "displayAmount": 60, "type": null, "id": 1774490771799}]	35	18	3
2220	V3842	153	2026-03-26 02:10:16.794072	PAID	3	[{"method": "EFECTIVO", "amount": 153, "received": 503, "cambio": 350, "displayAmount": 503, "type": null, "id": 1774491028654}]	35	24	3
2222	V9361	72	2026-03-26 02:12:09.740896	PAID	3	[{"method": "EFECTIVO", "amount": 72, "received": 100, "cambio": 28, "displayAmount": 100, "type": null, "id": 1774491143086}]	35	24	3
2224	V4899	70	2026-03-26 02:13:22.627492	PAID	3	[{"method": "EFECTIVO", "amount": 70, "received": 200, "cambio": 130, "displayAmount": 200, "type": null, "id": 1774491226496}]	35	24	3
2228	V5501	39	2026-03-26 02:18:01.089822	PAID	5	[{"method": "EFECTIVO", "amount": 39, "received": 100, "cambio": 61, "displayAmount": 100, "type": null, "id": 1774491510071}]	35	9	3
2233	V3608	17	2026-03-26 02:22:15.538537	PAID	5	[{"method": "EFECTIVO", "amount": 17, "received": 17, "cambio": 0, "displayAmount": 17, "type": null, "id": 1774491784787}]	35	4	3
2221	V9530	34	2026-03-26 02:11:03.359371	PAID	3	[{"method": "EFECTIVO", "amount": 34, "received": 34, "cambio": 0, "displayAmount": 34, "type": null, "id": 1774492013406}]	35	24	3
2241	V1564	63	2026-03-26 02:30:03.327363	PAID	3	[{"method": "EFECTIVO", "amount": 63, "received": 500, "cambio": 437, "displayAmount": 500, "type": null, "id": 1774492212632}]	35	24	3
2525	V8013	77	2026-03-27 02:16:32.294718	PAID	3	[{"method": "EFECTIVO", "amount": 77, "received": 100, "cambio": 23, "displayAmount": 100, "type": null, "id": 1774577819004}]	70	24	1
2400	V3950	83	2026-03-26 23:27:53.329647	PAID	5	[{"method": "EFECTIVO", "amount": 83, "received": 83, "cambio": 0, "displayAmount": 83, "type": null, "id": 1774577963647}]	70	9	1
2529	V9036	62	2026-03-27 02:20:10.310008	PAID	5	[{"method": "EFECTIVO", "amount": 62, "received": 200, "cambio": 138, "displayAmount": 200, "type": null, "id": 1774578031075}]	70	13	1
2539	V9277	44	2026-03-27 02:36:04.520823	PAID	3	[{"method": "EFECTIVO", "amount": 44, "received": 200, "cambio": 156, "displayAmount": 200, "type": null, "id": 1774578991946}]	70	13	1
2543	V8406	99	2026-03-27 02:38:21.721938	PAID	3	[{"method": "EFECTIVO", "amount": 99, "received": 100, "cambio": 1, "displayAmount": 100, "type": null, "id": 1774579148979}]	70	13	1
2546	V7390	63	2026-03-27 02:45:14.738746	PAID	5	[{"method": "EFECTIVO", "amount": 63, "displayAmount": 63, "type": null, "id": 1774579526677, "received": 63, "cambio": 0}]	70	13	1
2549	V8539	103	2026-03-27 02:57:30.890309	PAID	3	[{"method": "EFECTIVO", "amount": 103, "received": 103, "cambio": 0, "displayAmount": 103, "type": null, "id": 1774580758009}]	70	24	1
2551	V3961	145	2026-03-27 02:59:55.936505	PAID	5	[{"method": "EFECTIVO", "amount": 145, "received": 145, "cambio": 0, "displayAmount": 145, "type": null, "id": 1774580823952}]	70	4	1
2556	V7636	103	2026-03-27 03:13:13.183922	PAID	3	[{"method": "EFECTIVO", "amount": 103, "received": 500, "cambio": 397, "displayAmount": 500, "type": null, "id": 1774581206636}]	70	24	1
2619	V3690	41	2026-03-27 14:54:25.344211	PAID	5	[{"method": "EFECTIVO", "amount": 41, "received": 100, "cambio": 59, "displayAmount": 100, "type": null, "id": 1774623288633}]	71	15	20
2211	V4451	62	2026-03-26 01:54:22.674291	PAID	6	[{"method": "EFECTIVO", "amount": 62, "received": 62, "cambio": 0, "displayAmount": 62, "type": null, "id": 1774581475674}]	70	4	1
2557	V3079	108	2026-03-27 03:25:26.394427	PAID	3	[{"method": "EFECTIVO", "amount": 108, "displayAmount": 120, "type": null, "id": 1774581938676, "received": 120, "cambio": 12}]	70	24	1
2561	V7572	112	2026-03-27 03:30:17.071456	PAID	3	[{"method": "EFECTIVO", "amount": 112, "received": 150, "cambio": 38, "displayAmount": 150, "type": null, "id": 1774582227010}]	70	24	1
2562	V3788	57	2026-03-27 03:31:02.291545	PAID	3	[{"method": "EFECTIVO", "amount": 57, "received": 100, "cambio": 43, "displayAmount": 100, "type": null, "id": 1774582273805}]	70	24	1
2616	V7142	52	2026-03-27 14:48:37.646458	PAID	3	[{"method": "EFECTIVO", "amount": 52, "displayAmount": 55, "type": null, "id": 1774622935404, "received": 55, "cambio": 3}]	71	17	20
2617	V6108	35	2026-03-27 14:48:38.313323	PAID	5	[{"method": "EFECTIVO", "amount": 35, "displayAmount": 500, "type": null, "id": 1774622984831, "received": 500, "cambio": 465}]	71	15	20
2624	V3243	29	2026-03-27 15:03:37.783808	PAID	5	[{"method": "EFECTIVO", "amount": 29, "displayAmount": 29, "type": null, "id": 1774623826187, "received": 29, "cambio": 0}]	71	15	20
2625	V8248	31	2026-03-27 15:04:01.182158	PAID	3	[{"method": "EFECTIVO", "amount": 31, "displayAmount": 50, "type": null, "id": 1774623857384, "received": 50, "cambio": 19}]	71	17	20
2626	V6648	49	2026-03-27 15:08:59.093272	PAID	5	[{"method": "EFECTIVO", "amount": 49, "displayAmount": 200, "type": null, "id": 1774624213693, "received": 200, "cambio": 151}]	71	15	20
2621	V2984	3	2026-03-27 15:01:05.1012	PAID	5	[{"method": "EFECTIVO", "amount": 3, "received": 3, "cambio": 0, "displayAmount": 3, "type": null, "id": 1774624633663}]	71	15	20
2629	V1788	70	2026-03-27 15:11:56.693596	PAID	4	[{"method": "EFECTIVO", "amount": 70, "displayAmount": 100, "type": null, "id": 1774624649195, "received": 100, "cambio": 30}]	71	16	20
2633	V7118	116	2026-03-27 15:16:57.934563	PAID	3	[{"method": "EFECTIVO", "amount": 116, "displayAmount": 150, "type": null, "id": 1774624685372, "received": 150, "cambio": 34}]	71	15	20
\.


--
-- Name: cash_movements_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.cash_movements_id_seq', 20, true);


--
-- Name: cash_sessions_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.cash_sessions_id_seq', 71, true);


--
-- Name: categories_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.categories_id_seq', 17, true);


--
-- Name: employees_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.employees_id_seq', 33, true);


--
-- Name: products_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.products_id_seq', 350, true);


--
-- Name: security_profiles_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.security_profiles_id_seq', 5, true);


--
-- Name: system_settings_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.system_settings_id_seq', 3, true);


--
-- Name: terminal_sessions_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.terminal_sessions_id_seq', 6, true);


--
-- Name: ticket_items_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.ticket_items_id_seq', 31562, true);


--
-- Name: tickets_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.tickets_id_seq', 2663, true);


--
-- Name: alembic_version alembic_version_pkc; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.alembic_version
    ADD CONSTRAINT alembic_version_pkc PRIMARY KEY (version_num);


--
-- Name: cash_movements cash_movements_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cash_movements
    ADD CONSTRAINT cash_movements_pkey PRIMARY KEY (id);


--
-- Name: cash_sessions cash_sessions_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cash_sessions
    ADD CONSTRAINT cash_sessions_pkey PRIMARY KEY (id);


--
-- Name: categories categories_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.categories
    ADD CONSTRAINT categories_pkey PRIMARY KEY (id);


--
-- Name: employees employees_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.employees
    ADD CONSTRAINT employees_pkey PRIMARY KEY (id);


--
-- Name: products products_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.products
    ADD CONSTRAINT products_pkey PRIMARY KEY (id);


--
-- Name: security_profiles security_profiles_name_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.security_profiles
    ADD CONSTRAINT security_profiles_name_key UNIQUE (name);


--
-- Name: security_profiles security_profiles_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.security_profiles
    ADD CONSTRAINT security_profiles_pkey PRIMARY KEY (id);


--
-- Name: system_settings system_settings_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.system_settings
    ADD CONSTRAINT system_settings_pkey PRIMARY KEY (id);


--
-- Name: terminal_sessions terminal_sessions_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.terminal_sessions
    ADD CONSTRAINT terminal_sessions_pkey PRIMARY KEY (id);


--
-- Name: ticket_items ticket_items_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ticket_items
    ADD CONSTRAINT ticket_items_pkey PRIMARY KEY (id);


--
-- Name: tickets tickets_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tickets
    ADD CONSTRAINT tickets_pkey PRIMARY KEY (id);


--
-- Name: ix_cash_movements_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ix_cash_movements_id ON public.cash_movements USING btree (id);


--
-- Name: ix_cash_sessions_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ix_cash_sessions_id ON public.cash_sessions USING btree (id);


--
-- Name: ix_cash_sessions_terminal_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ix_cash_sessions_terminal_id ON public.cash_sessions USING btree (terminal_id);


--
-- Name: ix_categories_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ix_categories_id ON public.categories USING btree (id);


--
-- Name: ix_categories_name; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX ix_categories_name ON public.categories USING btree (name);


--
-- Name: ix_employees_employee_code; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX ix_employees_employee_code ON public.employees USING btree (employee_code);


--
-- Name: ix_employees_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ix_employees_id ON public.employees USING btree (id);


--
-- Name: ix_products_barcode; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX ix_products_barcode ON public.products USING btree (barcode);


--
-- Name: ix_products_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ix_products_id ON public.products USING btree (id);


--
-- Name: ix_products_name; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ix_products_name ON public.products USING btree (name);


--
-- Name: ix_products_sku; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX ix_products_sku ON public.products USING btree (sku);


--
-- Name: ix_security_profiles_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ix_security_profiles_id ON public.security_profiles USING btree (id);


--
-- Name: ix_system_settings_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ix_system_settings_id ON public.system_settings USING btree (id);


--
-- Name: ix_system_settings_key; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX ix_system_settings_key ON public.system_settings USING btree (key);


--
-- Name: ix_terminal_sessions_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ix_terminal_sessions_id ON public.terminal_sessions USING btree (id);


--
-- Name: ix_terminal_sessions_terminal_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ix_terminal_sessions_terminal_id ON public.terminal_sessions USING btree (terminal_id);


--
-- Name: ix_ticket_items_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ix_ticket_items_id ON public.ticket_items USING btree (id);


--
-- Name: ix_tickets_account_num; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX ix_tickets_account_num ON public.tickets USING btree (account_num);


--
-- Name: ix_tickets_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ix_tickets_id ON public.tickets USING btree (id);


--
-- Name: cash_movements cash_movements_cash_session_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cash_movements
    ADD CONSTRAINT cash_movements_cash_session_id_fkey FOREIGN KEY (cash_session_id) REFERENCES public.cash_sessions(id);


--
-- Name: cash_sessions cash_sessions_employee_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cash_sessions
    ADD CONSTRAINT cash_sessions_employee_id_fkey FOREIGN KEY (employee_id) REFERENCES public.employees(id);


--
-- Name: employees employees_profile_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.employees
    ADD CONSTRAINT employees_profile_id_fkey FOREIGN KEY (profile_id) REFERENCES public.security_profiles(id);


--
-- Name: products products_category_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.products
    ADD CONSTRAINT products_category_id_fkey FOREIGN KEY (category_id) REFERENCES public.categories(id);


--
-- Name: ticket_items ticket_items_product_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ticket_items
    ADD CONSTRAINT ticket_items_product_id_fkey FOREIGN KEY (product_id) REFERENCES public.products(id);


--
-- Name: ticket_items ticket_items_ticket_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ticket_items
    ADD CONSTRAINT ticket_items_ticket_id_fkey FOREIGN KEY (ticket_id) REFERENCES public.tickets(id);


--
-- Name: tickets tickets_captured_by_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tickets
    ADD CONSTRAINT tickets_captured_by_id_fkey FOREIGN KEY (captured_by_id) REFERENCES public.employees(id);


--
-- Name: tickets tickets_cash_session_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tickets
    ADD CONSTRAINT tickets_cash_session_id_fkey FOREIGN KEY (cash_session_id) REFERENCES public.cash_sessions(id);


--
-- Name: tickets tickets_cashed_by_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tickets
    ADD CONSTRAINT tickets_cashed_by_id_fkey FOREIGN KEY (cashed_by_id) REFERENCES public.employees(id);


--
-- Name: tickets tickets_session_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tickets
    ADD CONSTRAINT tickets_session_id_fkey FOREIGN KEY (session_id) REFERENCES public.terminal_sessions(id);


--
-- PostgreSQL database dump complete
--

\unrestrict hozNg61Hxmi1Say2C41r7a7PzPG6JxAxSrYmwzEz7OufoXNEQgEwfAd8RTgQ1fA

