--
-- PostgreSQL database dump
--

\restrict KPnUfleIYDamopBhvAMDw70JeDLbM4OQgkhMK3lemz0oIemABwqR5i95Oex0Plr

-- Dumped from database version 16.13 (Homebrew)
-- Dumped by pg_dump version 16.13 (Homebrew)

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
-- Data for Name: __EFMigrationsHistory_PostgreSQL; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public."__EFMigrationsHistory_PostgreSQL" ("MigrationId", "ProductVersion") FROM stdin;
20260507170030_InitialCreate	8.0.4
\.


--
-- Data for Name: avatars; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.avatars ("Id", "Name", "ImageUrl", "IsDefault", "IsActive", "CreatedAt", "UpdatedAt", "IsDeleted") FROM stdin;
7895fb76-73ba-4bd6-9537-49aee1d29dd1	Varsayılan Avatar	/assets/avatars/default-avatar.png	t	t	2026-05-07 20:26:39.29808+03	\N	f
\.


--
-- Data for Name: users; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.users ("Id", "Email", "PasswordHash", "Role", "IsEmailConfirmed", "LastLoginAt", "CreatedAt", "UpdatedAt", "IsDeleted") FROM stdin;
79792f56-53a1-4e57-9903-5d469758d462	gunesatesok@gmail.com	$2a$11$nkPwvLFrcpvFxS8wogTZReutaBFvRbNGpU.aGkwuCZISaM8wsFe7G	1	f	2026-04-20 08:56:44.847938+03	2026-04-20 08:46:24.857994+03	2026-04-20 08:56:44.848746+03	f
025a8133-9088-4e90-9cd9-9dbe75bb8311	test2@test.com	$2a$11$ejxdOMk7Mudc/vNzvN0i5evByor5e9dyc3Qz6J9BifZ/8cWEBpMCe	1	f	\N	2026-04-20 13:02:00.945188+03	\N	f
1cbbd6d7-8625-4682-bc05-38dd8ef2e4ca	test@test.com	$2a$11$JAh5BsCo48giHv87GdFcj.IAawr8iQazMossnZPDkwGVW.7Gu0sMG	1	f	2026-05-07 20:33:14.711453+03	2026-04-20 11:21:01.566818+03	2026-05-07 20:33:14.71178+03	f
\.


--
-- Data for Name: parent_profiles; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.parent_profiles ("Id", "UserId", "FirstName", "LastName", "PhoneNumber", "CreatedAt", "UpdatedAt", "IsDeleted") FROM stdin;
1225320b-80e1-491f-8faa-01ea331fec84	79792f56-53a1-4e57-9903-5d469758d462	Gunes	Atesok	5336939304	2026-04-20 08:46:24.858008+03	\N	f
69f5a1e7-6fe4-49ab-8f34-8e870c6550b6	1cbbd6d7-8625-4682-bc05-38dd8ef2e4ca	Test	User	5551234567	2026-04-20 11:21:01.566835+03	\N	f
4e9fb792-0e57-4363-a431-accefb88bfd1	025a8133-9088-4e90-9cd9-9dbe75bb8311	test22	test2	5555555555	2026-04-20 13:02:00.945189+03	\N	f
\.


--
-- Data for Name: child_profiles; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.child_profiles ("Id", "ParentProfileId", "Name", "DateOfBirth", "GradeLevel", "AvatarImageUrl", "TotalCoins", "TotalStars", "AvatarId", "CreatedAt", "UpdatedAt", "IsDeleted") FROM stdin;
fecb8e5f-9a82-43b0-9df4-e2672492d16f	69f5a1e7-6fe4-49ab-8f34-8e870c6550b6	Mocha	2019-07-01 00:00:00+03	4	default-avatar.png	1200	33	\N	2026-04-20 13:49:52.261484+03	2026-04-23 16:41:21.553454+03	f
6c6a4aba-5350-4c1b-b45a-c0cb286c9dfc	69f5a1e7-6fe4-49ab-8f34-8e870c6550b6	Ada	2016-05-02 00:00:00+03	4	default-avatar.png	350	9	\N	2026-04-20 13:22:09.586511+03	2026-05-07 20:34:29.977435+03	f
\.


--
-- Data for Name: subjects; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.subjects ("Id", "Name", "DisplayOrder", "IsActive", "CreatedAt", "UpdatedAt", "IsDeleted") FROM stdin;
655d7fff-8c2b-4aa8-b723-b343d82c67d3	Matematik	1	t	2026-04-20 18:04:14.220553+03	\N	f
\.


