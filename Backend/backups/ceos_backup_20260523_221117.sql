--
-- PostgreSQL database dump
--

\restrict ZpG5FmdKQke3cTXuewBiqGrdgVmYghcNqqJt2QoDHMk5wsxBXrjG0Mh51uvwI33

-- Dumped from database version 18.3
-- Dumped by pg_dump version 18.3

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET transaction_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: estadosolicitudenum; Type: TYPE; Schema: public; Owner: ceos
--

CREATE TYPE public.estadosolicitudenum AS ENUM (
    'PENDIENTE',
    'APROBADA',
    'RECHAZADA'
);


ALTER TYPE public.estadosolicitudenum OWNER TO ceos;

--
-- Name: roleenum; Type: TYPE; Schema: public; Owner: ceos
--

CREATE TYPE public.roleenum AS ENUM (
    'SUPERADMIN',
    'ADMIN',
    'INVENTARIO',
    'DOCTOR'
);


ALTER TYPE public.roleenum OWNER TO ceos;

--
-- Name: tipomovimientoenum; Type: TYPE; Schema: public; Owner: ceos
--

CREATE TYPE public.tipomovimientoenum AS ENUM (
    'ENTRADA',
    'SALIDA',
    'AJUSTE'
);


ALTER TYPE public.tipomovimientoenum OWNER TO ceos;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: gastos; Type: TABLE; Schema: public; Owner: ceos
--

CREATE TABLE public.gastos (
    id integer NOT NULL,
    concepto character varying(180) NOT NULL,
    monto numeric(12,2) NOT NULL,
    descripcion character varying(255),
    fecha timestamp with time zone DEFAULT now() NOT NULL,
    registrado_por_id integer NOT NULL
);


ALTER TABLE public.gastos OWNER TO ceos;

--
-- Name: gastos_id_seq; Type: SEQUENCE; Schema: public; Owner: ceos
--

CREATE SEQUENCE public.gastos_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.gastos_id_seq OWNER TO ceos;

--
-- Name: gastos_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: ceos
--

ALTER SEQUENCE public.gastos_id_seq OWNED BY public.gastos.id;


--
-- Name: materiales; Type: TABLE; Schema: public; Owner: ceos
--

CREATE TABLE public.materiales (
    id integer NOT NULL,
    nombre character varying(120) NOT NULL,
    categoria character varying(120) NOT NULL,
    stock_actual integer NOT NULL,
    stock_minimo integer NOT NULL,
    fecha_vencimiento date,
    fecha_alerta_vencimiento date
);


ALTER TABLE public.materiales OWNER TO ceos;

--
-- Name: materiales_id_seq; Type: SEQUENCE; Schema: public; Owner: ceos
--

CREATE SEQUENCE public.materiales_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.materiales_id_seq OWNER TO ceos;

--
-- Name: materiales_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: ceos
--

ALTER SEQUENCE public.materiales_id_seq OWNED BY public.materiales.id;


--
-- Name: movimientos_inventario; Type: TABLE; Schema: public; Owner: ceos
--

CREATE TABLE public.movimientos_inventario (
    id integer NOT NULL,
    material_id integer NOT NULL,
    tipo public.tipomovimientoenum NOT NULL,
    cantidad integer NOT NULL,
    fecha timestamp with time zone DEFAULT now() NOT NULL,
    usuario_id integer NOT NULL
);


ALTER TABLE public.movimientos_inventario OWNER TO ceos;

--
-- Name: movimientos_inventario_id_seq; Type: SEQUENCE; Schema: public; Owner: ceos
--

CREATE SEQUENCE public.movimientos_inventario_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.movimientos_inventario_id_seq OWNER TO ceos;

--
-- Name: movimientos_inventario_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: ceos
--

ALTER SEQUENCE public.movimientos_inventario_id_seq OWNED BY public.movimientos_inventario.id;


--
-- Name: solicitudes_material; Type: TABLE; Schema: public; Owner: ceos
--

CREATE TABLE public.solicitudes_material (
    id integer NOT NULL,
    material_id integer NOT NULL,
    cantidad integer NOT NULL,
    motivo character varying(255),
    estado public.estadosolicitudenum NOT NULL,
    solicitante_id integer NOT NULL,
    fecha_creacion timestamp with time zone DEFAULT now() NOT NULL
);


ALTER TABLE public.solicitudes_material OWNER TO ceos;

--
-- Name: solicitudes_material_id_seq; Type: SEQUENCE; Schema: public; Owner: ceos
--

CREATE SEQUENCE public.solicitudes_material_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.solicitudes_material_id_seq OWNER TO ceos;

--
-- Name: solicitudes_material_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: ceos
--

