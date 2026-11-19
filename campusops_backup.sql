--
-- PostgreSQL database dump
--

\restrict vM30n2jpFheu0ULZ6PA6ha33Fz2fVNpxVe3jiaPdp2KpZrP1InB35nNwqasEpwh

-- Dumped from database version 15.19 (Debian 15.19-1.pgdg13+2)
-- Dumped by pg_dump version 15.19 (Debian 15.19-1.pgdg13+2)

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

--
-- Name: uuid-ossp; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS "uuid-ossp" WITH SCHEMA public;


--
-- Name: EXTENSION "uuid-ossp"; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION "uuid-ossp" IS 'generate universally unique identifiers (UUIDs)';


--
-- Name: asset_status; Type: TYPE; Schema: public; Owner: campusops_user
--

CREATE TYPE public.asset_status AS ENUM (
    'WORKING',
    'UNDER_MAINTENANCE',
    'BROKEN',
    'REPLACED',
    'DISPOSED'
);


ALTER TYPE public.asset_status OWNER TO campusops_user;

--
-- Name: location_type; Type: TYPE; Schema: public; Owner: campusops_user
--

CREATE TYPE public.location_type AS ENUM (
    'CLASSROOM',
    'LABORATORY',
    'HOSTEL',
    'OFFICE',
    'CANTEEN',
    'LIBRARY',
    'GARDEN',
    'PARKING',
    'CORRIDOR',
    'WASHROOM',
    'OTHER'
);


ALTER TYPE public.location_type OWNER TO campusops_user;

--
-- Name: notification_channel; Type: TYPE; Schema: public; Owner: campusops_user
--

CREATE TYPE public.notification_channel AS ENUM (
    'EMAIL',
    'TELEGRAM',
    'WHATSAPP',
    'IN_APP'
);


ALTER TYPE public.notification_channel OWNER TO campusops_user;

--
-- Name: notification_status; Type: TYPE; Schema: public; Owner: campusops_user
--

CREATE TYPE public.notification_status AS ENUM (
    'PENDING',
    'SENT',
    'FAILED'
);


ALTER TYPE public.notification_status OWNER TO campusops_user;

--
-- Name: ticket_category; Type: TYPE; Schema: public; Owner: campusops_user
--

CREATE TYPE public.ticket_category AS ENUM (
    'IT',
    'ELECTRICAL',
    'PLUMBING',
    'CIVIL',
    'HOUSEKEEPING',
    'SECURITY',
    'CANTEEN',
    'HORTICULTURE',
    'OTHER'
);


ALTER TYPE public.ticket_category OWNER TO campusops_user;

--
-- Name: ticket_priority; Type: TYPE; Schema: public; Owner: campusops_user
--

CREATE TYPE public.ticket_priority AS ENUM (
    'LOW',
    'MEDIUM',
    'HIGH',
    'CRITICAL'
);


ALTER TYPE public.ticket_priority OWNER TO campusops_user;

--
-- Name: ticket_status; Type: TYPE; Schema: public; Owner: campusops_user
--

CREATE TYPE public.ticket_status AS ENUM (
    'OPEN',
    'AI_PROCESSED',
    'ASSIGNED',
    'ACCEPTED',
    'IN_PROGRESS',
    'RESOLVED',
    'CLOSED',
    'CANCELLED',
    'REJECTED',
    'ESCALATED'
);


ALTER TYPE public.ticket_status OWNER TO campusops_user;

--
-- Name: user_role; Type: TYPE; Schema: public; Owner: campusops_user
--

CREATE TYPE public.user_role AS ENUM (
    'STUDENT',
    'TECHNICIAN',
    'SUPERVISOR',
    'ADMIN'
);


ALTER TYPE public.user_role OWNER TO campusops_user;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: assets; Type: TABLE; Schema: public; Owner: campusops_user
--