--
-- Data for Name: topics; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.topics ("Id", "SubjectId", "Name", "Description", "DisplayOrder", "IsActive", "CreatedAt", "UpdatedAt", "IsDeleted") FROM stdin;
52bf8c1f-b712-43a9-95e6-2df20cf908e8	655d7fff-8c2b-4aa8-b723-b343d82c67d3	Çıkarma	Çıkarma işlemi	3	t	2026-04-20 18:04:14.262367+03	\N	f
68213d20-0b82-4cd4-be81-3e1fff54ab60	655d7fff-8c2b-4aa8-b723-b343d82c67d3	Problemler	Sözel matematik problemleri	4	t	2026-04-20 18:04:14.262367+03	\N	f
a8efd985-0f8f-43d1-9cc1-3971840c6d8a	655d7fff-8c2b-4aa8-b723-b343d82c67d3	Toplama	Toplama işlemi	2	t	2026-04-20 18:04:14.262366+03	\N	f
bc819b1d-773d-42fa-b74f-2d70506d7330	655d7fff-8c2b-4aa8-b723-b343d82c67d3	Sayı & Görsel	Sayıları tanıma ve görsel olarak sayma	1	t	2026-04-20 18:04:14.262366+03	\N	f
\.


--
-- Data for Name: levels; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.levels ("Id", "TopicId", "Name", "Description", "Difficulty", "DisplayOrder", "MinCorrectToPass", "IsActive", "CreatedAt", "UpdatedAt", "IsDeleted") FROM stdin;
3012e196-6ac2-4156-a482-b8d14ed6d4ea	bc819b1d-773d-42fa-b74f-2d70506d7330	Okul Öncesi	1-10 arası sayılar	1	1	7	t	2026-04-20 18:04:14.276441+03	\N	f
9d3cdecc-5943-4793-bdfe-864d5b027348	a8efd985-0f8f-43d1-9cc1-3971840c6d8a	Seviye 1	Basit toplama işlemleri	2	1	4	t	2026-04-20 18:04:14.276441+03	\N	f
b15d2478-fa2c-4d1a-a307-1b12857049a5	52bf8c1f-b712-43a9-95e6-2df20cf908e8	Seviye 1	Basit çıkarma işlemleri	2	1	4	t	2026-04-20 18:04:14.276441+03	\N	f
ec0cefef-ad9a-4817-a494-6a359263e1e8	68213d20-0b82-4cd4-be81-3e1fff54ab60	Seviye 1	Basit sözel problemler	3	1	4	t	2026-04-20 18:04:14.276441+03	\N	f
\.