ALTER SEQUENCE public.solicitudes_material_id_seq OWNED BY public.solicitudes_material.id;


--
-- Name: usuarios; Type: TABLE; Schema: public; Owner: ceos
--

CREATE TABLE public.usuarios (
    id integer NOT NULL,
    nombre character varying(120) NOT NULL,
    email character varying(255) NOT NULL,
    hashed_password character varying(255) NOT NULL,
    rol public.roleenum NOT NULL
);


ALTER TABLE public.usuarios OWNER TO ceos;

--
-- Name: usuarios_id_seq; Type: SEQUENCE; Schema: public; Owner: ceos
--

CREATE SEQUENCE public.usuarios_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.usuarios_id_seq OWNER TO ceos;

--
-- Name: usuarios_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: ceos
--

ALTER SEQUENCE public.usuarios_id_seq OWNED BY public.usuarios.id;


--
-- Name: gastos id; Type: DEFAULT; Schema: public; Owner: ceos
--

ALTER TABLE ONLY public.gastos ALTER COLUMN id SET DEFAULT nextval('public.gastos_id_seq'::regclass);


--
-- Name: materiales id; Type: DEFAULT; Schema: public; Owner: ceos
--

ALTER TABLE ONLY public.materiales ALTER COLUMN id SET DEFAULT nextval('public.materiales_id_seq'::regclass);


--
-- Name: movimientos_inventario id; Type: DEFAULT; Schema: public; Owner: ceos
--

ALTER TABLE ONLY public.movimientos_inventario ALTER COLUMN id SET DEFAULT nextval('public.movimientos_inventario_id_seq'::regclass);


--
-- Name: solicitudes_material id; Type: DEFAULT; Schema: public; Owner: ceos
--

ALTER TABLE ONLY public.solicitudes_material ALTER COLUMN id SET DEFAULT nextval('public.solicitudes_material_id_seq'::regclass);


--
-- Name: usuarios id; Type: DEFAULT; Schema: public; Owner: ceos
--

ALTER TABLE ONLY public.usuarios ALTER COLUMN id SET DEFAULT nextval('public.usuarios_id_seq'::regclass);


--
-- Data for Name: gastos; Type: TABLE DATA; Schema: public; Owner: ceos
--

COPY public.gastos (id, concepto, monto, descripcion, fecha, registrado_por_id) FROM stdin;
1	Compra insumos MVP	150.50	Prueba smoke	2026-05-23 16:56:57.342688-04	1
2	Compra insumos MVP	150.50	Prueba smoke	2026-05-23 18:11:17.247595-04	1
\.


--
-- Data for Name: materiales; Type: TABLE DATA; Schema: public; Owner: ceos
--

COPY public.materiales (id, nombre, categoria, stock_actual, stock_minimo, fecha_vencimiento, fecha_alerta_vencimiento) FROM stdin;
1	Guantes Nitrilo MVP	Insumos	23	5	\N	\N
2	Guantes Nitrilo MVP 1779574276	Insumos	23	5	\N	\N
\.


--
-- Data for Name: movimientos_inventario; Type: TABLE DATA; Schema: public; Owner: ceos
--

COPY public.movimientos_inventario (id, material_id, tipo, cantidad, fecha, usuario_id) FROM stdin;
1	1	SALIDA	2	2026-05-23 16:56:57.320949-04	1
2	2	SALIDA	2	2026-05-23 18:11:17.223915-04	1
\.


--
-- Data for Name: solicitudes_material; Type: TABLE DATA; Schema: public; Owner: ceos
--

COPY public.solicitudes_material (id, material_id, cantidad, motivo, estado, solicitante_id, fecha_creacion) FROM stdin;
\.


--
-- Data for Name: usuarios; Type: TABLE DATA; Schema: public; Owner: ceos
--

COPY public.usuarios (id, nombre, email, hashed_password, rol) FROM stdin;
1	Super Admin	superadmin@ceos.com	$2b$12$KN2Q1Dkt67HU1CzBtWhwlu0qaHCauJk4dZiU6Az7YVVGF7a0NCfii	SUPERADMIN
\.


--
-- Name: gastos_id_seq; Type: SEQUENCE SET; Schema: public; Owner: ceos
--

SELECT pg_catalog.setval('public.gastos_id_seq', 2, true);


--
-- Name: materiales_id_seq; Type: SEQUENCE SET; Schema: public; Owner: ceos
--

SELECT pg_catalog.setval('public.materiales_id_seq', 2, true);


--
-- Name: movimientos_inventario_id_seq; Type: SEQUENCE SET; Schema: public; Owner: ceos
--

SELECT pg_catalog.setval('public.movimientos_inventario_id_seq', 2, true);


