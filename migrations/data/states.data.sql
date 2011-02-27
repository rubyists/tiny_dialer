--
-- PostgreSQL database dump
--

SET statement_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = off;
SET check_function_bodies = false;
SET client_min_messages = warning;
SET escape_string_warning = off;

SET search_path = public, pg_catalog;

--
-- Name: states_id_seq; Type: SEQUENCE SET; Schema: public; Owner: dialer
--

SELECT pg_catalog.setval('states_id_seq', 51, true);


--
-- Data for Name: states; Type: TABLE DATA; Schema: public; Owner: dialer
--

COPY states (id, state, start, stop) FROM stdin;
39	TX	08:00	20:00
1	MA	09:00	20:00
2	RI	09:00	20:00
3	NH	09:00	20:00
4	ME	09:00	20:00
5	VT	09:00	20:00
6	CT	09:00	20:00
7	NJ	09:00	20:00
8	NY	09:00	20:00
9	PA	09:00	20:00
10	DE	09:00	20:00
11	DC	09:00	20:00
12	MD	09:00	20:00
13	VA	09:00	20:00
14	WV	09:00	20:00
15	NC	09:00	20:00
16	SC	09:00	20:00
17	GA	09:00	20:00
18	FL	09:00	20:00
19	AL	09:00	20:00
20	TN	09:00	20:00
21	MS	09:00	20:00
22	KY	09:00	20:00
23	OH	09:00	20:00
24	IN	09:00	20:00
25	MI	09:00	20:00
26	IA	09:00	20:00
27	WI	09:00	20:00
28	MN	09:00	20:00
29	SD	09:00	20:00
30	ND	09:00	20:00
31	MT	09:00	20:00
32	IL	09:00	20:00
33	MO	09:00	20:00
34	KS	09:00	20:00
35	NE	09:00	20:00
36	LA	09:00	20:00
37	AR	09:00	20:00
38	OK	09:00	20:00
40	CO	09:00	20:00
41	WY	09:00	20:00
42	ID	09:00	20:00
43	UT	09:00	20:00
44	AZ	09:00	20:00
45	NM	09:00	20:00
46	NV	09:00	20:00
47	CA	09:00	20:00
48	HI	09:00	20:00
49	OR	09:00	20:00
50	WA	09:00	20:00
51	AK	09:00	20:00
\.


--
-- PostgreSQL database dump complete
--