--
-- Data for Name: questions; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.questions ("Id", "LevelId", "QuestionText", "QuestionType", "CorrectAnswer", "Explanation", "DisplayOrder", "IsActive", "CreatedAt", "UpdatedAt", "IsDeleted") FROM stdin;
0a1fe00f-b22a-43b0-81db-441835cccf46	3012e196-6ac2-4156-a482-b8d14ed6d4ea	En büyük sayı hangisi?	1	B	\N	10	t	2026-04-20 18:04:14.28649+03	\N	f
2456d510-aae6-4b70-a02b-c0f63a118785	3012e196-6ac2-4156-a482-b8d14ed6d4ea	3'ten sonra hangi sayı gelir?	1	A	\N	8	t	2026-04-20 18:04:14.28649+03	\N	f
3dc4988f-9a75-4c37-aff9-86662c2475fd	3012e196-6ac2-4156-a482-b8d14ed6d4ea	5'ten önce hangi sayı gelir?	1	A	\N	9	t	2026-04-20 18:04:14.28649+03	\N	f
42279694-ac42-4a60-a607-1ced6b3bfcab	3012e196-6ac2-4156-a482-b8d14ed6d4ea	Hangisi daha büyüktür?	1	B	\N	3	t	2026-04-20 18:04:14.28649+03	\N	f
54f66de2-6167-406f-8fe5-315563f67811	3012e196-6ac2-4156-a482-b8d14ed6d4ea	🐶🐶🐶 kaç köpek var?	1	B	\N	2	t	2026-04-20 18:04:14.28649+03	\N	f
5dd3a430-608a-4d1f-8ce3-a1096e4d71f8	3012e196-6ac2-4156-a482-b8d14ed6d4ea	Hangisi daha küçüktür?	1	B	\N	4	t	2026-04-20 18:04:14.28649+03	\N	f
6ef5f993-38a8-46b1-acc5-72932e00cb32	3012e196-6ac2-4156-a482-b8d14ed6d4ea	Hangisi 10'dan küçüktür?	1	B	\N	7	t	2026-04-20 18:04:14.28649+03	\N	f
a13edd1f-987b-4f36-9ab2-58bb56804a4b	3012e196-6ac2-4156-a482-b8d14ed6d4ea	🍌🍌🍌🍌 kaç muz var?	1	B	\N	5	t	2026-04-20 18:04:14.28649+03	\N	f
a5cd1bee-8379-4e51-aaa4-afcc25423c9f	3012e196-6ac2-4156-a482-b8d14ed6d4ea	Boşluğu doldur: 1, 2, __, 4	3	3	\N	6	t	2026-04-20 18:04:14.28649+03	\N	f
f6f8cf02-ee5f-4151-90e5-f1eacbb3d7f7	3012e196-6ac2-4156-a482-b8d14ed6d4ea	🍎🍎 kaç tane elma var?	1	B	İki tane elma var.	1	t	2026-04-20 18:04:14.28649+03	\N	f
1e2d1f29-0d67-4e60-bfee-1f619188bb52	9d3cdecc-5943-4793-bdfe-864d5b027348	2 + 3 = ?	3	5	\N	1	t	2026-04-20 18:04:14.297189+03	\N	f
4c7bfc86-9aad-4e18-b509-aace5a1fdd38	9d3cdecc-5943-4793-bdfe-864d5b027348	4 + 1 = ?	3	5	\N	2	t	2026-04-20 18:04:14.297189+03	\N	f
8e577492-0a43-41a7-92ac-c93c4e0f87ff	9d3cdecc-5943-4793-bdfe-864d5b027348	3 + 6 = ?	3	9	\N	4	t	2026-04-20 18:04:14.297189+03	\N	f
c29cca61-a629-47e1-a1e2-dcc3b48302a6	9d3cdecc-5943-4793-bdfe-864d5b027348	7 + 1 = ?	3	8	\N	5	t	2026-04-20 18:04:14.297189+03	\N	f
f8fd660a-1baa-4dd8-aa71-060b46dffd74	9d3cdecc-5943-4793-bdfe-864d5b027348	5 + 2 = ?	3	7	\N	3	t	2026-04-20 18:04:14.297189+03	\N	f
04c03d36-f978-4060-b4ad-9c312f7483f2	b15d2478-fa2c-4d1a-a307-1b12857049a5	5 - 2 = ?	3	3	\N	1	t	2026-04-20 18:04:14.298979+03	\N	f
5535087c-ddb2-4940-aa7d-deb30b21b15a	b15d2478-fa2c-4d1a-a307-1b12857049a5	9 - 1 = ?	3	8	\N	3	t	2026-04-20 18:04:14.298979+03	\N	f
62725af4-4054-49a9-aa32-ccf83b8d7d55	b15d2478-fa2c-4d1a-a307-1b12857049a5	7 - 3 = ?	3	4	\N	2	t	2026-04-20 18:04:14.298979+03	\N	f
82c8332e-65ed-47ec-9b20-86760b6225e7	b15d2478-fa2c-4d1a-a307-1b12857049a5	6 - 3 = ?	3	3	\N	5	t	2026-04-20 18:04:14.298979+03	\N	f
91956aa4-c9a9-4c9f-9de1-1a4ae31142d1	b15d2478-fa2c-4d1a-a307-1b12857049a5	8 - 2 = ?	3	6	\N	4	t	2026-04-20 18:04:14.298979+03	\N	f
0af0a9ce-4b34-4791-acf9-9ce0b3ab90a6	ec0cefef-ad9a-4817-a494-6a359263e1e8	Ayşe'nin 5 kalemi var. 1 tanesi kırıldı. Kaç kaldı?	3	4	5 - 1 = 4	2	t	2026-04-20 18:04:14.301025+03	\N	f
7c6bce09-d60b-47d8-85f4-538f5694069f	ec0cefef-ad9a-4817-a494-6a359263e1e8	4 kuş vardı. 1'i uçtu. Kaç kaldı?	3	3	4 - 1 = 3	4	t	2026-04-20 18:04:14.301025+03	\N	f
80724837-f696-4258-a6b1-cee21657464a	ec0cefef-ad9a-4817-a494-6a359263e1e8	Ali'nin 2 elması var. 2 tane daha aldı. Kaç oldu?	3	4	2 + 2 = 4	1	t	2026-04-20 18:04:14.301025+03	\N	f
9d43aecb-ddb7-4a1a-98f0-d0171f7aa2ee	ec0cefef-ad9a-4817-a494-6a359263e1e8	Bir sepette 3 elma vardı. 3 tane daha eklendi. Kaç oldu?	3	6	3 + 3 = 6	3	t	2026-04-20 18:04:14.301025+03	\N	f
a2ac4fb3-8a0a-44b8-93e3-3ece1652ec92	ec0cefef-ad9a-4817-a494-6a359263e1e8	7 balon vardı. 2'si patladı. Kaç kaldı?	3	5	7 - 2 = 5	5	t	2026-04-20 18:04:14.301025+03	\N	f
\.


