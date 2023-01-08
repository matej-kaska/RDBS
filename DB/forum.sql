PGDMP         3                 {            forum    14.3    14.3 N    M           0    0    ENCODING    ENCODING        SET client_encoding = 'UTF8';
                      false            N           0    0 
   STDSTRINGS 
   STDSTRINGS     (   SET standard_conforming_strings = 'on';
                      false            O           0    0 
   SEARCHPATH 
   SEARCHPATH     8   SELECT pg_catalog.set_config('search_path', '', false);
                      false            P           1262    16394    forum    DATABASE     a   CREATE DATABASE forum WITH TEMPLATE = template0 ENCODING = 'UTF8' LOCALE = 'Czech_Czechia.1250';
    DROP DATABASE forum;
                postgres    false            �            1255    32869    count_comm(integer)    FUNCTION       CREATE FUNCTION public.count_comm(komentar integer) RETURNS integer
    LANGUAGE plpgsql
    AS $$DECLARE celkem integer;

BEGIN

	SELECT COUNT(k.id) INTO celkem
	FROM komentare k
	JOIN prispevky p
	ON p.id = k.prispevek_id
	WHERE k.prispevek_id = komentar;
	
	RETURN celkem;
	
END;
$$;
 3   DROP FUNCTION public.count_comm(komentar integer);
       public          postgres    false            �            1255    32842    count_rows_of_table(text, text)    FUNCTION     �  CREATE FUNCTION public.count_rows_of_table(schema text, tablename text) RETURNS integer
    LANGUAGE plpgsql
    AS $$DECLARE
  query_template CONSTANT TEXT NOT NULL :='SELECT COUNT(*) FROM "?schema"."?tablename"';

  query CONSTANT TEXT NOT NULL :=
    REPLACE(
      REPLACE(
        query_template, '?schema', schema),
     '?tablename', tablename);

  result INT NOT NULL := -1;
BEGIN
  EXECUTE query INTO result;
  RETURN result;
END;$$;
 G   DROP FUNCTION public.count_rows_of_table(schema text, tablename text);
       public          postgres    false            �            1255    32871    random_hodnoceni()    FUNCTION     ~  CREATE FUNCTION public.random_hodnoceni() RETURNS void
    LANGUAGE plpgsql
    AS $$DECLARE 
	cur CURSOR FOR SELECT id, hodnoceni, uzivatel_id, prispevek_id FROM hodnoceni;
	cur_row RECORD;
BEGIN
	open cur;
LOOP
	fetch cur into cur_row;
	EXIT WHEN NOT FOUND;
	UPDATE hodnoceni SET hodnoceni = trunc(random() * 5 + 1) WHERE cur_row.id = hodnoceni.id;
END LOOP;
	close cur;
END;
$$;
 )   DROP FUNCTION public.random_hodnoceni();
       public          postgres    false            �            1255    32885    random_random_hodnoceni() 	   PROCEDURE       CREATE PROCEDURE public.random_random_hodnoceni()
    LANGUAGE plpgsql
    AS $$DECLARE 
	cur CURSOR FOR SELECT id, hodnoceni, uzivatel_id, prispevek_id FROM hodnoceni;
	cur_row RECORD;
BEGIN
	open cur;
LOOP
	fetch cur into cur_row;
	EXIT WHEN NOT FOUND;
	UPDATE hodnoceni SET hodnoceni = trunc(random() * 5 + 1) WHERE cur_row.id = hodnoceni.id;
END LOOP;
	close cur;
IF trunc(random() * 2 + 1) = 1 THEN
    COMMIT;
	RAISE NOTICE 'Commitnuto! (Success)';
ELSE
	ROLLBACK;
	raise NOTICE 'Rollbacknuto! (Fail)';
END IF;
END;
$$;
 1   DROP PROCEDURE public.random_random_hodnoceni();
       public          postgres    false            �            1255    32882    uzivatele_changes()    FUNCTION     `  CREATE FUNCTION public.uzivatele_changes() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
	IF NEW.prezdivka <> OLD.prezdivka OR NEW.heslo <> OLD.heslo OR NEW.email <> OLD.email THEN
		 INSERT INTO uzivatele_audits(uzivatel_id,prezdivka,heslo,email,zmena)
		 VALUES(OLD.id,OLD.prezdivka,OLD.heslo,OLD.email,now());
	END IF;

	RETURN NEW;
END;
$$;
 *   DROP FUNCTION public.uzivatele_changes();
       public          postgres    false            �            1259    16400    hodnoceni_id_seq    SEQUENCE     �   CREATE SEQUENCE public.hodnoceni_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 '   DROP SEQUENCE public.hodnoceni_id_seq;
       public          postgres    false            �            1259    16395 	   hodnoceni    TABLE     �   CREATE TABLE public.hodnoceni (
    id integer DEFAULT nextval('public.hodnoceni_id_seq'::regclass) NOT NULL,
    hodnoceni numeric NOT NULL,
    uzivatel_id integer NOT NULL,
    prispevek_id integer NOT NULL
);
    DROP TABLE public.hodnoceni;
       public         heap    postgres    false    210            Q           0    0    TABLE hodnoceni    ACL     2   GRANT DELETE ON TABLE public.hodnoceni TO matejr;
          public          postgres    false    209            �            1259    16406    komentare_id_seq    SEQUENCE     �   CREATE SEQUENCE public.komentare_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 '   DROP SEQUENCE public.komentare_id_seq;
       public          postgres    false            �            1259    16401 	   komentare    TABLE     �   CREATE TABLE public.komentare (
    id integer DEFAULT nextval('public.komentare_id_seq'::regclass) NOT NULL,
    uzivatel_id integer NOT NULL,
    prispevek_id integer NOT NULL,
    text text NOT NULL
);
    DROP TABLE public.komentare;
       public         heap    postgres    false    212            R           0    0    TABLE komentare    ACL     2   GRANT DELETE ON TABLE public.komentare TO matejr;
          public          postgres    false    211            �            1259    16419    role    TABLE     \   CREATE TABLE public.role (
    id integer NOT NULL,
    nazev character varying NOT NULL
);
    DROP TABLE public.role;
       public         heap    postgres    false            S           0    0 
   TABLE role    ACL     -   GRANT DELETE ON TABLE public.role TO matejr;
          public          postgres    false    217            �            1259    16431    uzivatele_role    TABLE     g   CREATE TABLE public.uzivatele_role (
    role_id integer NOT NULL,
    uzivatel_id integer NOT NULL
);
 "   DROP TABLE public.uzivatele_role;
       public         heap    postgres    false            T           0    0    TABLE uzivatele_role    ACL     7   GRANT DELETE ON TABLE public.uzivatele_role TO matejr;
          public          postgres    false    221            �            1259    24695    number_of_sers    VIEW     �   CREATE VIEW public.number_of_sers AS
 SELECT r.nazev
   FROM (public.role r
     RIGHT JOIN public.uzivatele_role ur ON ((r.id = ur.role_id)));
 !   DROP VIEW public.number_of_sers;
       public          postgres    false    217    221    217            U           0    0    TABLE number_of_sers    ACL     7   GRANT DELETE ON TABLE public.number_of_sers TO matejr;
          public          postgres    false    222            �            1259    16413 	   prispevky    TABLE     �   CREATE TABLE public.prispevky (
    id integer NOT NULL,
    nazev character varying NOT NULL,
    obsah text NOT NULL,
    obrazek character varying NOT NULL,
    uzivatel_id integer NOT NULL
);
    DROP TABLE public.prispevky;
       public         heap    postgres    false            V           0    0    TABLE prispevky    ACL     2   GRANT DELETE ON TABLE public.prispevky TO matejr;
          public          postgres    false    215            �            1259    16425 	   uzivatele    TABLE     �   CREATE TABLE public.uzivatele (
    id integer NOT NULL,
    prezdivka character varying NOT NULL,
    heslo character varying NOT NULL,
    email character varying NOT NULL
);
    DROP TABLE public.uzivatele;
       public         heap    postgres    false            W           0    0    TABLE uzivatele    ACL     2   GRANT DELETE ON TABLE public.uzivatele TO matejr;
          public          postgres    false    219            �            1259    32849    number_of_users    VIEW     �  CREATE VIEW public.number_of_users AS
 SELECT r.nazev,
    count(r.nazev) AS pocet_uzivatelu,
    count(p.id) AS pocet_prispevku
   FROM (((public.role r
     RIGHT JOIN public.uzivatele_role ur ON ((r.id = ur.role_id)))
     JOIN public.uzivatele u ON ((u.id = ur.uzivatel_id)))
     LEFT JOIN public.prispevky p ON ((p.uzivatel_id = u.id)))
  GROUP BY r.nazev
  ORDER BY (count(r.nazev));
 "   DROP VIEW public.number_of_users;
       public          postgres    false    221    215    215    217    217    219    221            �            1259    16412    odpovedi_id_seq    SEQUENCE     �   CREATE SEQUENCE public.odpovedi_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 &   DROP SEQUENCE public.odpovedi_id_seq;
       public          postgres    false            �            1259    16407    odpovedi    TABLE     �   CREATE TABLE public.odpovedi (
    id integer DEFAULT nextval('public.odpovedi_id_seq'::regclass) NOT NULL,
    text text NOT NULL,
    uzivatel_id integer NOT NULL,
    komentar_id integer NOT NULL
);
    DROP TABLE public.odpovedi;
       public         heap    postgres    false    214            X           0    0    TABLE odpovedi    ACL     1   GRANT DELETE ON TABLE public.odpovedi TO matejr;
          public          postgres    false    213            �            1259    16418    posts_id_seq    SEQUENCE     �   CREATE SEQUENCE public.posts_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 #   DROP SEQUENCE public.posts_id_seq;
       public          postgres    false    215            Y           0    0    posts_id_seq    SEQUENCE OWNED BY     A   ALTER SEQUENCE public.posts_id_seq OWNED BY public.prispevky.id;
          public          postgres    false    216            �            1259    16424    roles_id_seq    SEQUENCE     �   CREATE SEQUENCE public.roles_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 #   DROP SEQUENCE public.roles_id_seq;
       public          postgres    false    217            Z           0    0    roles_id_seq    SEQUENCE OWNED BY     <   ALTER SEQUENCE public.roles_id_seq OWNED BY public.role.id;
          public          postgres    false    218            �            1259    16430    users_id_seq    SEQUENCE     �   CREATE SEQUENCE public.users_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 #   DROP SEQUENCE public.users_id_seq;
       public          postgres    false    219            [           0    0    users_id_seq    SEQUENCE OWNED BY     A   ALTER SEQUENCE public.users_id_seq OWNED BY public.uzivatele.id;
          public          postgres    false    220            �            1259    32877    uzivatele_audits    TABLE       CREATE TABLE public.uzivatele_audits (
    id integer NOT NULL,
    uzivatel_id integer NOT NULL,
    prezdivka character varying NOT NULL,
    heslo character varying NOT NULL,
    email character varying NOT NULL,
    zmena timestamp(6) without time zone NOT NULL
);
 $   DROP TABLE public.uzivatele_audits;
       public         heap    postgres    false            �            1259    32876    uzivatele_audits_id_seq    SEQUENCE     �   ALTER TABLE public.uzivatele_audits ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.uzivatele_audits_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);
            public          postgres    false    225            �           2604    24579    prispevky id    DEFAULT     h   ALTER TABLE ONLY public.prispevky ALTER COLUMN id SET DEFAULT nextval('public.posts_id_seq'::regclass);
 ;   ALTER TABLE public.prispevky ALTER COLUMN id DROP DEFAULT;
       public          postgres    false    216    215            �           2604    24580    role id    DEFAULT     c   ALTER TABLE ONLY public.role ALTER COLUMN id SET DEFAULT nextval('public.roles_id_seq'::regclass);
 6   ALTER TABLE public.role ALTER COLUMN id DROP DEFAULT;
       public          postgres    false    218    217            �           2604    24581    uzivatele id    DEFAULT     h   ALTER TABLE ONLY public.uzivatele ALTER COLUMN id SET DEFAULT nextval('public.users_id_seq'::regclass);
 ;   ALTER TABLE public.uzivatele ALTER COLUMN id DROP DEFAULT;
       public          postgres    false    220    219            <          0    16395 	   hodnoceni 
   TABLE DATA           M   COPY public.hodnoceni (id, hodnoceni, uzivatel_id, prispevek_id) FROM stdin;
    public          postgres    false    209   �[       >          0    16401 	   komentare 
   TABLE DATA           H   COPY public.komentare (id, uzivatel_id, prispevek_id, text) FROM stdin;
    public          postgres    false    211   �]       @          0    16407    odpovedi 
   TABLE DATA           F   COPY public.odpovedi (id, text, uzivatel_id, komentar_id) FROM stdin;
    public          postgres    false    213   �d       B          0    16413 	   prispevky 
   TABLE DATA           K   COPY public.prispevky (id, nazev, obsah, obrazek, uzivatel_id) FROM stdin;
    public          postgres    false    215   �h       D          0    16419    role 
   TABLE DATA           )   COPY public.role (id, nazev) FROM stdin;
    public          postgres    false    217   �       F          0    16425 	   uzivatele 
   TABLE DATA           @   COPY public.uzivatele (id, prezdivka, heslo, email) FROM stdin;
    public          postgres    false    219   �       J          0    32877    uzivatele_audits 
   TABLE DATA           [   COPY public.uzivatele_audits (id, uzivatel_id, prezdivka, heslo, email, zmena) FROM stdin;
    public          postgres    false    225   Y�       H          0    16431    uzivatele_role 
   TABLE DATA           >   COPY public.uzivatele_role (role_id, uzivatel_id) FROM stdin;
    public          postgres    false    221   &�       \           0    0    hodnoceni_id_seq    SEQUENCE SET     @   SELECT pg_catalog.setval('public.hodnoceni_id_seq', 164, true);
          public          postgres    false    210            ]           0    0    komentare_id_seq    SEQUENCE SET     ?   SELECT pg_catalog.setval('public.komentare_id_seq', 30, true);
          public          postgres    false    212            ^           0    0    odpovedi_id_seq    SEQUENCE SET     >   SELECT pg_catalog.setval('public.odpovedi_id_seq', 31, true);
          public          postgres    false    214            _           0    0    posts_id_seq    SEQUENCE SET     ;   SELECT pg_catalog.setval('public.posts_id_seq', 22, true);
          public          postgres    false    216            `           0    0    roles_id_seq    SEQUENCE SET     :   SELECT pg_catalog.setval('public.roles_id_seq', 4, true);
          public          postgres    false    218            a           0    0    users_id_seq    SEQUENCE SET     ;   SELECT pg_catalog.setval('public.users_id_seq', 40, true);
          public          postgres    false    220            b           0    0    uzivatele_audits_id_seq    SEQUENCE SET     E   SELECT pg_catalog.setval('public.uzivatele_audits_id_seq', 2, true);
          public          postgres    false    224            �           2606    16441    hodnoceni hodnoceni_pkey 
   CONSTRAINT     V   ALTER TABLE ONLY public.hodnoceni
    ADD CONSTRAINT hodnoceni_pkey PRIMARY KEY (id);
 B   ALTER TABLE ONLY public.hodnoceni DROP CONSTRAINT hodnoceni_pkey;
       public            postgres    false    209            �           2606    16443    komentare komentare_pkey 
   CONSTRAINT     V   ALTER TABLE ONLY public.komentare
    ADD CONSTRAINT komentare_pkey PRIMARY KEY (id);
 B   ALTER TABLE ONLY public.komentare DROP CONSTRAINT komentare_pkey;
       public            postgres    false    211            �           2606    16445    odpovedi odpovedi_pkey 
   CONSTRAINT     T   ALTER TABLE ONLY public.odpovedi
    ADD CONSTRAINT odpovedi_pkey PRIMARY KEY (id);
 @   ALTER TABLE ONLY public.odpovedi DROP CONSTRAINT odpovedi_pkey;
       public            postgres    false    213            �           2606    16447    prispevky prispevky_pkey 
   CONSTRAINT     V   ALTER TABLE ONLY public.prispevky
    ADD CONSTRAINT prispevky_pkey PRIMARY KEY (id);
 B   ALTER TABLE ONLY public.prispevky DROP CONSTRAINT prispevky_pkey;
       public            postgres    false    215            �           2606    16449    role role_pkey 
   CONSTRAINT     L   ALTER TABLE ONLY public.role
    ADD CONSTRAINT role_pkey PRIMARY KEY (id);
 8   ALTER TABLE ONLY public.role DROP CONSTRAINT role_pkey;
       public            postgres    false    217            �           2606    16451    uzivatele uzivatele_pkey 
   CONSTRAINT     V   ALTER TABLE ONLY public.uzivatele
    ADD CONSTRAINT uzivatele_pkey PRIMARY KEY (id);
 B   ALTER TABLE ONLY public.uzivatele DROP CONSTRAINT uzivatele_pkey;
       public            postgres    false    219            �           2606    16503 "   uzivatele_role uzivatele_role_pkey 
   CONSTRAINT     r   ALTER TABLE ONLY public.uzivatele_role
    ADD CONSTRAINT uzivatele_role_pkey PRIMARY KEY (role_id, uzivatel_id);
 L   ALTER TABLE ONLY public.uzivatele_role DROP CONSTRAINT uzivatele_role_pkey;
       public            postgres    false    221    221            �           1259    16452    fki_komentare_fkey    INDEX     N   CREATE INDEX fki_komentare_fkey ON public.odpovedi USING btree (komentar_id);
 &   DROP INDEX public.fki_komentare_fkey;
       public            postgres    false    213            �           1259    16453    fki_prispevky_fkey    INDEX     P   CREATE INDEX fki_prispevky_fkey ON public.komentare USING btree (prispevek_id);
 &   DROP INDEX public.fki_prispevky_fkey;
       public            postgres    false    211            �           1259    16454    fki_roles_fkey    INDEX     L   CREATE INDEX fki_roles_fkey ON public.uzivatele_role USING btree (role_id);
 "   DROP INDEX public.fki_roles_fkey;
       public            postgres    false    221            �           1259    16455    fki_users_fkey    INDEX     P   CREATE INDEX fki_users_fkey ON public.uzivatele_role USING btree (uzivatel_id);
 "   DROP INDEX public.fki_users_fkey;
       public            postgres    false    221            �           1259    16456    fki_uzivatele_fkey    INDEX     O   CREATE INDEX fki_uzivatele_fkey ON public.komentare USING btree (uzivatel_id);
 &   DROP INDEX public.fki_uzivatele_fkey;
       public            postgres    false    211            �           1259    32867    idx_prispevky    INDEX     K   CREATE UNIQUE INDEX idx_prispevky ON public.prispevky USING btree (obsah);
 !   DROP INDEX public.idx_prispevky;
       public            postgres    false    215            �           2620    32883    uzivatele uzivatele_change    TRIGGER     |   CREATE TRIGGER uzivatele_change BEFORE UPDATE ON public.uzivatele FOR EACH ROW EXECUTE FUNCTION public.uzivatele_changes();
 3   DROP TRIGGER uzivatele_change ON public.uzivatele;
       public          postgres    false    219    239            �           2606    16457    odpovedi komentare_fkey    FK CONSTRAINT     ~   ALTER TABLE ONLY public.odpovedi
    ADD CONSTRAINT komentare_fkey FOREIGN KEY (komentar_id) REFERENCES public.komentare(id);
 A   ALTER TABLE ONLY public.odpovedi DROP CONSTRAINT komentare_fkey;
       public          postgres    false    213    211    3222            �           2606    16462    komentare prispevky_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.komentare
    ADD CONSTRAINT prispevky_fkey FOREIGN KEY (prispevek_id) REFERENCES public.prispevky(id);
 B   ALTER TABLE ONLY public.komentare DROP CONSTRAINT prispevky_fkey;
       public          postgres    false    211    215    3228            �           2606    16467    hodnoceni prispevky_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.hodnoceni
    ADD CONSTRAINT prispevky_fkey FOREIGN KEY (prispevek_id) REFERENCES public.prispevky(id);
 B   ALTER TABLE ONLY public.hodnoceni DROP CONSTRAINT prispevky_fkey;
       public          postgres    false    209    3228    215            �           2606    16472    uzivatele_role role_fkey    FK CONSTRAINT     v   ALTER TABLE ONLY public.uzivatele_role
    ADD CONSTRAINT role_fkey FOREIGN KEY (role_id) REFERENCES public.role(id);
 B   ALTER TABLE ONLY public.uzivatele_role DROP CONSTRAINT role_fkey;
       public          postgres    false    217    221    3230            �           2606    16477    uzivatele_role uzivatele_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.uzivatele_role
    ADD CONSTRAINT uzivatele_fkey FOREIGN KEY (uzivatel_id) REFERENCES public.uzivatele(id);
 G   ALTER TABLE ONLY public.uzivatele_role DROP CONSTRAINT uzivatele_fkey;
       public          postgres    false    219    3232    221            �           2606    16482    prispevky uzivatele_fkey    FK CONSTRAINT        ALTER TABLE ONLY public.prispevky
    ADD CONSTRAINT uzivatele_fkey FOREIGN KEY (uzivatel_id) REFERENCES public.uzivatele(id);
 B   ALTER TABLE ONLY public.prispevky DROP CONSTRAINT uzivatele_fkey;
       public          postgres    false    3232    215    219            �           2606    16487    komentare uzivatele_fkey    FK CONSTRAINT        ALTER TABLE ONLY public.komentare
    ADD CONSTRAINT uzivatele_fkey FOREIGN KEY (uzivatel_id) REFERENCES public.uzivatele(id);
 B   ALTER TABLE ONLY public.komentare DROP CONSTRAINT uzivatele_fkey;
       public          postgres    false    219    211    3232            �           2606    16492    odpovedi uzivatele_fkey    FK CONSTRAINT     ~   ALTER TABLE ONLY public.odpovedi
    ADD CONSTRAINT uzivatele_fkey FOREIGN KEY (uzivatel_id) REFERENCES public.uzivatele(id);
 A   ALTER TABLE ONLY public.odpovedi DROP CONSTRAINT uzivatele_fkey;
       public          postgres    false    213    3232    219            �           2606    16497    hodnoceni uzivatele_fkey    FK CONSTRAINT        ALTER TABLE ONLY public.hodnoceni
    ADD CONSTRAINT uzivatele_fkey FOREIGN KEY (uzivatel_id) REFERENCES public.uzivatele(id);
 B   ALTER TABLE ONLY public.hodnoceni DROP CONSTRAINT uzivatele_fkey;
       public          postgres    false    209    219    3232            <   e  x�5�Y��0E�o����a/��u��@TR�t*1�`��^��eY[M��q:{��إ5]�e��ʭ�4=8����q�Gk��wp>�)Lgm\��z`�m�q�9/?_�)CI:7�N%����ۦ���pvV��汜�jyvG��.]p��[؀|�ԅ���|�!7r�P�C���m��6!Ee��$hR�׎����ʵZ�mj�@���8�:ՙ� ���g�+�eq��ڰ�J�
Z8� ,EX`>BTA �u���e��*HY�xá|�R4�*l���!��t iЌO�ј4���^t�2�{�X�f�ԴiE m�T������mFK���w@t��5-!DK��FC�l�"*�bHm�ŐX_Ő�I^�/eKK\��w(�H_���haz��Q�c=��/@��jR}I�F_R�Kj�'婔��$�ח�-y�4��o�h��͢�E�-/�Q=l>�h��1^����Q_��˱3��A��� ������٭x��C���ep���Γ����$��0Z��֙YC���<���1��%%|\�<a�/k����i��F&�F�������?��/H�d�� A�H��s�C�6�����������      >   �  x�eV=o�F��_q����zO�d	XJ\Y�6� E�͐�C��!Aa�*[�\l@j����s�O��
��̝{�=��ٝ&�]�}�����˽��;������7�vnK��K.�i��ì���LV��cC�,�R�܇,�^%�S��hF2��K���A���*$��v�����V��o����0Hj��\f*�Qi��$���LO�d�yX�ü�ã$/��բq4������%�|�Z�����iA8E�ˑ����k{�l���,�)�Q�2�NMP/"Fq�0�C�L7$��Z2~��JTiYb1bk�����n/#lgɏ�<̊j/yE�@&�ro]F7�XT�2���)��#��3��(���|����1H$ �'^Y��0������Oy_J����Q; w\�B_c�0#,��u'J�U-BPK�Α�$�<)}��� �E�9�SpC#8d�Je{��t90��S����
2��L0��%��C8��tk[l*Ԇ&�!�n�L��"�:�����2����&��8���j[|��M�=O�8�o���L�q�v<�u�]O'��������/3d�y�� [�2j1�)5�/��u� ß�������Do?|�LV�rF��p;� �B�D	���$y�`�l�~C�v�uJ��EY���`��z��]?O!�]�N?��-EWZeh�cS����N�����]F�
nT>�K#T�N
�(��9�M~�F �-p��u�4d����W�d�f+�@ꌾ��(R�h5����(�ŝ�Qm���t�"E]�,�_� �i�s4,f�BK�ʾ�Я��&�zp�:�X?����gǘČj-[�![�O��GGH���G������DO��GQ�XTK׷A�+[7�g��K#��fe~�	�]�34����O=r�~�<�L.PX��h
�}' �*-~���F����qxd� B����=�4�Yf6#n}�_<�����:�_�T��|��@B�0�GՌ�A�d胫#����.��p�Г����ګ�~��e���3B�
�����[���	rl�QV�,=g��%��o�4g���+�ɾ+��vp����x�#��a0�b��كR�y�9@����z�� �I`o�&�V˰6g�]�hE˓PF��/�k?�w�mO/�Ge�Z�ز3Nph���aun6�����$<]� ��L��|���}��T�g7f�H�<K��v��<�>��yV6�P)�LCF�
�y�C|���H�ߤg��]r� F���F�l�x8��QSQ��}�6�fo�w(�� �JΝ����Jѯ����%�-NP"���!����Ѯe�b�Q�t���o��]hƘ�`N��y�\��Z5�A����/N���+A��/ �Ձ��+Bq��?�`(VY+�sM�5z�� Z�e �W����(�c ��}e�˵�������G�y/��e�CC�6f�  Ciy��9���	�D�f�#��������q{�4Ā�����	4y,%�hx(CĞKCi���=�-�9/~l�2և{�[y�\�dन�93I��l4��@l��M�}�����·�a����N�t�e�\%E���.�]���Ύ�|Nw��z:�O�	狝��������e����І�A����BW9����W�s����k������G;O*cLzv�����J���i�?�K]C      @   �  x�mT=o�F���b���(ɲ��n$�)iV��qI.����_��?��JE
��|����+9>�\�3;;�潙-&�'�5��H�����DB�->�Z鶺�^�������*Y�uI|#koz��/���ք�<Z_�Fy���\�*E��9IFHҭ$a�b�q��yΖl�-�G�+�Q�3Cp�{Y�@VJ�����*�4��5R��+�ג|��j��V�k��-�ySoH�ވ@�C8����l-���8$����X+WM �Q.6B��H�&��l:^�l���5{��&&�Ur���W�,���`[��S��V
�5�h��kE�j����&�?�����X�V`j>���	5U�&�Y.��sΦ�2�b?�X|Ռ�:]��Zl���D;>Sw�2>vP>�{D (/�"[���)��5��56�@%[��b�3A@���b�Kv�]���ג��xX����{i��}G�4XӃr�m"���ԛsTLT�J ��o״��H�|P��Ό���6�Eu!�V3��Dm��!]h��Wj��v|�1Q�M�4nm�΢�0��ǘ�� ji@�ʔp�-dU�!ݯ��lx�Ox�KBy��D�e�bή�9����i����4��(�-@��{հbƖٌ���b���8oC�Ӭ�-�{�ExA�/ąJ������=�Wo��[)?c�B%�Wٔ�RO���dBP�n� �y砠��_Y���믺P�(Rˑ�KC��~��26$pL��q0�4�;�.G����3��Gu�E��j�m�P,��q�s���t#Kb7� �J�!��wC�H\{��w-�F}�?|��؇$�V���,,V1ˊ��y ;�"+����:��1]$k�*���ɞfX��/��Wk�Wɚ%��(���̊%kM��K_޸�&�-���@�;4����'���`x�M(�Nppc��s��s���9��`�ո�޸f7��y���t�nޝ�g�����$�����W�e��BW�      B      x��ZM�Gr=�������L��p�yH+�^R��D� � �U�î��,Te��u��Vؓ�`x x�I����d�ߋ��iJ�:��z�+3##^D������/m�`g�1�U?{���L�M��|o���tu��͋ݏ�w���s&��Ɍ��K���4�Po������2S�ԕ��ʴ�p����9m�_زv�_m�ꛟ�c��^qñO6X�
���-/��oM����n�.u�Ɩ�4���*
�}�Q��bYؾ�}������y_��r�k|ɛ��t����u�aS����f�b5�X;lܯ��쮝����#����՟��ϰ����y9���r�p�L�+����'<�Bm6��>�׭6Ǧ��Ň��J�� =~���F�o;�P�4Z�¨ ���6��V��\�l��t���xR�1�tl��ca����v[CQon�<��څT=E�j(�Ү�ׁ�Q+TnɯHP�����:��X�G�EH��a��5N�}�����Y����-~L]]��$*�����v�!�-6r>��w@sR�b�v��'��5�-7 ��^���h�6�߆��X�3�6�ͷy�Z� @����3� 1����巐)@�s�̙U�wxZ�D��^K��UW ʶ²MB�<s�*�M�;�,_����3�`w*��`���]�C"�3�S�S+OuS<���QqVk2q��(�-���X�n�M /8����
��^g�~���pm�2��P�J&�<>tҹ���_J#ԛ[�����|>{�͗_�Ύ�fO-�ZBw<�nߝ=���omFm�]���t�\ܜ�5��2b[X����G{�Z  �,|Z��@�_m�!L�'�eNk�Qq]�ct�'7?؎�D@���>���ڢ3D-M�un�dȹ�꺦��*��;<'��/�D/|�I����s.������v=L0�>DO��_�����ŊL¦�ף��k�%2�e�B��s��腐���u,c_�\V���n|��Ө�c\-����{��)��J��8����eET
���k<2���*_�: �X~	,�i�e.��C�n���YS�C�fk��:E��s�1#3WIh(,���ۊ�Q��+�Ό3/!p����ę��'u�����zu�^���J��۟�����y���ѝL@S�>[�u/rh��mj�Fsa���������8"B��k�3$m(����y�d� �c	0[�Yn)?� >����Tt�Y�XnD�A�����
ZZ�nLkG@k2\.��~cR[`I�s�������		玈��7?����_���g|�$�ǂ"�Ѥr�� h�PJ�j��ܥ+|fuT��@�u�M��z����K�6����JM��@]�F;xB��w��`�'.��3�l���pH��B'\��lV��������6tD���C�FtD�¯�/+�c�����>�5v ��&Ȱ	f���.�-2 �� .�+ #������x(q�x��I0�g�v�@�~U��9^�@�DQ.> f��-Y�	~�xW�"E�j�/h��&�SW���T8D�@�(	�n��YD^�`57_B>|�x���xc�ͧ,���|�¯v�����0 �A�9�#�A"��2k{K.�6���5%"&�f{���Ӡ�^��$P*���Qld�-"�K�Z��ԫ7�נ�ǲW"�l{�8?/�'P�\�ϱ)�i�P�쟝�)�Sƫ��h�Ӹ}I��V`��<�%�1݁<8i���s�_$�*܄��J�d@��RI>�ѵd�B��������X�Xm�-���&N	�����[�=��{WEB�BO��G��.�/Pl�lÈ�uT�S�H�����/L�SK�1��}�ם`ݮ� ��,��5�>0�.����G��y��>vW.��C|2��Bh�G�Eߔ�f���"��ܷo���_W/�����U�׿9{ ��� s�p��ofˣ{��L���r�j�oY��L �@j�� \�� ��ow��9)Q���J6���>��@JB9��)3����RyL�)�^%���^�|!B����+J%�jwᳺ�v��P���SOՒ����5z)P�.�;�r[q�5�Ĺ5��m��*C�)Ӣ�#�H�QH����{��Aj����e�T�":ю���C5V,O���>>T�������aL8�^�,�4�x6!��{��
��J�B�ۢ@֭��Q�W��H2
�$�E������.{[K�$Ş�a�.�S������2�B��H"�U랞hU�yɦz1�c���1k<��0���HT����l�+Cf%.S��2����c�W3VnJz2n��bVt�	ַ���1*Wd�P,17�S8�/��,�k���+<ԡ�q���hQ6E�u�e���,�`\ޚӔ92��j�E� P��� ���Gej!�5,2s���qt��b ͠B4�7k��=�¼�~*���(X�L匄77��C����z�'ڇ	a2@�x%�6%+�"eK-�b�=2�A�!j	Xl6�i�?~�#I���ȧr�3��y�}���6�e:��Y\�"D�\����M;O��~�Y�M�X�],��iyo�x����2�{��cܜ������ghB1�<e~C���"(��NHޮĪ��_���⠮��7.ܽ'N�y+�k�����;�g~�^C>C�<(�5�V�O�/�·ΐ+�sql��erSq����%����7�:/aw�+�|U��I�,=O�`��J}1>�u�ڗ��5C� N�O�mƶ��^���&�a3������ ����͚\�u��L/�����c5�%����O/b�=?z8{�������Ϟ=����U�ƣ�X�^L�\���� �GI�3�ޮ�l�P��B��2�d��}�W���)��:"��g]I�������jVY��{o����ȇ�M*e�~�ڥ�SI͏ҝQ���C)]�T�P;v��[�U_
o:̣���]�Z�.)#�:c�b`PU�^�1"�i*F%K�L'�ǅ�T-�{�|Zp�!C�9��J
lR��1��T�$���ՠk�tפH]��䚰~���s�L�o�z� $@�
�hi<"9O}J-�����AQj��Ӗ�d��\���z�i�����t�d�t�x��O�5�DީQ\�O5�U]��4b�[�,�ɁKߏ�4xYv��P�2����W��!�2�h�5��o���ﾛy�~π��`"m���7C��X>|p�lq���{�o!�d蠡ڟ��	n�O��Q���'����	R#
�:?)�2���W��T��O�ʱ��Um��{�h��=�+Q	ٳ��j�x�}�U��`�����	�I�IVy/���'۷�"PtVjS�}p���P�oJ�pX�A{�i�Is6��Β��w�� ��Q�F8��"(�$^�zĺ#�ة�E�?�>H���ʥ&�<��蔊a��܍�RiD��<��v?�s֮���=#���[(�s=!K�`PT�}6~�m�O��)����F۫��>�r��F'OĪF�����7��(��V4pq8Q`�Y���!a���P/L7A�.v2�
&1���"Ac�5����^2l��U��#����Il�r�Í�X`�u����Ҿ�o�#�F��i"F�2;����������G��Yoj>wl��t`siY�}��J��r�:R:K�ڲƶ0�Tt�;Z�����(
c����*��|&@i�
�7ɫk���EJ�81�H�\++���gD���q����}M���@.s�$�H
�'�y���,6R�l�ܪ�"An6bA(�e��̉oy�t���cR!�f������+7�W"��(_�lq?Oh]\��}a�a3�o�V��m*Z-'��ɪ̥�����ղ�i��U��k�s� ��4n�&����Yp��8��f:��g�[�˻Bg�c}�F���K����E9L�z���M<��s�������1*�ˀ
���Xm'�p�T�O0����r�C��xR��4 �  9;��o���Q��[<0�S�GW�D9')�FDtL8[��^:�:�ei"ɷH�M�RG!�'����"SP��E`�<޷{�/ɑܮs���Vڙ��%���j>�>��\xP�N nqk�sz�hzN ���w����o�"S�c��@!�I;�$�4N�dp	E�5X���l��:v��S��9�dx�sԃ�	uG�e�8���q�$�:�O�����.$��3s:�d���x~��_F0,�Y1���穩$�p]�S��P��o\�k�ͭ�&��J%�j�
f�;���"Ї��Z*s$@���rq�tt�2�_G��` ��$|l���N����Xl3�$%�c#����Lm�h7u�A����}U�N��}����Dha":Oe}�:� ���BKx�լm㌃q���>����yæB��فVF"��٥���q�Hb��#����� �Gz�Qa�B bcc�$&��a���6Vs���BOS�ӣ�9g��X�L�D�]�>�i�m��n�[l���S,�I�ҵ��S�y��A~��r��	�%Na�+��I��c#<2��צȍ�f��(����Ҋ����I�	7��\E��H�G���g���_��/��9FRۍ6T&r���,66�K�	��� �$v��,?�|� <�C�D��)d�����(+ڷ���IN���A6L]��N�IJ��|cER���s��|�B��2+�������c��?�w�:�Wc"F(퓒_�}��K����/-�<�|xy�c���Z�<<�;�/l�H��s}��;62K�V��Gˣ���k0p���Y�$��\���u�yv�U>�<)��|�$(�t"o�H�)o��.Χ�~1��Nˁ�����|ÎV����+�E��@֡/��9�R�K��b0)��)���<|_������ȭ��}�~2$F�+�ǚq_�v��qI��Ӂ%CK���r�@�]�B���D6�؝�w�T��ws&�>���/�L�F��^��N��T��󵔢R�鴼pq������l���@�9��'Z~a��M�Ц���p����bW�餭4�5)9D�p���;G˻�W$Xy�]��aNc)���j���^���#��k�����Ƣz~~�z���<���q(k}Q��~���ԯ��5�)��ݏ�N��2'T��m�k����6<����`\%BŮ@�5ޢ��0���|�$z�NZ ��K���-$;�)�:��+}/O��&�BH�)��Mֲ�m�OFr<C
��`C;p� �=cՒrV��jw�o�����X�-�}B���3"�K����At�Ns�Ku*E��Tˑ�^Q������HPX�� �U�bňEӥ
(�h-��k��2C�}yi@�}�Q�䦩9Ή�-���g��2���A�_.��Z�ISan>�^~�oM�d�b��4X�i+p��H2��T�wq��MQ�u^�eB<�k�Yp��2:��ӅYp�3�����`8�U��nV}�,�Ez?Έ���|y�����־�UNO��O���fg����lg������PgYg��F��)������\��d~�����&6����������C
cE�Mzp$��y���oh ����"}`^��Yz����Yroqy/9���?t�g���nf���`y��������%�NgP`��
;���72)y�w�������Wp      D   4   x�3�,��,K,I��2���OI-J,�/�2�LL����2��/�K-����� A4      F   |  x��V�nk9\�|�!�%��!��Hj�c;�f�맜��=A��^������*���o�Ë~�y3�k�5����m��Zk�(/�)�Hu&Y#7U�=��)h6bѶ�z��E��]/��qћneQ�"�5�M��c��9M�y�V�����dep���[X����5�|����|`��]���7���z�L9%դ\��L� �J=��j��t�)k^�:�ȝ�W���ڷ�=oǃ__�����&)c��,^�%��ZZZ3��ySI�]Z�R�Kβ�����Ϫn�z����������4����4̨�2*l�(azٝ$�٪IK�\k�b��k7+�>�o�K��:���o���^�{kk�e]X�j©�XUj���4J9���v�m;����tx�;���:�7�{L�f�V���DYZ�+�uHm99C�>�w����x�������pҳ�mX��NKvɉyt!j�2:<�$�u�k�el�(�X�`�^�vS��^�M7M�vOX�����XrZcE#�=�u��'%�E0�l#"�)l���QP�n��
[�$�`��iA���*L0o����V/��A#{7��&�Y`�q���.����۬��21ģy`�rX8��ץ��"�Jyv�uzD[�9vX��1��q�����||��Z��FP��l؎�-���u� �Y�����dF����oh�/X�ѯϟLe{���<|�-N[����X�6�L�Tt���`���2�φ|�!ēG�-վ{����+-�oS�A3��SG��#˰�����9���C�PE�H��X|����oh?����A}�0;�o��np�����"M���&��"�0gX)��(˦2*�.��ÿ��Uж��ק���tl6���>f���s�l+��1��k6^h3C�4G�0�u���w�����|��9���q.ˡ.�¤,]*��O�PS�A�}�p���+9h�����h������ڠ�@�gڳ#�Gqњט�X�ε��kQ�,�$Up��b�(����vM�}u�z�И��E�7k��f�`��u� |�^5Z��cr^ ��!u}���K�^q��q�]A�~�62FG0(����l���D�bhTG,W�5\>;������C�{kV�zR���7$�'eӬ !��D�i�d���
�k��8�9�zFh�0�l��qO�s�e�{I��
U�{�-���r��J#G)
�sS�A�������9�0���J��{�o�"X����ݤ/���k�Q� m�j�GwK�d��s��Ӽk���lp$/���D�cU���}�,��$Y�68!Qj��-���G*�'�nve��[<}Q0�3���8j(�cTPd�������
�d2Y������ڶO�OĽ��~�s��o�����~G���s���9�8<<<��V      J   �   x�M�1r!��N��A���F ��퍋M��ǩ����̓ ��8���wR�V��]�|-�&����e֎�5�6�Z��`[�\|����c�c=�uO�0#�3�3�6,J&�1���Ϻ����@.2�dD��GJ�V'6q��ej�m ��<H���h�j{�.��~��|���	h��$�*]�G�1�vH�      H   S   x����@B�RL&��lzI�u<��T��b�0�34���P7�^�kK#�em뱎���M1&b2����-e���M}Q�. ?�u[     