--
-- Name: solicitudes_material_id_seq; Type: SEQUENCE SET; Schema: public; Owner: ceos
--

SELECT pg_catalog.setval('public.solicitudes_material_id_seq', 1, false);


--
-- Name: usuarios_id_seq; Type: SEQUENCE SET; Schema: public; Owner: ceos
--

SELECT pg_catalog.setval('public.usuarios_id_seq', 1, true);


--
-- Name: gastos gastos_pkey; Type: CONSTRAINT; Schema: public; Owner: ceos
--

ALTER TABLE ONLY public.gastos
    ADD CONSTRAINT gastos_pkey PRIMARY KEY (id);


--
-- Name: materiales materiales_pkey; Type: CONSTRAINT; Schema: public; Owner: ceos
--

ALTER TABLE ONLY public.materiales
    ADD CONSTRAINT materiales_pkey PRIMARY KEY (id);


--
-- Name: movimientos_inventario movimientos_inventario_pkey; Type: CONSTRAINT; Schema: public; Owner: ceos
--

ALTER TABLE ONLY public.movimientos_inventario
    ADD CONSTRAINT movimientos_inventario_pkey PRIMARY KEY (id);


--
-- Name: solicitudes_material solicitudes_material_pkey; Type: CONSTRAINT; Schema: public; Owner: ceos
--

ALTER TABLE ONLY public.solicitudes_material
    ADD CONSTRAINT solicitudes_material_pkey PRIMARY KEY (id);


--
-- Name: usuarios usuarios_pkey; Type: CONSTRAINT; Schema: public; Owner: ceos
--

ALTER TABLE ONLY public.usuarios
    ADD CONSTRAINT usuarios_pkey PRIMARY KEY (id);


--
-- Name: ix_gastos_id; Type: INDEX; Schema: public; Owner: ceos
--

CREATE INDEX ix_gastos_id ON public.gastos USING btree (id);


--
-- Name: ix_materiales_id; Type: INDEX; Schema: public; Owner: ceos
--

CREATE INDEX ix_materiales_id ON public.materiales USING btree (id);


--
-- Name: ix_materiales_nombre; Type: INDEX; Schema: public; Owner: ceos
--

CREATE UNIQUE INDEX ix_materiales_nombre ON public.materiales USING btree (nombre);


--
-- Name: ix_movimientos_inventario_id; Type: INDEX; Schema: public; Owner: ceos
--

CREATE INDEX ix_movimientos_inventario_id ON public.movimientos_inventario USING btree (id);


--
-- Name: ix_solicitudes_material_id; Type: INDEX; Schema: public; Owner: ceos
--

CREATE INDEX ix_solicitudes_material_id ON public.solicitudes_material USING btree (id);


--
-- Name: ix_usuarios_email; Type: INDEX; Schema: public; Owner: ceos
--

CREATE UNIQUE INDEX ix_usuarios_email ON public.usuarios USING btree (email);


--
-- Name: ix_usuarios_id; Type: INDEX; Schema: public; Owner: ceos
--

CREATE INDEX ix_usuarios_id ON public.usuarios USING btree (id);


--
-- Name: gastos gastos_registrado_por_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ceos
--

ALTER TABLE ONLY public.gastos
    ADD CONSTRAINT gastos_registrado_por_id_fkey FOREIGN KEY (registrado_por_id) REFERENCES public.usuarios(id);


--
-- Name: movimientos_inventario movimientos_inventario_material_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ceos
--

ALTER TABLE ONLY public.movimientos_inventario
    ADD CONSTRAINT movimientos_inventario_material_id_fkey FOREIGN KEY (material_id) REFERENCES public.materiales(id);


--
-- Name: movimientos_inventario movimientos_inventario_usuario_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ceos
--

ALTER TABLE ONLY public.movimientos_inventario
    ADD CONSTRAINT movimientos_inventario_usuario_id_fkey FOREIGN KEY (usuario_id) REFERENCES public.usuarios(id);


--
-- Name: solicitudes_material solicitudes_material_material_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ceos
--

ALTER TABLE ONLY public.solicitudes_material
    ADD CONSTRAINT solicitudes_material_material_id_fkey FOREIGN KEY (material_id) REFERENCES public.materiales(id);


--
-- Name: solicitudes_material solicitudes_material_solicitante_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ceos
--

ALTER TABLE ONLY public.solicitudes_material
    ADD CONSTRAINT solicitudes_material_solicitante_id_fkey FOREIGN KEY (solicitante_id) REFERENCES public.usuarios(id);


--
-- PostgreSQL database dump complete
--

\unrestrict ZpG5FmdKQke3cTXuewBiqGrdgVmYghcNqqJt2QoDHMk5wsxBXrjG0Mh51uvwI33