--
-- Data for Name: answer_attempts; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.answer_attempts ("Id", "ChildId", "QuestionId", "SubmittedAnswer", "IsCorrect", "TimeTakenSeconds", "AttemptedAt", "CreatedAt", "UpdatedAt", "IsDeleted") FROM stdin;
\.


--
-- Data for Name: avatar_items; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.avatar_items ("Id", "Name", "ItemType", "PointCost", "ImageUrl", "Category", "IsActive", "CreatedAt", "UpdatedAt", "IsDeleted") FROM stdin;
10175cac-abed-4521-ae98-21e7705e6785	🎽 Spor Forması	3	150	/assets/items/outfits/sports-jersey.png	Kıyafet	t	2026-05-07 20:26:39.342769+03	\N	f
176ced0b-2ae2-44cb-966f-50bff6fd4246	🎩 Silindir Şapka	1	100	/assets/items/hats/top-hat.png	Şapka	t	2026-05-07 20:26:39.342769+03	\N	f
34fae7dd-823f-4008-83d7-4260ba37a28b	🕶️ Güneş Gözlüğü	2	75	/assets/items/glasses/sunglasses.png	Gözlük	t	2026-05-07 20:26:39.342769+03	\N	f
3a8e7d73-910d-4aa1-829a-599ed6650f7c	👑 Altın Taç	1	100	/assets/items/hats/crown.png	Şapka	t	2026-05-07 20:26:39.342769+03	\N	f
698280bd-d639-416d-90e1-963fb50756c5	🌌 Uzay Arka Planı	5	250	/assets/items/backgrounds/space.png	Arka Plan	t	2026-05-07 20:26:39.34277+03	\N	f
71296b37-3f63-4407-b6da-64c2a59d8995	⭐ Parlayan Yıldız	4	100	/assets/items/accessories/star.png	Aksesuar	t	2026-05-07 20:26:39.342769+03	\N	f
b1f95b1f-1d24-40d2-a716-6bef7fb83670	👓 Okuma Gözlüğü	2	75	/assets/items/glasses/reading-glasses.png	Gözlük	t	2026-05-07 20:26:39.342769+03	\N	f
b86225ea-fcb5-41e5-8f92-d8d0a1e05a50	🧢 Kırmızı Şapka	1	50	/assets/items/hats/red-cap.png	Şapka	t	2026-05-07 20:26:39.342769+03	\N	f
bcf02f38-2696-45e2-b1ca-9e430d2a0e1d	🌈 Gökkuşağı Arka Plan	5	250	/assets/items/backgrounds/rainbow.png	Arka Plan	t	2026-05-07 20:26:39.342769+03	\N	f
bdb8c51a-8e62-462c-9bc2-875dd1a555ce	🦸 Süper Kahraman Kostümü	3	200	/assets/items/outfits/superhero.png	Kıyafet	t	2026-05-07 20:26:39.342769+03	\N	f
de822da3-d37a-49a3-826c-bb8259330a15	🎒 Renkli Sırt Çantası	4	100	/assets/items/accessories/backpack.png	Aksesuar	t	2026-05-07 20:26:39.342769+03	\N	f
eb51adbc-43df-46a1-b713-9379b06aaa71	👕 Mavi Tişört	3	150	/assets/items/outfits/blue-tshirt.png	Kıyafet	t	2026-05-07 20:26:39.342769+03	\N	f
\.


--
-- Data for Name: child_equipped_items; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.child_equipped_items ("Id", "ChildProfileId", "ItemId", "EquippedAt", "CreatedAt", "UpdatedAt", "IsDeleted") FROM stdin;
\.


