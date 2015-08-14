--
-- PostgreSQL database dump
--

SET statement_timeout = 0;
SET lock_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SET check_function_bodies = false;
SET client_min_messages = warning;

--
-- Name: plpgsql; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS plpgsql WITH SCHEMA pg_catalog;


--
-- Name: EXTENSION plpgsql; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION plpgsql IS 'PL/pgSQL procedural language';


--
-- Name: pg_trgm; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS pg_trgm WITH SCHEMA public;


--
-- Name: EXTENSION pg_trgm; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION pg_trgm IS 'text similarity measurement and index searching based on trigrams';


SET search_path = public, pg_catalog;

SET default_tablespace = '';

SET default_with_oids = false;

--
-- Name: activities; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE activities (
    id integer NOT NULL,
    trackable_id integer,
    trackable_type character varying,
    owner_id integer,
    owner_type character varying,
    key character varying,
    parameters text,
    recipient_id integer,
    recipient_type character varying,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: activities_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE activities_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: activities_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE activities_id_seq OWNED BY activities.id;


--
-- Name: attachments; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE attachments (
    id integer NOT NULL,
    file character varying,
    title character varying,
    description text,
    parent_id integer,
    parent_type character varying,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    content_type character varying,
    file_size integer,
    author_user_id integer
);


--
-- Name: attachments_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE attachments_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: attachments_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE attachments_id_seq OWNED BY attachments.id;


--
-- Name: badges_sashes; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE badges_sashes (
    id integer NOT NULL,
    badge_id integer,
    sash_id integer,
    notified_user boolean DEFAULT false,
    created_at timestamp without time zone
);


--
-- Name: badges_sashes_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE badges_sashes_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: badges_sashes_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE badges_sashes_id_seq OWNED BY badges_sashes.id;


--
-- Name: bookmarks; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE bookmarks (
    id integer NOT NULL,
    bookmarkable_id integer,
    bookmarkable_type character varying,
    user_id integer,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: bookmarks_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE bookmarks_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: bookmarks_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE bookmarks_id_seq OWNED BY bookmarks.id;


--
-- Name: bv_mappings; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE bv_mappings (
    id integer NOT NULL,
    bv_name character varying,
    plz character varying,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: bv_mappings_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE bv_mappings_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: bv_mappings_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE bv_mappings_id_seq OWNED BY bv_mappings.id;


--
-- Name: comments; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE comments (
    id integer NOT NULL,
    text text,
    author_user_id integer,
    commentable_type character varying,
    commentable_id integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: comments_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE comments_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: comments_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE comments_id_seq OWNED BY comments.id;


--
-- Name: dag_links; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE dag_links (
    id integer NOT NULL,
    ancestor_id integer,
    ancestor_type character varying,
    descendant_id integer,
    descendant_type character varying,
    direct boolean,
    count integer,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    valid_to timestamp without time zone,
    valid_from timestamp without time zone
);


--
-- Name: dag_links_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE dag_links_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: dag_links_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE dag_links_id_seq OWNED BY dag_links.id;


--
-- Name: events; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE events (
    id integer NOT NULL,
    name character varying,
    description text,
    start_at timestamp without time zone,
    end_at timestamp without time zone,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    location character varying,
    publish_on_global_website boolean,
    publish_on_local_website boolean
);


--
-- Name: events_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE events_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: events_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE events_id_seq OWNED BY events.id;


--
-- Name: flags; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE flags (
    id integer NOT NULL,
    key character varying,
    flagable_id integer,
    flagable_type character varying,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: flags_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE flags_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: flags_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE flags_id_seq OWNED BY flags.id;


--
-- Name: geo_locations; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE geo_locations (
    id integer NOT NULL,
    address character varying,
    latitude double precision,
    longitude double precision,
    country character varying,
    country_code character varying,
    city character varying,
    postal_code character varying,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    queried_at timestamp without time zone,
    street character varying,
    state character varying
);


--
-- Name: geo_locations_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE geo_locations_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: geo_locations_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE geo_locations_id_seq OWNED BY geo_locations.id;


--
-- Name: groups; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE groups (
    id integer NOT NULL,
    name character varying,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    token character varying,
    extensive_name character varying,
    internal_token character varying,
    body text,
    type character varying
);


--
-- Name: groups_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE groups_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: groups_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE groups_id_seq OWNED BY groups.id;


--
-- Name: issues; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE issues (
    id integer NOT NULL,
    title character varying,
    description character varying,
    reference_id integer,
    reference_type character varying,
    resolved_at timestamp without time zone,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    responsible_admin_id integer
);


--
-- Name: issues_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE issues_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: issues_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE issues_id_seq OWNED BY issues.id;


--
-- Name: last_seen_activities; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE last_seen_activities (
    id integer NOT NULL,
    user_id integer,
    description character varying,
    link_to_object_id integer,
    link_to_object_type character varying,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: last_seen_activities_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE last_seen_activities_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: last_seen_activities_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE last_seen_activities_id_seq OWNED BY last_seen_activities.id;


--
-- Name: mentions; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE mentions (
    id integer NOT NULL,
    who_user_id integer,
    whom_user_id integer,
    reference_type character varying,
    reference_id integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: mentions_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE mentions_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: mentions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE mentions_id_seq OWNED BY mentions.id;


--
-- Name: merit_actions; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE merit_actions (
    id integer NOT NULL,
    user_id integer,
    action_method character varying,
    action_value integer,
    had_errors boolean DEFAULT false,
    target_model character varying,
    target_id integer,
    target_data text,
    processed boolean DEFAULT false,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: merit_actions_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE merit_actions_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: merit_actions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE merit_actions_id_seq OWNED BY merit_actions.id;


--
-- Name: merit_activity_logs; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE merit_activity_logs (
    id integer NOT NULL,
    action_id integer,
    related_change_type character varying,
    related_change_id integer,
    description character varying,
    created_at timestamp without time zone
);


--
-- Name: merit_activity_logs_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE merit_activity_logs_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: merit_activity_logs_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE merit_activity_logs_id_seq OWNED BY merit_activity_logs.id;


--
-- Name: merit_score_points; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE merit_score_points (
    id integer NOT NULL,
    score_id integer,
    num_points integer DEFAULT 0,
    log character varying,
    created_at timestamp without time zone
);


--
-- Name: merit_score_points_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE merit_score_points_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: merit_score_points_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE merit_score_points_id_seq OWNED BY merit_score_points.id;


--
-- Name: merit_scores; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE merit_scores (
    id integer NOT NULL,
    sash_id integer,
    category character varying DEFAULT 'default'::character varying
);


--
-- Name: merit_scores_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE merit_scores_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: merit_scores_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE merit_scores_id_seq OWNED BY merit_scores.id;


--
-- Name: nav_nodes; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE nav_nodes (
    id integer NOT NULL,
    url_component character varying,
    breadcrumb_item character varying,
    menu_item character varying,
    slim_breadcrumb boolean,
    slim_url boolean,
    slim_menu boolean,
    hidden_menu boolean,
    navable_id integer,
    navable_type character varying,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: nav_nodes_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE nav_nodes_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: nav_nodes_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE nav_nodes_id_seq OWNED BY nav_nodes.id;


--
-- Name: notifications; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE notifications (
    id integer NOT NULL,
    recipient_id integer,
    author_id integer,
    reference_url character varying,
    reference_type character varying,
    reference_id integer,
    message character varying,
    text text,
    sent_at timestamp without time zone,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    read_at timestamp without time zone
);


--
-- Name: notifications_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE notifications_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: notifications_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE notifications_id_seq OWNED BY notifications.id;


--
-- Name: pages; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE pages (
    id integer NOT NULL,
    title character varying,
    content text,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    redirect_to character varying,
    author_user_id integer,
    type character varying
);


--
-- Name: pages_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE pages_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: pages_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE pages_id_seq OWNED BY pages.id;


--
-- Name: posts; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE posts (
    id integer NOT NULL,
    subject character varying,
    text text,
    group_id integer,
    author_user_id integer,
    external_author character varying,
    sent_at timestamp without time zone,
    sticky boolean,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    entire_message text,
    message_id character varying,
    content_type character varying
);


--
-- Name: posts_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE posts_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: posts_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE posts_id_seq OWNED BY posts.id;


--
-- Name: profile_fields; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE profile_fields (
    id integer NOT NULL,
    profileable_id integer,
    label character varying,
    type character varying,
    value text,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    profileable_type character varying,
    parent_id integer
);


--
-- Name: profile_fields_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE profile_fields_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: profile_fields_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE profile_fields_id_seq OWNED BY profile_fields.id;


--
-- Name: relationships; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE relationships (
    id integer NOT NULL,
    name character varying,
    user1_id integer,
    user2_id integer,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: relationships_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE relationships_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: relationships_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE relationships_id_seq OWNED BY relationships.id;


--
-- Name: sashes; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE sashes (
    id integer NOT NULL,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: sashes_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE sashes_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: sashes_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE sashes_id_seq OWNED BY sashes.id;


--
-- Name: schema_migrations; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE schema_migrations (
    version character varying NOT NULL
);


--
-- Name: settings; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE settings (
    id integer NOT NULL,
    var character varying NOT NULL,
    value text,
    thing_id integer,
    thing_type character varying,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: settings_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE settings_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: settings_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE settings_id_seq OWNED BY settings.id;


--
-- Name: status_group_membership_infos; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE status_group_membership_infos (
    id integer NOT NULL,
    membership_id integer,
    promoted_by_workflow_id integer,
    promoted_on_event_id integer,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: status_group_membership_infos_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE status_group_membership_infos_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: status_group_membership_infos_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE status_group_membership_infos_id_seq OWNED BY status_group_membership_infos.id;


--
-- Name: user_accounts; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE user_accounts (
    id integer NOT NULL,
    encrypted_password character varying DEFAULT ''::character varying NOT NULL,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    user_id integer,
    reset_password_token character varying,
    reset_password_sent_at timestamp without time zone,
    remember_created_at timestamp without time zone,
    sign_in_count integer DEFAULT 0,
    current_sign_in_at timestamp without time zone,
    last_sign_in_at timestamp without time zone,
    current_sign_in_ip character varying,
    last_sign_in_ip character varying,
    auth_token character varying
);


--
-- Name: user_accounts_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE user_accounts_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: user_accounts_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE user_accounts_id_seq OWNED BY user_accounts.id;


--
-- Name: users; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE users (
    id integer NOT NULL,
    alias character varying,
    first_name character varying,
    last_name character varying,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    female boolean,
    accepted_terms character varying,
    accepted_terms_at timestamp without time zone,
    incognito boolean,
    avatar_id character varying,
    notification_policy character varying,
    locale character varying,
    sash_id integer,
    level integer DEFAULT 0
);


--
-- Name: users_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE users_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: users_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE users_id_seq OWNED BY users.id;


--
-- Name: workflow_kit_parameters; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE workflow_kit_parameters (
    id integer NOT NULL,
    key character varying,
    value character varying,
    parameterable_id integer,
    parameterable_type character varying,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: workflow_kit_parameters_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE workflow_kit_parameters_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: workflow_kit_parameters_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE workflow_kit_parameters_id_seq OWNED BY workflow_kit_parameters.id;


--
-- Name: workflow_kit_steps; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE workflow_kit_steps (
    id integer NOT NULL,
    sequence_index integer,
    workflow_id integer,
    brick_name character varying,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: workflow_kit_steps_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE workflow_kit_steps_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: workflow_kit_steps_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE workflow_kit_steps_id_seq OWNED BY workflow_kit_steps.id;


--
-- Name: workflow_kit_workflows; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE workflow_kit_workflows (
    id integer NOT NULL,
    name character varying,
    description character varying,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: workflow_kit_workflows_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE workflow_kit_workflows_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: workflow_kit_workflows_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE workflow_kit_workflows_id_seq OWNED BY workflow_kit_workflows.id;


--
-- Name: workflows; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE workflows (
    id integer NOT NULL,
    name character varying,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: workflows_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE workflows_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: workflows_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE workflows_id_seq OWNED BY workflows.id;


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY activities ALTER COLUMN id SET DEFAULT nextval('activities_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY attachments ALTER COLUMN id SET DEFAULT nextval('attachments_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY badges_sashes ALTER COLUMN id SET DEFAULT nextval('badges_sashes_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY bookmarks ALTER COLUMN id SET DEFAULT nextval('bookmarks_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY bv_mappings ALTER COLUMN id SET DEFAULT nextval('bv_mappings_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY comments ALTER COLUMN id SET DEFAULT nextval('comments_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY dag_links ALTER COLUMN id SET DEFAULT nextval('dag_links_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY events ALTER COLUMN id SET DEFAULT nextval('events_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY flags ALTER COLUMN id SET DEFAULT nextval('flags_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY geo_locations ALTER COLUMN id SET DEFAULT nextval('geo_locations_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY groups ALTER COLUMN id SET DEFAULT nextval('groups_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY issues ALTER COLUMN id SET DEFAULT nextval('issues_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY last_seen_activities ALTER COLUMN id SET DEFAULT nextval('last_seen_activities_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY mentions ALTER COLUMN id SET DEFAULT nextval('mentions_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY merit_actions ALTER COLUMN id SET DEFAULT nextval('merit_actions_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY merit_activity_logs ALTER COLUMN id SET DEFAULT nextval('merit_activity_logs_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY merit_score_points ALTER COLUMN id SET DEFAULT nextval('merit_score_points_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY merit_scores ALTER COLUMN id SET DEFAULT nextval('merit_scores_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY nav_nodes ALTER COLUMN id SET DEFAULT nextval('nav_nodes_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY notifications ALTER COLUMN id SET DEFAULT nextval('notifications_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY pages ALTER COLUMN id SET DEFAULT nextval('pages_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY posts ALTER COLUMN id SET DEFAULT nextval('posts_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY profile_fields ALTER COLUMN id SET DEFAULT nextval('profile_fields_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY relationships ALTER COLUMN id SET DEFAULT nextval('relationships_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY sashes ALTER COLUMN id SET DEFAULT nextval('sashes_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY settings ALTER COLUMN id SET DEFAULT nextval('settings_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY status_group_membership_infos ALTER COLUMN id SET DEFAULT nextval('status_group_membership_infos_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY user_accounts ALTER COLUMN id SET DEFAULT nextval('user_accounts_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY users ALTER COLUMN id SET DEFAULT nextval('users_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY workflow_kit_parameters ALTER COLUMN id SET DEFAULT nextval('workflow_kit_parameters_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY workflow_kit_steps ALTER COLUMN id SET DEFAULT nextval('workflow_kit_steps_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY workflow_kit_workflows ALTER COLUMN id SET DEFAULT nextval('workflow_kit_workflows_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY workflows ALTER COLUMN id SET DEFAULT nextval('workflows_id_seq'::regclass);


--
-- Name: activities_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY activities
    ADD CONSTRAINT activities_pkey PRIMARY KEY (id);


--
-- Name: attachments_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY attachments
    ADD CONSTRAINT attachments_pkey PRIMARY KEY (id);


--
-- Name: badges_sashes_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY badges_sashes
    ADD CONSTRAINT badges_sashes_pkey PRIMARY KEY (id);


--
-- Name: bookmarks_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY bookmarks
    ADD CONSTRAINT bookmarks_pkey PRIMARY KEY (id);


--
-- Name: bv_mappings_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY bv_mappings
    ADD CONSTRAINT bv_mappings_pkey PRIMARY KEY (id);


--
-- Name: comments_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY comments
    ADD CONSTRAINT comments_pkey PRIMARY KEY (id);


--
-- Name: dag_links_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY dag_links
    ADD CONSTRAINT dag_links_pkey PRIMARY KEY (id);


--
-- Name: events_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY events
    ADD CONSTRAINT events_pkey PRIMARY KEY (id);


--
-- Name: flags_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY flags
    ADD CONSTRAINT flags_pkey PRIMARY KEY (id);


--
-- Name: geo_locations_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY geo_locations
    ADD CONSTRAINT geo_locations_pkey PRIMARY KEY (id);


--
-- Name: groups_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY groups
    ADD CONSTRAINT groups_pkey PRIMARY KEY (id);


--
-- Name: issues_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY issues
    ADD CONSTRAINT issues_pkey PRIMARY KEY (id);


--
-- Name: last_seen_activities_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY last_seen_activities
    ADD CONSTRAINT last_seen_activities_pkey PRIMARY KEY (id);


--
-- Name: mentions_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY mentions
    ADD CONSTRAINT mentions_pkey PRIMARY KEY (id);


--
-- Name: merit_actions_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY merit_actions
    ADD CONSTRAINT merit_actions_pkey PRIMARY KEY (id);


--
-- Name: merit_activity_logs_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY merit_activity_logs
    ADD CONSTRAINT merit_activity_logs_pkey PRIMARY KEY (id);


--
-- Name: merit_score_points_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY merit_score_points
    ADD CONSTRAINT merit_score_points_pkey PRIMARY KEY (id);


--
-- Name: merit_scores_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY merit_scores
    ADD CONSTRAINT merit_scores_pkey PRIMARY KEY (id);


--
-- Name: nav_nodes_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY nav_nodes
    ADD CONSTRAINT nav_nodes_pkey PRIMARY KEY (id);


--
-- Name: notifications_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY notifications
    ADD CONSTRAINT notifications_pkey PRIMARY KEY (id);


--
-- Name: pages_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY pages
    ADD CONSTRAINT pages_pkey PRIMARY KEY (id);


--
-- Name: posts_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY posts
    ADD CONSTRAINT posts_pkey PRIMARY KEY (id);


--
-- Name: profile_fields_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY profile_fields
    ADD CONSTRAINT profile_fields_pkey PRIMARY KEY (id);


--
-- Name: relationships_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY relationships
    ADD CONSTRAINT relationships_pkey PRIMARY KEY (id);


--
-- Name: sashes_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY sashes
    ADD CONSTRAINT sashes_pkey PRIMARY KEY (id);


--
-- Name: settings_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY settings
    ADD CONSTRAINT settings_pkey PRIMARY KEY (id);


--
-- Name: status_group_membership_infos_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY status_group_membership_infos
    ADD CONSTRAINT status_group_membership_infos_pkey PRIMARY KEY (id);


--
-- Name: user_accounts_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY user_accounts
    ADD CONSTRAINT user_accounts_pkey PRIMARY KEY (id);


--
-- Name: users_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id);


--
-- Name: workflow_kit_parameters_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY workflow_kit_parameters
    ADD CONSTRAINT workflow_kit_parameters_pkey PRIMARY KEY (id);


--
-- Name: workflow_kit_steps_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY workflow_kit_steps
    ADD CONSTRAINT workflow_kit_steps_pkey PRIMARY KEY (id);


--
-- Name: workflow_kit_workflows_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY workflow_kit_workflows
    ADD CONSTRAINT workflow_kit_workflows_pkey PRIMARY KEY (id);


--
-- Name: workflows_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY workflows
    ADD CONSTRAINT workflows_pkey PRIMARY KEY (id);


--
-- Name: dag_ancestor; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX dag_ancestor ON dag_links USING btree (ancestor_id, ancestor_type, direct);


--
-- Name: dag_descendant; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX dag_descendant ON dag_links USING btree (descendant_id, descendant_type);


--
-- Name: flagable; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX flagable ON flags USING btree (flagable_id, flagable_type);


--
-- Name: flagable_key; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX flagable_key ON flags USING btree (flagable_id, flagable_type, key);


--
-- Name: index_activities_on_owner_id_and_owner_type; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_activities_on_owner_id_and_owner_type ON activities USING btree (owner_id, owner_type);


--
-- Name: index_activities_on_recipient_id_and_recipient_type; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_activities_on_recipient_id_and_recipient_type ON activities USING btree (recipient_id, recipient_type);


--
-- Name: index_activities_on_trackable_id_and_trackable_type; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_activities_on_trackable_id_and_trackable_type ON activities USING btree (trackable_id, trackable_type);


--
-- Name: index_badges_sashes_on_badge_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_badges_sashes_on_badge_id ON badges_sashes USING btree (badge_id);


--
-- Name: index_badges_sashes_on_badge_id_and_sash_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_badges_sashes_on_badge_id_and_sash_id ON badges_sashes USING btree (badge_id, sash_id);


--
-- Name: index_badges_sashes_on_sash_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_badges_sashes_on_sash_id ON badges_sashes USING btree (sash_id);


--
-- Name: index_geo_locations_on_address; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_geo_locations_on_address ON geo_locations USING btree (address);


--
-- Name: index_mentions_on_whom_user_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_mentions_on_whom_user_id ON mentions USING btree (whom_user_id);


--
-- Name: index_settings_on_thing_type_and_thing_id_and_var; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_settings_on_thing_type_and_thing_id_and_var ON settings USING btree (thing_type, thing_id, var);


--
-- Name: index_user_accounts_on_reset_password_token; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_user_accounts_on_reset_password_token ON user_accounts USING btree (reset_password_token);


--
-- Name: key; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX key ON flags USING btree (key);


--
-- Name: navable_type; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX navable_type ON nav_nodes USING btree (navable_id, navable_type);


--
-- Name: profileable; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX profileable ON profile_fields USING btree (profileable_id, profileable_type);


--
-- Name: profileable_type; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX profileable_type ON profile_fields USING btree (profileable_id, profileable_type, type);


--
-- Name: type; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX type ON profile_fields USING btree (type);


--
-- Name: unique_schema_migrations; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX unique_schema_migrations ON schema_migrations USING btree (version);


--
-- Name: attachments_author_user_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY attachments
    ADD CONSTRAINT attachments_author_user_id_fk FOREIGN KEY (author_user_id) REFERENCES users(id);


--
-- Name: bookmarks_user_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY bookmarks
    ADD CONSTRAINT bookmarks_user_id_fk FOREIGN KEY (user_id) REFERENCES users(id);


--
-- Name: last_seen_activities_user_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY last_seen_activities
    ADD CONSTRAINT last_seen_activities_user_id_fk FOREIGN KEY (user_id) REFERENCES users(id);


--
-- Name: pages_author_user_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY pages
    ADD CONSTRAINT pages_author_user_id_fk FOREIGN KEY (author_user_id) REFERENCES users(id);


--
-- Name: posts_author_user_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY posts
    ADD CONSTRAINT posts_author_user_id_fk FOREIGN KEY (author_user_id) REFERENCES users(id);


--
-- Name: posts_group_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY posts
    ADD CONSTRAINT posts_group_id_fk FOREIGN KEY (group_id) REFERENCES groups(id);


--
-- Name: profile_fields_parent_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY profile_fields
    ADD CONSTRAINT profile_fields_parent_id_fk FOREIGN KEY (parent_id) REFERENCES profile_fields(id);


--
-- Name: relationships_user1_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY relationships
    ADD CONSTRAINT relationships_user1_id_fk FOREIGN KEY (user1_id) REFERENCES users(id);


--
-- Name: relationships_user2_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY relationships
    ADD CONSTRAINT relationships_user2_id_fk FOREIGN KEY (user2_id) REFERENCES users(id);


--
-- Name: user_accounts_user_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY user_accounts
    ADD CONSTRAINT user_accounts_user_id_fk FOREIGN KEY (user_id) REFERENCES users(id);


--
-- Name: workflow_kit_steps_workflow_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY workflow_kit_steps
    ADD CONSTRAINT workflow_kit_steps_workflow_id_fk FOREIGN KEY (workflow_id) REFERENCES workflow_kit_workflows(id);


--
-- PostgreSQL database dump complete
--

SET search_path TO "$user",public;

INSERT INTO schema_migrations (version) VALUES ('20120403002734');

INSERT INTO schema_migrations (version) VALUES ('20120403011601');

INSERT INTO schema_migrations (version) VALUES ('20120403161549');

INSERT INTO schema_migrations (version) VALUES ('20120405222050');

INSERT INTO schema_migrations (version) VALUES ('20120406225409');

INSERT INTO schema_migrations (version) VALUES ('20120425161138');

INSERT INTO schema_migrations (version) VALUES ('20120425162644');

INSERT INTO schema_migrations (version) VALUES ('20120426023322');

INSERT INTO schema_migrations (version) VALUES ('20120426043315');

INSERT INTO schema_migrations (version) VALUES ('20120426043542');

INSERT INTO schema_migrations (version) VALUES ('20120426090436');

INSERT INTO schema_migrations (version) VALUES ('20120427021934');

INSERT INTO schema_migrations (version) VALUES ('20120427044338');

INSERT INTO schema_migrations (version) VALUES ('20120427150156');

INSERT INTO schema_migrations (version) VALUES ('20120506073852');

INSERT INTO schema_migrations (version) VALUES ('20120507165551');

INSERT INTO schema_migrations (version) VALUES ('20120508130729');

INSERT INTO schema_migrations (version) VALUES ('20120508152233');

INSERT INTO schema_migrations (version) VALUES ('20120508201550');

INSERT INTO schema_migrations (version) VALUES ('20120511090234');

INSERT INTO schema_migrations (version) VALUES ('20120701115059');

INSERT INTO schema_migrations (version) VALUES ('20120710193308');

INSERT INTO schema_migrations (version) VALUES ('20120713102445');

INSERT INTO schema_migrations (version) VALUES ('20120722005022');

INSERT INTO schema_migrations (version) VALUES ('20120722005023');

INSERT INTO schema_migrations (version) VALUES ('20120722005024');

INSERT INTO schema_migrations (version) VALUES ('20120723165226');

INSERT INTO schema_migrations (version) VALUES ('20120811141703');

INSERT INTO schema_migrations (version) VALUES ('20120814101052');

INSERT INTO schema_migrations (version) VALUES ('20120815205811');

INSERT INTO schema_migrations (version) VALUES ('20120926140743');

INSERT INTO schema_migrations (version) VALUES ('20120928211931');

INSERT INTO schema_migrations (version) VALUES ('20121011001151');

INSERT INTO schema_migrations (version) VALUES ('20130118215712');

INSERT INTO schema_migrations (version) VALUES ('20130118222319');

INSERT INTO schema_migrations (version) VALUES ('20130118225427');

INSERT INTO schema_migrations (version) VALUES ('20130207215239');

INSERT INTO schema_migrations (version) VALUES ('20130209204705');

INSERT INTO schema_migrations (version) VALUES ('20130220185631');

INSERT INTO schema_migrations (version) VALUES ('20130309193623');

INSERT INTO schema_migrations (version) VALUES ('20130310004016');

INSERT INTO schema_migrations (version) VALUES ('20130310004842');

INSERT INTO schema_migrations (version) VALUES ('20130313211728');

INSERT INTO schema_migrations (version) VALUES ('20130313234644');

INSERT INTO schema_migrations (version) VALUES ('20130314011831');

INSERT INTO schema_migrations (version) VALUES ('20130315072837');

INSERT INTO schema_migrations (version) VALUES ('20130315073719');

INSERT INTO schema_migrations (version) VALUES ('20130320003141');

INSERT INTO schema_migrations (version) VALUES ('20130320011252');

INSERT INTO schema_migrations (version) VALUES ('20130329231902');

INSERT INTO schema_migrations (version) VALUES ('20130404223828');

INSERT INTO schema_migrations (version) VALUES ('20130409193040');

INSERT INTO schema_migrations (version) VALUES ('20130908011259');

INSERT INTO schema_migrations (version) VALUES ('20131115130631');

INSERT INTO schema_migrations (version) VALUES ('20140611170614');

INSERT INTO schema_migrations (version) VALUES ('20140808223512');

INSERT INTO schema_migrations (version) VALUES ('20141008101813');

INSERT INTO schema_migrations (version) VALUES ('20141010130457');

INSERT INTO schema_migrations (version) VALUES ('20141010134300');

INSERT INTO schema_migrations (version) VALUES ('20141018143449');

INSERT INTO schema_migrations (version) VALUES ('20141018221751');

INSERT INTO schema_migrations (version) VALUES ('20141102224044');

INSERT INTO schema_migrations (version) VALUES ('20141110193937');

INSERT INTO schema_migrations (version) VALUES ('20141202140522');

INSERT INTO schema_migrations (version) VALUES ('20141209161946');

INSERT INTO schema_migrations (version) VALUES ('20150127013842');

INSERT INTO schema_migrations (version) VALUES ('20150129194501');

INSERT INTO schema_migrations (version) VALUES ('20150305235708');

INSERT INTO schema_migrations (version) VALUES ('20150314174008');

INSERT INTO schema_migrations (version) VALUES ('20150505222900');

INSERT INTO schema_migrations (version) VALUES ('20150518140212');

INSERT INTO schema_migrations (version) VALUES ('20150518150522');

INSERT INTO schema_migrations (version) VALUES ('20150518222832');

INSERT INTO schema_migrations (version) VALUES ('20150518222833');

INSERT INTO schema_migrations (version) VALUES ('20150523111623');

INSERT INTO schema_migrations (version) VALUES ('20150523130544');

INSERT INTO schema_migrations (version) VALUES ('20150527151038');

INSERT INTO schema_migrations (version) VALUES ('20150530224106');

INSERT INTO schema_migrations (version) VALUES ('20150619215357');

INSERT INTO schema_migrations (version) VALUES ('20150707230008');

INSERT INTO schema_migrations (version) VALUES ('20150707230009');

INSERT INTO schema_migrations (version) VALUES ('20150707230010');

INSERT INTO schema_migrations (version) VALUES ('20150707230011');

INSERT INTO schema_migrations (version) VALUES ('20150707230012');

INSERT INTO schema_migrations (version) VALUES ('20150707230013');

INSERT INTO schema_migrations (version) VALUES ('20150729230534');