CREATE TABLE public.assets (
    id integer NOT NULL,
    asset_code character varying(50) NOT NULL,
    name character varying(150) NOT NULL,
    category character varying(100),
    location_id integer,
    department_id integer,
    purchase_date date,
    warranty_end date,
    status public.asset_status DEFAULT 'WORKING'::public.asset_status,
    last_maintenance date,
    notes text,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    updated_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE public.assets OWNER TO campusops_user;

--
-- Name: assets_id_seq; Type: SEQUENCE; Schema: public; Owner: campusops_user
--

CREATE SEQUENCE public.assets_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.assets_id_seq OWNER TO campusops_user;

--
-- Name: assets_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: campusops_user
--

ALTER SEQUENCE public.assets_id_seq OWNED BY public.assets.id;


--
-- Name: audit_logs; Type: TABLE; Schema: public; Owner: campusops_user
--

CREATE TABLE public.audit_logs (
    id integer NOT NULL,
    user_id integer,
    action character varying(100) NOT NULL,
    entity character varying(100) NOT NULL,
    entity_id integer,
    old_value jsonb,
    new_value jsonb,
    ip_address character varying(50),
    "timestamp" timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE public.audit_logs OWNER TO campusops_user;

--
-- Name: audit_logs_id_seq; Type: SEQUENCE; Schema: public; Owner: campusops_user
--

CREATE SEQUENCE public.audit_logs_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.audit_logs_id_seq OWNER TO campusops_user;

--
-- Name: audit_logs_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: campusops_user
--

ALTER SEQUENCE public.audit_logs_id_seq OWNED BY public.audit_logs.id;


--
-- Name: departments; Type: TABLE; Schema: public; Owner: campusops_user
--

CREATE TABLE public.departments (
    id integer NOT NULL,
    name character varying(100) NOT NULL,
    description text,
    contact_email character varying(150),
    contact_phone character varying(20),
    sla_hours_low integer DEFAULT 48,
    sla_hours_medium integer DEFAULT 24,
    sla_hours_high integer DEFAULT 8,
    sla_hours_critical integer DEFAULT 2,
    is_active boolean DEFAULT true,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE public.departments OWNER TO campusops_user;

--
-- Name: departments_id_seq; Type: SEQUENCE; Schema: public; Owner: campusops_user
--

CREATE SEQUENCE public.departments_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.departments_id_seq OWNER TO campusops_user;

--
-- Name: departments_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: campusops_user
--

ALTER SEQUENCE public.departments_id_seq OWNED BY public.departments.id;


--
-- Name: feedback; Type: TABLE; Schema: public; Owner: campusops_user
--

CREATE TABLE public.feedback (
    id integer NOT NULL,
    ticket_id integer NOT NULL,
    given_by integer NOT NULL,
    rating integer,
    comment text,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT feedback_rating_check CHECK (((rating >= 1) AND (rating <= 5)))
);


ALTER TABLE public.feedback OWNER TO campusops_user;

--
-- Name: feedback_id_seq; Type: SEQUENCE; Schema: public; Owner: campusops_user
--

CREATE SEQUENCE public.feedback_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.feedback_id_seq OWNER TO campusops_user;

--
-- Name: feedback_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: campusops_user
--

ALTER SEQUENCE public.feedback_id_seq OWNED BY public.feedback.id;


--
-- Name: locations; Type: TABLE; Schema: public; Owner: campusops_user
--

CREATE TABLE public.locations (
    id integer NOT NULL,
    building character varying(100) NOT NULL,
    floor character varying(20),
    room character varying(50),
    location_type public.location_type DEFAULT 'OTHER'::public.location_type,
    description text,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE public.locations OWNER TO campusops_user;

--
-- Name: locations_id_seq; Type: SEQUENCE; Schema: public; Owner: campusops_user
--

CREATE SEQUENCE public.locations_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.locations_id_seq OWNER TO campusops_user;

--
-- Name: locations_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: campusops_user
--

ALTER SEQUENCE public.locations_id_seq OWNED BY public.locations.id;


--
-- Name: notifications; Type: TABLE; Schema: public; Owner: campusops_user
--

CREATE TABLE public.notifications (
    id integer NOT NULL,
    user_id integer,
    ticket_id integer,
    channel public.notification_channel NOT NULL,
    message text NOT NULL,
    status public.notification_status DEFAULT 'PENDING'::public.notification_status,
    sent_at timestamp without time zone,
    error_message text,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE public.notifications OWNER TO campusops_user;

--
-- Name: notifications_id_seq; Type: SEQUENCE; Schema: public; Owner: campusops_user
--

CREATE SEQUENCE public.notifications_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.notifications_id_seq OWNER TO campusops_user;

--
-- Name: notifications_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: campusops_user
--

ALTER SEQUENCE public.notifications_id_seq OWNED BY public.notifications.id;


--
-- Name: ticket_history; Type: TABLE; Schema: public; Owner: campusops_user
--

CREATE TABLE public.ticket_history (
    id integer NOT NULL,
    ticket_id integer NOT NULL,
    old_status public.ticket_status,
    new_status public.ticket_status NOT NULL,
    changed_by integer,
    comment text,
    "timestamp" timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE public.ticket_history OWNER TO campusops_user;

--
-- Name: ticket_history_id_seq; Type: SEQUENCE; Schema: public; Owner: campusops_user
--

CREATE SEQUENCE public.ticket_history_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.ticket_history_id_seq OWNER TO campusops_user;

--
-- Name: ticket_history_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: campusops_user
--

ALTER SEQUENCE public.ticket_history_id_seq OWNED BY public.ticket_history.id;


--
-- Name: tickets; Type: TABLE; Schema: public; Owner: campusops_user
--

CREATE TABLE public.tickets (
    id integer NOT NULL,
    ticket_number character varying(20) NOT NULL,
    title character varying(255) NOT NULL,
    description text NOT NULL,
    category public.ticket_category,
    priority public.ticket_priority DEFAULT 'MEDIUM'::public.ticket_priority,
    status public.ticket_status DEFAULT 'OPEN'::public.ticket_status,
    reported_by integer NOT NULL,
    location_id integer,
    asset_id integer,
    assigned_department integer,
    assigned_to integer,
    ai_category public.ticket_category,
    ai_category_confidence double precision,
    ai_priority public.ticket_priority,
    ai_priority_confidence double precision,
    ai_processed_at timestamp without time zone,
    is_duplicate boolean DEFAULT false,
    duplicate_of integer,
    duplicate_similarity double precision,
    image_path character varying(500),
    due_at timestamp without time zone,
    escalation_level integer DEFAULT 0,
    resolution_notes text,
    resolved_at timestamp without time zone,
    closed_at timestamp without time zone,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    updated_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE public.tickets OWNER TO campusops_user;

--
-- Name: tickets_id_seq; Type: SEQUENCE; Schema: public; Owner: campusops_user
--

CREATE SEQUENCE public.tickets_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.tickets_id_seq OWNER TO campusops_user;

--
-- Name: tickets_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: campusops_user
--

ALTER SEQUENCE public.tickets_id_seq OWNED BY public.tickets.id;


--
-- Name: users; Type: TABLE; Schema: public; Owner: campusops_user
--

CREATE TABLE public.users (
    id integer NOT NULL,
    name character varying(150) NOT NULL,
    email character varying(150) NOT NULL,
    password_hash character varying(255) NOT NULL,
    role public.user_role DEFAULT 'STUDENT'::public.user_role NOT NULL,
    department_id integer,
    phone character varying(20),
    student_id character varying(50),
    is_active boolean DEFAULT true,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    updated_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE public.users OWNER TO campusops_user;

--
-- Name: users_id_seq; Type: SEQUENCE; Schema: public; Owner: campusops_user
--

CREATE SEQUENCE public.users_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.users_id_seq OWNER TO campusops_user;

--
-- Name: users_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: campusops_user
--

ALTER SEQUENCE public.users_id_seq OWNED BY public.users.id;


--
-- Name: assets id; Type: DEFAULT; Schema: public; Owner: campusops_user
--

ALTER TABLE ONLY public.assets ALTER COLUMN id SET DEFAULT nextval('public.assets_id_seq'::regclass);


--
-- Name: audit_logs id; Type: DEFAULT; Schema: public; Owner: campusops_user
--

ALTER TABLE ONLY public.audit_logs ALTER COLUMN id SET DEFAULT nextval('public.audit_logs_id_seq'::regclass);


--
-- Name: departments id; Type: DEFAULT; Schema: public; Owner: campusops_user
--

ALTER TABLE ONLY public.departments ALTER COLUMN id SET DEFAULT nextval('public.departments_id_seq'::regclass);


--
-- Name: feedback id; Type: DEFAULT; Schema: public; Owner: campusops_user
--

ALTER TABLE ONLY public.feedback ALTER COLUMN id SET DEFAULT nextval('public.feedback_id_seq'::regclass);


--
-- Name: locations id; Type: DEFAULT; Schema: public; Owner: campusops_user
--

ALTER TABLE ONLY public.locations ALTER COLUMN id SET DEFAULT nextval('public.locations_id_seq'::regclass);


--
-- Name: notifications id; Type: DEFAULT; Schema: public; Owner: campusops_user
--

ALTER TABLE ONLY public.notifications ALTER COLUMN id SET DEFAULT nextval('public.notifications_id_seq'::regclass);


--
-- Name: ticket_history id; Type: DEFAULT; Schema: public; Owner: campusops_user
--

ALTER TABLE ONLY public.ticket_history ALTER COLUMN id SET DEFAULT nextval('public.ticket_history_id_seq'::regclass);


--
-- Name: tickets id; Type: DEFAULT; Schema: public; Owner: campusops_user
--

ALTER TABLE ONLY public.tickets ALTER COLUMN id SET DEFAULT nextval('public.tickets_id_seq'::regclass);


--
-- Name: users id; Type: DEFAULT; Schema: public; Owner: campusops_user
--

ALTER TABLE ONLY public.users ALTER COLUMN id SET DEFAULT nextval('public.users_id_seq'::regclass);


--
-- Data for Name: assets; Type: TABLE DATA; Schema: public; Owner: campusops_user
--

COPY public.assets (id, asset_code, name, category, location_id, department_id, purchase_date, warranty_end, status, last_maintenance, notes, created_at, updated_at) FROM stdin;
\.


--
-- Data for Name: audit_logs; Type: TABLE DATA; Schema: public; Owner: campusops_user
--

COPY public.audit_logs (id, user_id, action, entity, entity_id, old_value, new_value, ip_address, "timestamp") FROM stdin;
\.


--
-- Data for Name: departments; Type: TABLE DATA; Schema: public; Owner: campusops_user
--

COPY public.departments (id, name, description, contact_email, contact_phone, sla_hours_low, sla_hours_medium, sla_hours_high, sla_hours_critical, is_active, created_at) FROM stdin;
1	IT & Network	Handles WiFi, computers, projectors, servers and printers	it@campus.edu	9800000001	48	24	4	2	t	2026-09-24 09:52:01.096961
2	Electrical	Handles lights, fans, AC, power sockets, generator and wiring	electrical@campus.edu	9800000002	48	24	4	1	t	2026-09-24 09:52:01.096961
3	Plumbing	Handles water leaks, taps, toilets, drainage and water supply	plumbing@campus.edu	9800000003	48	24	6	2	t	2026-09-24 09:52:01.096961
4	Civil & Infrastructure	Handles wall cracks, broken doors/windows, floor and roof damage	civil@campus.edu	9800000004	48	24	8	4	t	2026-09-24 09:52:01.096961
5	Housekeeping	Handles cleaning, garbage, pest control and washroom hygiene	housekeeping@campus.edu	9800000005	48	12	4	3	t	2026-09-24 09:52:01.096961
6	Security	Handles gate, CCTV, access control and suspicious activity	security@campus.edu	9800000006	24	12	2	1	t	2026-09-24 09:52:01.096961
7	Canteen & Mess	Handles food quality, hygiene, equipment and water filters	canteen@campus.edu	9800000007	48	24	4	2	t	2026-09-24 09:52:01.096961
8	Horticulture	Handles garden, plants, outdoor areas and fallen trees	horticulture@campus.edu	9800000008	48	24	8	4	t	2026-09-24 09:52:01.096961
\.


--
-- Data for Name: feedback; Type: TABLE DATA; Schema: public; Owner: campusops_user
--

COPY public.feedback (id, ticket_id, given_by, rating, comment, created_at) FROM stdin;
\.


--
-- Data for Name: locations; Type: TABLE DATA; Schema: public; Owner: campusops_user
--

COPY public.locations (id, building, floor, room, location_type, description, created_at) FROM stdin;
1	Main Building	Ground Floor	Room 101	CLASSROOM	\N	2026-09-24 09:52:01.096961
2	Main Building	Ground Floor	Room 102	CLASSROOM	\N	2026-09-24 09:52:01.096961
3	Main Building	1st Floor	Room 201	CLASSROOM	\N	2026-09-24 09:52:01.096961
4	Main Building	1st Floor	Room 204	CLASSROOM	\N	2026-09-24 09:52:01.096961
5	Main Building	2nd Floor	Room 301	CLASSROOM	\N	2026-09-24 09:52:01.096961
6	Computer Lab Block	Ground Floor	Lab 1	LABORATORY	\N	2026-09-24 09:52:01.096961
7	Computer Lab Block	Ground Floor	Lab 2	LABORATORY	\N	2026-09-24 09:52:01.096961
8	Computer Lab Block	1st Floor	Lab 3	LABORATORY	\N	2026-09-24 09:52:01.096961
9	Science Block	Ground Floor	Physics Lab	LABORATORY	\N	2026-09-24 09:52:01.096961
10	Science Block	1st Floor	Chemistry Lab	LABORATORY	\N	2026-09-24 09:52:01.096961
11	Hostel Block A	Ground Floor	Common Room	HOSTEL	\N	2026-09-24 09:52:01.096961
12	Hostel Block A	1st Floor	Room A-101	HOSTEL	\N	2026-09-24 09:52:01.096961
13	Hostel Block B	Ground Floor	Common Room	HOSTEL	\N	2026-09-24 09:52:01.096961
14	Hostel Block B	2nd Floor	Room B-201	HOSTEL	\N	2026-09-24 09:52:01.096961
15	Admin Block	Ground Floor	Principal Office	OFFICE	\N	2026-09-24 09:52:01.096961
16	Library	Ground Floor	Reading Hall	LIBRARY	\N	2026-09-24 09:52:01.096961
17	Canteen	Ground Floor	Main Canteen	CANTEEN	\N	2026-09-24 09:52:01.096961
18	Campus Ground	\N	Main Gate	OTHER	\N	2026-09-24 09:52:01.096961
19	Campus Ground	\N	Parking Area	PARKING	\N	2026-09-24 09:52:01.096961
20	Campus Ground	\N	Garden Area	GARDEN	\N	2026-09-24 09:52:01.096961
\.


--
-- Data for Name: notifications; Type: TABLE DATA; Schema: public; Owner: campusops_user
--

COPY public.notifications (id, user_id, ticket_id, channel, message, status, sent_at, error_message, created_at) FROM stdin;
\.


--
-- Data for Name: ticket_history; Type: TABLE DATA; Schema: public; Owner: campusops_user
--

COPY public.ticket_history (id, ticket_id, old_status, new_status, changed_by, comment, "timestamp") FROM stdin;
1	1	\N	OPEN	2	Ticket created	2026-09-26 09:58:21.167235
2	1	OPEN	ASSIGNED	2	Assigned to department 1	2026-09-26 10:10:39.901329
3	1	ASSIGNED	ACCEPTED	2	Ticket accepted by technician	2026-09-26 10:11:52.323152
4	1	ACCEPTED	IN_PROGRESS	2	Work started	2026-09-26 10:12:10.075368
5	1	IN_PROGRESS	RESOLVED	2	Resolved: WiFi router was restarted and reconfigured. Issue resolved.	2026-09-26 10:12:35.407636
6	2	\N	OPEN	2	Ticket created	2026-09-29 10:05:49.988343
\.


--
-- Data for Name: tickets; Type: TABLE DATA; Schema: public; Owner: campusops_user
--

COPY public.tickets (id, ticket_number, title, description, category, priority, status, reported_by, location_id, asset_id, assigned_department, assigned_to, ai_category, ai_category_confidence, ai_priority, ai_priority_confidence, ai_processed_at, is_duplicate, duplicate_of, duplicate_similarity, image_path, due_at, escalation_level, resolution_notes, resolved_at, closed_at, created_at, updated_at) FROM stdin;
1	TKT-0001	WiFi not working in Lab 3	The WiFi connection is completely down in Computer Lab 3. All students are affected.	IT	HIGH	RESOLVED	2	8	\N	1	2	\N	\N	\N	\N	\N	f	\N	\N	\N	2026-09-26 14:10:39.9207	0	WiFi router was restarted and reconfigured. Issue resolved.	2026-09-26 10:12:35.416475	\N	2026-09-26 09:58:21.077328	2026-09-26 10:12:35.407636
2	TKT-0002	AC not working in Hostel Block A	The AC in Hostel Block A common room has stopped working since yesterday.	ELECTRICAL	MEDIUM	OPEN	2	11	\N	\N	\N	\N	\N	\N	\N	\N	f	\N	\N	\N	\N	0	\N	\N	\N	2026-09-29 10:05:49.950519	2026-09-29 10:05:49.950519
\.


--
-- Data for Name: users; Type: TABLE DATA; Schema: public; Owner: campusops_user
--

COPY public.users (id, name, email, password_hash, role, department_id, phone, student_id, is_active, created_at, updated_at) FROM stdin;
1	Campus Admin	admin@campus.edu	$2b$12$placeholder_hash_change_this	ADMIN	\N	9800000000	\N	t	2026-09-24 09:52:01.096961	2026-09-24 09:52:01.096961
2	Krishnendu Adhikary	krishnendu@campus.edu	$2b$12$iK0X5EvwLGHTPLgwk/5ZfunGcHxTdPTAXYkHll7PPn0vJMTY9GWUy	ADMIN	\N	9564209924	CSPG/032/25	t	2026-09-26 09:11:27.679141	\N
3	Raju Technician	technician@campus.edu	$2b$12$iq3UFvAvUdHO2jV5ER81UuUxPQBEWYdI47Nc6WsC6K1h.u3EfpKz.	TECHNICIAN	\N	9800000002	\N	t	2026-09-29 10:00:15.21647	\N
4	Priya Supervisor	supervisor@campus.edu	$2b$12$6hFl4.Jx3XdLgQ9ZKjk0b.TSBcjhVN.O/45TxdF1hs1o2np0D/MMu	SUPERVISOR	1	9800000003	\N	t	2026-09-29 10:00:27.68717	\N
\.


--
-- Name: assets_id_seq; Type: SEQUENCE SET; Schema: public; Owner: campusops_user
--

SELECT pg_catalog.setval('public.assets_id_seq', 1, false);


--
-- Name: audit_logs_id_seq; Type: SEQUENCE SET; Schema: public; Owner: campusops_user
--

SELECT pg_catalog.setval('public.audit_logs_id_seq', 1, false);


--
-- Name: departments_id_seq; Type: SEQUENCE SET; Schema: public; Owner: campusops_user
--

SELECT pg_catalog.setval('public.departments_id_seq', 8, true);


--
-- Name: feedback_id_seq; Type: SEQUENCE SET; Schema: public; Owner: campusops_user
--

SELECT pg_catalog.setval('public.feedback_id_seq', 1, false);


--
-- Name: locations_id_seq; Type: SEQUENCE SET; Schema: public; Owner: campusops_user
--

SELECT pg_catalog.setval('public.locations_id_seq', 20, true);


--
-- Name: notifications_id_seq; Type: SEQUENCE SET; Schema: public; Owner: campusops_user
--

SELECT pg_catalog.setval('public.notifications_id_seq', 1, false);


--
-- Name: ticket_history_id_seq; Type: SEQUENCE SET; Schema: public; Owner: campusops_user
--

SELECT pg_catalog.setval('public.ticket_history_id_seq', 6, true);


--
-- Name: tickets_id_seq; Type: SEQUENCE SET; Schema: public; Owner: campusops_user
--

SELECT pg_catalog.setval('public.tickets_id_seq', 2, true);


--
-- Name: users_id_seq; Type: SEQUENCE SET; Schema: public; Owner: campusops_user
--

SELECT pg_catalog.setval('public.users_id_seq', 4, true);


--
-- Name: assets assets_asset_code_key; Type: CONSTRAINT; Schema: public; Owner: campusops_user
--

ALTER TABLE ONLY public.assets
    ADD CONSTRAINT assets_asset_code_key UNIQUE (asset_code);


--
-- Name: assets assets_pkey; Type: CONSTRAINT; Schema: public; Owner: campusops_user
--

ALTER TABLE ONLY public.assets
    ADD CONSTRAINT assets_pkey PRIMARY KEY (id);


--
-- Name: audit_logs audit_logs_pkey; Type: CONSTRAINT; Schema: public; Owner: campusops_user
--

ALTER TABLE ONLY public.audit_logs
    ADD CONSTRAINT audit_logs_pkey PRIMARY KEY (id);


--
-- Name: departments departments_name_key; Type: CONSTRAINT; Schema: public; Owner: campusops_user
--

ALTER TABLE ONLY public.departments
    ADD CONSTRAINT departments_name_key UNIQUE (name);


--
-- Name: departments departments_pkey; Type: CONSTRAINT; Schema: public; Owner: campusops_user
--

ALTER TABLE ONLY public.departments
    ADD CONSTRAINT departments_pkey PRIMARY KEY (id);


--
-- Name: feedback feedback_pkey; Type: CONSTRAINT; Schema: public; Owner: campusops_user
--

ALTER TABLE ONLY public.feedback
    ADD CONSTRAINT feedback_pkey PRIMARY KEY (id);


--
-- Name: feedback feedback_ticket_id_key; Type: CONSTRAINT; Schema: public; Owner: campusops_user
--

ALTER TABLE ONLY public.feedback
    ADD CONSTRAINT feedback_ticket_id_key UNIQUE (ticket_id);


--
-- Name: locations locations_pkey; Type: CONSTRAINT; Schema: public; Owner: campusops_user
--

ALTER TABLE ONLY public.locations
    ADD CONSTRAINT locations_pkey PRIMARY KEY (id);


--
-- Name: notifications notifications_pkey; Type: CONSTRAINT; Schema: public; Owner: campusops_user
--

ALTER TABLE ONLY public.notifications
    ADD CONSTRAINT notifications_pkey PRIMARY KEY (id);


--
-- Name: ticket_history ticket_history_pkey; Type: CONSTRAINT; Schema: public; Owner: campusops_user
--

ALTER TABLE ONLY public.ticket_history
    ADD CONSTRAINT ticket_history_pkey PRIMARY KEY (id);


--
-- Name: tickets tickets_pkey; Type: CONSTRAINT; Schema: public; Owner: campusops_user
--

ALTER TABLE ONLY public.tickets
    ADD CONSTRAINT tickets_pkey PRIMARY KEY (id);


--
-- Name: tickets tickets_ticket_number_key; Type: CONSTRAINT; Schema: public; Owner: campusops_user
--

ALTER TABLE ONLY public.tickets
    ADD CONSTRAINT tickets_ticket_number_key UNIQUE (ticket_number);


--
-- Name: users users_email_key; Type: CONSTRAINT; Schema: public; Owner: campusops_user
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key UNIQUE (email);


--
-- Name: users users_pkey; Type: CONSTRAINT; Schema: public; Owner: campusops_user
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id);


--
-- Name: idx_audit_logs_entity; Type: INDEX; Schema: public; Owner: campusops_user
--

CREATE INDEX idx_audit_logs_entity ON public.audit_logs USING btree (entity);


--
-- Name: idx_audit_logs_user_id; Type: INDEX; Schema: public; Owner: campusops_user
--

CREATE INDEX idx_audit_logs_user_id ON public.audit_logs USING btree (user_id);


--
-- Name: idx_notifications_user_id; Type: INDEX; Schema: public; Owner: campusops_user
--

CREATE INDEX idx_notifications_user_id ON public.notifications USING btree (user_id);


--
-- Name: idx_ticket_history_ticket_id; Type: INDEX; Schema: public; Owner: campusops_user
--

CREATE INDEX idx_ticket_history_ticket_id ON public.ticket_history USING btree (ticket_id);


--
-- Name: idx_tickets_assigned_department; Type: INDEX; Schema: public; Owner: campusops_user
--

CREATE INDEX idx_tickets_assigned_department ON public.tickets USING btree (assigned_department);


--
-- Name: idx_tickets_assigned_to; Type: INDEX; Schema: public; Owner: campusops_user
--

CREATE INDEX idx_tickets_assigned_to ON public.tickets USING btree (assigned_to);


--
-- Name: idx_tickets_category; Type: INDEX; Schema: public; Owner: campusops_user
--

CREATE INDEX idx_tickets_category ON public.tickets USING btree (category);


--
-- Name: idx_tickets_created_at; Type: INDEX; Schema: public; Owner: campusops_user
--

CREATE INDEX idx_tickets_created_at ON public.tickets USING btree (created_at);


--
-- Name: idx_tickets_priority; Type: INDEX; Schema: public; Owner: campusops_user
--

CREATE INDEX idx_tickets_priority ON public.tickets USING btree (priority);


--
-- Name: idx_tickets_reported_by; Type: INDEX; Schema: public; Owner: campusops_user
--

CREATE INDEX idx_tickets_reported_by ON public.tickets USING btree (reported_by);


--
-- Name: idx_tickets_status; Type: INDEX; Schema: public; Owner: campusops_user
--

CREATE INDEX idx_tickets_status ON public.tickets USING btree (status);


--
-- Name: assets assets_department_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: campusops_user
--

ALTER TABLE ONLY public.assets
    ADD CONSTRAINT assets_department_id_fkey FOREIGN KEY (department_id) REFERENCES public.departments(id) ON DELETE SET NULL;


--
-- Name: assets assets_location_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: campusops_user
--

ALTER TABLE ONLY public.assets
    ADD CONSTRAINT assets_location_id_fkey FOREIGN KEY (location_id) REFERENCES public.locations(id) ON DELETE SET NULL;


--
-- Name: audit_logs audit_logs_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: campusops_user
--

ALTER TABLE ONLY public.audit_logs
    ADD CONSTRAINT audit_logs_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE SET NULL;


--
-- Name: feedback feedback_given_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: campusops_user
--

ALTER TABLE ONLY public.feedback
    ADD CONSTRAINT feedback_given_by_fkey FOREIGN KEY (given_by) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: feedback feedback_ticket_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: campusops_user
--

ALTER TABLE ONLY public.feedback
    ADD CONSTRAINT feedback_ticket_id_fkey FOREIGN KEY (ticket_id) REFERENCES public.tickets(id) ON DELETE CASCADE;


--
-- Name: notifications notifications_ticket_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: campusops_user
--

ALTER TABLE ONLY public.notifications
    ADD CONSTRAINT notifications_ticket_id_fkey FOREIGN KEY (ticket_id) REFERENCES public.tickets(id) ON DELETE CASCADE;


--
-- Name: notifications notifications_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: campusops_user
--

ALTER TABLE ONLY public.notifications
    ADD CONSTRAINT notifications_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: ticket_history ticket_history_changed_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: campusops_user
--

ALTER TABLE ONLY public.ticket_history
    ADD CONSTRAINT ticket_history_changed_by_fkey FOREIGN KEY (changed_by) REFERENCES public.users(id) ON DELETE SET NULL;


--
-- Name: ticket_history ticket_history_ticket_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: campusops_user
--

ALTER TABLE ONLY public.ticket_history
    ADD CONSTRAINT ticket_history_ticket_id_fkey FOREIGN KEY (ticket_id) REFERENCES public.tickets(id) ON DELETE CASCADE;


--
-- Name: tickets tickets_asset_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: campusops_user
--

ALTER TABLE ONLY public.tickets
    ADD CONSTRAINT tickets_asset_id_fkey FOREIGN KEY (asset_id) REFERENCES public.assets(id) ON DELETE SET NULL;


--
-- Name: tickets tickets_assigned_department_fkey; Type: FK CONSTRAINT; Schema: public; Owner: campusops_user
--

ALTER TABLE ONLY public.tickets
    ADD CONSTRAINT tickets_assigned_department_fkey FOREIGN KEY (assigned_department) REFERENCES public.departments(id) ON DELETE SET NULL;


--
-- Name: tickets tickets_assigned_to_fkey; Type: FK CONSTRAINT; Schema: public; Owner: campusops_user
--

ALTER TABLE ONLY public.tickets
    ADD CONSTRAINT tickets_assigned_to_fkey FOREIGN KEY (assigned_to) REFERENCES public.users(id) ON DELETE SET NULL;


--
-- Name: tickets tickets_duplicate_of_fkey; Type: FK CONSTRAINT; Schema: public; Owner: campusops_user
--

ALTER TABLE ONLY public.tickets
    ADD CONSTRAINT tickets_duplicate_of_fkey FOREIGN KEY (duplicate_of) REFERENCES public.tickets(id) ON DELETE SET NULL;


--
-- Name: tickets tickets_location_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: campusops_user
--

ALTER TABLE ONLY public.tickets
    ADD CONSTRAINT tickets_location_id_fkey FOREIGN KEY (location_id) REFERENCES public.locations(id) ON DELETE SET NULL;


--
-- Name: tickets tickets_reported_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: campusops_user
--

ALTER TABLE ONLY public.tickets
    ADD CONSTRAINT tickets_reported_by_fkey FOREIGN KEY (reported_by) REFERENCES public.users(id) ON DELETE RESTRICT;


--
-- Name: users users_department_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: campusops_user
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_department_id_fkey FOREIGN KEY (department_id) REFERENCES public.departments(id) ON DELETE SET NULL;


--
-- PostgreSQL database dump complete
--

\unrestrict vM30n2jpFheu0ULZ6PA6ha33Fz2fVNpxVe3jiaPdp2KpZrP1InB35nNwqasEpwh