--
-- Data for Name: child_owned_items; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.child_owned_items ("Id", "ChildProfileId", "ItemId", "PurchasedAt", "CreatedAt", "UpdatedAt", "IsDeleted") FROM stdin;
\.


--
-- Data for Name: child_progress; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.child_progress ("Id", "ChildId", "TotalScore", "TotalStars", "CompletedLevelsCount", "CreatedAt", "UpdatedAt", "IsDeleted") FROM stdin;
90aa4714-f309-4425-b1bb-506ecea92d24	6c6a4aba-5350-4c1b-b45a-c0cb286c9dfc	200	6	1	2026-05-07 20:28:29.463485+03	2026-05-07 20:34:29.974593+03	f
\.


--
-- Data for Name: level_results; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.level_results ("Id", "ChildId", "LevelId", "Score", "Stars", "CorrectCount", "TotalQuestions", "SuccessPercentage", "IsUnlocked", "CompletedAt", "CreatedAt", "UpdatedAt", "IsDeleted") FROM stdin;
65b0b3b8-5165-48f6-b756-1daf14514d2c	6c6a4aba-5350-4c1b-b45a-c0cb286c9dfc	3012e196-6ac2-4156-a482-b8d14ed6d4ea	100	3	10	10	100.00	t	2026-05-07 20:28:29.434229+03	2026-05-07 20:28:29.450141+03	\N	f
\.


--
-- Data for Name: match_sessions; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.match_sessions ("Id", "StartedAt", "EndedAt", "Status", "WinnerId", "CreatedAt", "UpdatedAt", "IsDeleted") FROM stdin;
\.


--
-- Data for Name: match_participants; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.match_participants ("Id", "MatchSessionId", "ChildProfileId", "Score", "JoinedAt", "IsReady", "CreatedAt", "UpdatedAt", "IsDeleted") FROM stdin;
\.


--
-- Data for Name: match_answers; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.match_answers ("Id", "MatchSessionId", "ParticipantId", "QuestionId", "Answer", "IsCorrect", "AnsweredAt", "PointsEarned", "CreatedAt", "UpdatedAt", "IsDeleted") FROM stdin;
\.


--
-- Data for Name: match_questions; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.match_questions ("Id", "MatchSessionId", "QuestionId", "QuestionOrder", "CreatedAt", "UpdatedAt", "IsDeleted") FROM stdin;
\.


--
-- Data for Name: match_requests; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.match_requests ("Id", "ChildProfileId", "RequestedAt", "Status", "MatchedAt", "MatchSessionId", "CreatedAt", "UpdatedAt", "IsDeleted") FROM stdin;
\.


--
-- Data for Name: question_options; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.question_options ("Id", "QuestionId", "OptionText", "DisplayOrder", "CreatedAt", "UpdatedAt", "IsDeleted") FROM stdin;
07a3ba69-d1fa-4c49-886f-b2fdd2d37543	0a1fe00f-b22a-43b0-81db-441835cccf46	9	1	2026-04-20 18:04:14.292903+03	\N	f
2884bf40-990f-4984-bf41-a38bd4a4363e	a13edd1f-987b-4f36-9ab2-58bb56804a4b	3	0	2026-04-20 18:04:14.292903+03	\N	f
3c4af2a1-a3ed-4eb1-9055-2133b686777f	f6f8cf02-ee5f-4151-90e5-f1eacbb3d7f7	3	2	2026-04-20 18:04:14.292902+03	\N	f
49f69d8c-c61c-4897-858d-8d74142cf140	a13edd1f-987b-4f36-9ab2-58bb56804a4b	4	1	2026-04-20 18:04:14.292903+03	\N	f
72ec3895-976d-44ee-96dc-74f1f5d54ad5	6ef5f993-38a8-46b1-acc5-72932e00cb32	8	1	2026-04-20 18:04:14.292903+03	\N	f
7821cc84-4416-475b-a470-4ce9cc09ee7c	5dd3a430-608a-4d1f-8ce3-a1096e4d71f8	3	1	2026-04-20 18:04:14.292902+03	\N	f
7f82c9c0-0605-4162-b43f-0589b325b87b	42279694-ac42-4a60-a607-1ced6b3bfcab	5	1	2026-04-20 18:04:14.292902+03	\N	f
84f38496-f4be-4868-868c-90efbf5bcb04	42279694-ac42-4a60-a607-1ced6b3bfcab	2	0	2026-04-20 18:04:14.292902+03	\N	f
87d8a62c-0c4b-4315-8ec3-de63ea20e680	6ef5f993-38a8-46b1-acc5-72932e00cb32	12	0	2026-04-20 18:04:14.292903+03	\N	f
8f8fd8dc-fd61-4993-bdeb-c557b3bb0896	2456d510-aae6-4b70-a02b-c0f63a118785	4	0	2026-04-20 18:04:14.292903+03	\N	f
9cb352b5-da66-4114-bb94-8cb79cfbc213	5dd3a430-608a-4d1f-8ce3-a1096e4d71f8	7	0	2026-04-20 18:04:14.292902+03	\N	f
a47f4ed1-5290-48c5-a0d3-250b2c3e4ba2	0a1fe00f-b22a-43b0-81db-441835cccf46	7	2	2026-04-20 18:04:14.292903+03	\N	f
a9907201-c66b-4a06-9da3-b134a1561565	54f66de2-6167-406f-8fe5-315563f67811	3	1	2026-04-20 18:04:14.292902+03	\N	f
b417ef91-509b-440e-8837-0b43673ce144	a13edd1f-987b-4f36-9ab2-58bb56804a4b	5	2	2026-04-20 18:04:14.292903+03	\N	f
ca2f46ca-8f8c-4193-8738-fb1846359e94	f6f8cf02-ee5f-4151-90e5-f1eacbb3d7f7	2	1	2026-04-20 18:04:14.292902+03	\N	f
ca486fb6-19ee-428a-8e78-ae174d3c846d	3dc4988f-9a75-4c37-aff9-86662c2475fd	6	1	2026-04-20 18:04:14.292903+03	\N	f
d7801b0b-53fa-47d6-9a16-d93b69b1d1d0	3dc4988f-9a75-4c37-aff9-86662c2475fd	4	0	2026-04-20 18:04:14.292903+03	\N	f
e7f3ecd2-963c-4790-9480-7856a5fe9087	54f66de2-6167-406f-8fe5-315563f67811	2	0	2026-04-20 18:04:14.292902+03	\N	f
ea644576-610b-4797-94b8-e85ab6b26ce0	54f66de2-6167-406f-8fe5-315563f67811	4	2	2026-04-20 18:04:14.292902+03	\N	f
ea7ae2dd-ee63-42d3-8920-02e28dc5fdcd	f6f8cf02-ee5f-4151-90e5-f1eacbb3d7f7	1	0	2026-04-20 18:04:14.292903+03	\N	f
ed5e0f1c-1880-4862-8f0f-c32196fac6be	0a1fe00f-b22a-43b0-81db-441835cccf46	6	0	2026-04-20 18:04:14.292903+03	\N	f
f500c822-da9a-477c-bcee-b0a71e43bcb0	2456d510-aae6-4b70-a02b-c0f63a118785	5	1	2026-04-20 18:04:14.292903+03	\N	f
\.


--
-- Data for Name: refresh_tokens; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.refresh_tokens ("Id", "UserId", "Token", "ExpiresAt", "IsRevoked", "IpAddress", "UserAgent", "CreatedAt", "UpdatedAt", "IsDeleted") FROM stdin;
d2be05ec-9604-40d4-88bf-d18d1c508427	1cbbd6d7-8625-4682-bc05-38dd8ef2e4ca	5cEywCptPPMuhcV3JIwvQGojj4fK4WLuHFgDQXBKeXYZNEzFOH2G4kRvfcMpN+1R4iOHcd6iAEZJIokP4wXAMg==	2026-05-14 20:27:31.193053+03	f	\N	\N	2026-05-07 20:27:31.238741+03	\N	f
4dcf18c8-9631-45c9-bab0-e58a7a6cf624	1cbbd6d7-8625-4682-bc05-38dd8ef2e4ca	+tqHR4fdXGluclpDax68wsBGy+zju8H7KvyXii3RcTN0vhFY9dIOd5HYRFosMPQkQl2nXCMHxLHxD1Hie9866g==	2026-05-14 20:33:14.716561+03	f	\N	\N	2026-05-07 20:33:14.717472+03	\N	f
\.


--
-- PostgreSQL database dump complete
--

\unrestrict KPnUfleIYDamopBhvAMDw70JeDLbM4OQgkhMK3lemz0oIemABwqR5i95Oex0Plr

