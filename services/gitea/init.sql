-- Adminer 4.8.1 PostgreSQL 14.4 dump

\connect "gitea";

DROP TABLE IF EXISTS "access";
DROP SEQUENCE IF EXISTS access_id_seq;
CREATE SEQUENCE access_id_seq INCREMENT 1 MINVALUE 1 MAXVALUE 9223372036854775807 CACHE 1;

CREATE TABLE "public"."access" (
    "id" bigint DEFAULT nextval('access_id_seq') NOT NULL,
    "user_id" bigint,
    "repo_id" bigint,
    "mode" integer,
    CONSTRAINT "UQE_access_s" UNIQUE ("user_id", "repo_id"),
    CONSTRAINT "access_pkey" PRIMARY KEY ("id")
) WITH (oids = false);


DROP TABLE IF EXISTS "access_token";
DROP SEQUENCE IF EXISTS access_token_id_seq;
CREATE SEQUENCE access_token_id_seq INCREMENT 1 MINVALUE 1 MAXVALUE 9223372036854775807 CACHE 1;

CREATE TABLE "public"."access_token" (
    "id" bigint DEFAULT nextval('access_token_id_seq') NOT NULL,
    "uid" bigint,
    "name" character varying(255),
    "token_hash" character varying(255),
    "token_salt" character varying(255),
    "token_last_eight" character varying(255),
    "created_unix" bigint,
    "updated_unix" bigint,
    CONSTRAINT "UQE_access_token_token_hash" UNIQUE ("token_hash"),
    CONSTRAINT "access_token_pkey" PRIMARY KEY ("id")
) WITH (oids = false);

CREATE INDEX "IDX_access_token_created_unix" ON "public"."access_token" USING btree ("created_unix");

CREATE INDEX "IDX_access_token_uid" ON "public"."access_token" USING btree ("uid");

CREATE INDEX "IDX_access_token_updated_unix" ON "public"."access_token" USING btree ("updated_unix");


DROP TABLE IF EXISTS "action";
DROP SEQUENCE IF EXISTS action_id_seq;
CREATE SEQUENCE action_id_seq INCREMENT 1 MINVALUE 1 MAXVALUE 9223372036854775807 CACHE 1;

CREATE TABLE "public"."action" (
    "id" bigint DEFAULT nextval('action_id_seq') NOT NULL,
    "user_id" bigint,
    "op_type" integer,
    "act_user_id" bigint,
    "repo_id" bigint,
    "comment_id" bigint,
    "is_deleted" boolean DEFAULT false NOT NULL,
    "ref_name" character varying(255),
    "is_private" boolean DEFAULT false NOT NULL,
    "content" text,
    "created_unix" bigint,
    CONSTRAINT "action_pkey" PRIMARY KEY ("id")
) WITH (oids = false);

CREATE INDEX "IDX_action_act_user_id" ON "public"."action" USING btree ("act_user_id");

CREATE INDEX "IDX_action_comment_id" ON "public"."action" USING btree ("comment_id");

CREATE INDEX "IDX_action_created_unix" ON "public"."action" USING btree ("created_unix");

CREATE INDEX "IDX_action_is_deleted" ON "public"."action" USING btree ("is_deleted");

CREATE INDEX "IDX_action_is_private" ON "public"."action" USING btree ("is_private");

CREATE INDEX "IDX_action_repo_id" ON "public"."action" USING btree ("repo_id");

CREATE INDEX "IDX_action_user_id" ON "public"."action" USING btree ("user_id");


DROP TABLE IF EXISTS "attachment";
DROP SEQUENCE IF EXISTS attachment_id_seq;
CREATE SEQUENCE attachment_id_seq INCREMENT 1 MINVALUE 1 MAXVALUE 9223372036854775807 CACHE 1;

CREATE TABLE "public"."attachment" (
    "id" bigint DEFAULT nextval('attachment_id_seq') NOT NULL,
    "uuid" uuid,
    "issue_id" bigint,
    "release_id" bigint,
    "uploader_id" bigint DEFAULT '0',
    "comment_id" bigint,
    "name" character varying(255),
    "download_count" bigint DEFAULT '0',
    "size" bigint DEFAULT '0',
    "created_unix" bigint,
    CONSTRAINT "UQE_attachment_uuid" UNIQUE ("uuid"),
    CONSTRAINT "attachment_pkey" PRIMARY KEY ("id")
) WITH (oids = false);

CREATE INDEX "IDX_attachment_issue_id" ON "public"."attachment" USING btree ("issue_id");

CREATE INDEX "IDX_attachment_release_id" ON "public"."attachment" USING btree ("release_id");

CREATE INDEX "IDX_attachment_uploader_id" ON "public"."attachment" USING btree ("uploader_id");


DROP TABLE IF EXISTS "collaboration";
DROP SEQUENCE IF EXISTS collaboration_id_seq;
CREATE SEQUENCE collaboration_id_seq INCREMENT 1 MINVALUE 1 MAXVALUE 9223372036854775807 CACHE 1;

CREATE TABLE "public"."collaboration" (
    "id" bigint DEFAULT nextval('collaboration_id_seq') NOT NULL,
    "repo_id" bigint NOT NULL,
    "user_id" bigint NOT NULL,
    "mode" integer DEFAULT '2' NOT NULL,
    CONSTRAINT "UQE_collaboration_s" UNIQUE ("repo_id", "user_id"),
    CONSTRAINT "collaboration_pkey" PRIMARY KEY ("id")
) WITH (oids = false);

CREATE INDEX "IDX_collaboration_repo_id" ON "public"."collaboration" USING btree ("repo_id");

CREATE INDEX "IDX_collaboration_user_id" ON "public"."collaboration" USING btree ("user_id");


DROP TABLE IF EXISTS "comment";
DROP SEQUENCE IF EXISTS comment_id_seq;
CREATE SEQUENCE comment_id_seq INCREMENT 1 MINVALUE 1 MAXVALUE 9223372036854775807 CACHE 1;

CREATE TABLE "public"."comment" (
    "id" bigint DEFAULT nextval('comment_id_seq') NOT NULL,
    "type" integer,
    "poster_id" bigint,
    "original_author" character varying(255),
    "original_author_id" bigint,
    "issue_id" bigint,
    "label_id" bigint,
    "old_milestone_id" bigint,
    "milestone_id" bigint,
    "assignee_id" bigint,
    "removed_assignee" boolean,
    "resolve_doer_id" bigint,
    "old_title" character varying(255),
    "new_title" character varying(255),
    "old_ref" character varying(255),
    "new_ref" character varying(255),
    "dependent_issue_id" bigint,
    "commit_id" bigint,
    "line" bigint,
    "tree_path" character varying(255),
    "content" text,
    "patch" text,
    "created_unix" bigint,
    "updated_unix" bigint,
    "commit_sha" character varying(40),
    "review_id" bigint,
    "invalidated" boolean,
    "ref_repo_id" bigint,
    "ref_issue_id" bigint,
    "ref_comment_id" bigint,
    "ref_action" smallint,
    "ref_is_pull" boolean,
    CONSTRAINT "comment_pkey" PRIMARY KEY ("id")
) WITH (oids = false);

CREATE INDEX "IDX_comment_created_unix" ON "public"."comment" USING btree ("created_unix");

CREATE INDEX "IDX_comment_issue_id" ON "public"."comment" USING btree ("issue_id");

CREATE INDEX "IDX_comment_poster_id" ON "public"."comment" USING btree ("poster_id");

CREATE INDEX "IDX_comment_ref_comment_id" ON "public"."comment" USING btree ("ref_comment_id");

CREATE INDEX "IDX_comment_ref_issue_id" ON "public"."comment" USING btree ("ref_issue_id");

CREATE INDEX "IDX_comment_ref_repo_id" ON "public"."comment" USING btree ("ref_repo_id");

CREATE INDEX "IDX_comment_review_id" ON "public"."comment" USING btree ("review_id");

CREATE INDEX "IDX_comment_type" ON "public"."comment" USING btree ("type");

CREATE INDEX "IDX_comment_updated_unix" ON "public"."comment" USING btree ("updated_unix");


DROP TABLE IF EXISTS "commit_status";
DROP SEQUENCE IF EXISTS commit_status_id_seq;
CREATE SEQUENCE commit_status_id_seq INCREMENT 1 MINVALUE 1 MAXVALUE 9223372036854775807 CACHE 1;

CREATE TABLE "public"."commit_status" (
    "id" bigint DEFAULT nextval('commit_status_id_seq') NOT NULL,
    "index" bigint,
    "repo_id" bigint,
    "state" character varying(7) NOT NULL,
    "sha" character varying(64) NOT NULL,
    "target_url" text,
    "description" text,
    "context_hash" character(40),
    "context" text,
    "creator_id" bigint,
    "created_unix" bigint,
    "updated_unix" bigint,
    CONSTRAINT "UQE_commit_status_repo_sha_index" UNIQUE ("index", "repo_id", "sha"),
    CONSTRAINT "commit_status_pkey" PRIMARY KEY ("id")
) WITH (oids = false);

CREATE INDEX "IDX_commit_status_context_hash" ON "public"."commit_status" USING btree ("context_hash");

CREATE INDEX "IDX_commit_status_created_unix" ON "public"."commit_status" USING btree ("created_unix");

CREATE INDEX "IDX_commit_status_index" ON "public"."commit_status" USING btree ("index");

CREATE INDEX "IDX_commit_status_repo_id" ON "public"."commit_status" USING btree ("repo_id");

CREATE INDEX "IDX_commit_status_sha" ON "public"."commit_status" USING btree ("sha");

CREATE INDEX "IDX_commit_status_updated_unix" ON "public"."commit_status" USING btree ("updated_unix");


DROP TABLE IF EXISTS "deleted_branch";
DROP SEQUENCE IF EXISTS deleted_branch_id_seq;
CREATE SEQUENCE deleted_branch_id_seq INCREMENT 1 MINVALUE 1 MAXVALUE 9223372036854775807 CACHE 1;

CREATE TABLE "public"."deleted_branch" (
    "id" bigint DEFAULT nextval('deleted_branch_id_seq') NOT NULL,
    "repo_id" bigint NOT NULL,
    "name" character varying(255) NOT NULL,
    "commit" character varying(255) NOT NULL,
    "deleted_by_id" bigint,
    "deleted_unix" bigint,
    CONSTRAINT "UQE_deleted_branch_s" UNIQUE ("repo_id", "name", "commit"),
    CONSTRAINT "deleted_branch_pkey" PRIMARY KEY ("id")
) WITH (oids = false);

CREATE INDEX "IDX_deleted_branch_deleted_by_id" ON "public"."deleted_branch" USING btree ("deleted_by_id");

CREATE INDEX "IDX_deleted_branch_deleted_unix" ON "public"."deleted_branch" USING btree ("deleted_unix");

CREATE INDEX "IDX_deleted_branch_repo_id" ON "public"."deleted_branch" USING btree ("repo_id");


DROP TABLE IF EXISTS "deploy_key";
DROP SEQUENCE IF EXISTS deploy_key_id_seq;
CREATE SEQUENCE deploy_key_id_seq INCREMENT 1 MINVALUE 1 MAXVALUE 9223372036854775807 CACHE 1;

CREATE TABLE "public"."deploy_key" (
    "id" bigint DEFAULT nextval('deploy_key_id_seq') NOT NULL,
    "key_id" bigint,
    "repo_id" bigint,
    "name" character varying(255),
    "fingerprint" character varying(255),
    "mode" integer DEFAULT '1' NOT NULL,
    "created_unix" bigint,
    "updated_unix" bigint,
    CONSTRAINT "UQE_deploy_key_s" UNIQUE ("key_id", "repo_id"),
    CONSTRAINT "deploy_key_pkey" PRIMARY KEY ("id")
) WITH (oids = false);

CREATE INDEX "IDX_deploy_key_key_id" ON "public"."deploy_key" USING btree ("key_id");

CREATE INDEX "IDX_deploy_key_repo_id" ON "public"."deploy_key" USING btree ("repo_id");


DROP TABLE IF EXISTS "email_address";
DROP SEQUENCE IF EXISTS email_address_id_seq;
CREATE SEQUENCE email_address_id_seq INCREMENT 1 MINVALUE 1 MAXVALUE 9223372036854775807 CACHE 1;

CREATE TABLE "public"."email_address" (
    "id" bigint DEFAULT nextval('email_address_id_seq') NOT NULL,
    "uid" bigint NOT NULL,
    "email" character varying(255) NOT NULL,
    "is_activated" boolean,
    CONSTRAINT "UQE_email_address_email" UNIQUE ("email"),
    CONSTRAINT "email_address_pkey" PRIMARY KEY ("id")
) WITH (oids = false);

CREATE INDEX "IDX_email_address_uid" ON "public"."email_address" USING btree ("uid");


DROP TABLE IF EXISTS "email_hash";
CREATE TABLE "public"."email_hash" (
    "hash" character varying(32) NOT NULL,
    "email" character varying(255) NOT NULL,
    CONSTRAINT "UQE_email_hash_email" UNIQUE ("email"),
    CONSTRAINT "email_hash_pkey" PRIMARY KEY ("hash")
) WITH (oids = false);


DROP TABLE IF EXISTS "external_login_user";
CREATE TABLE "public"."external_login_user" (
    "external_id" character varying(255) NOT NULL,
    "user_id" bigint NOT NULL,
    "login_source_id" bigint NOT NULL,
    "raw_data" json,
    "provider" character varying(25),
    "email" character varying(255),
    "name" character varying(255),
    "first_name" character varying(255),
    "last_name" character varying(255),
    "nick_name" character varying(255),
    "description" character varying(255),
    "avatar_url" character varying(255),
    "location" character varying(255),
    "access_token" text,
    "access_token_secret" text,
    "refresh_token" text,
    "expires_at" timestamp,
    CONSTRAINT "external_login_user_pkey" PRIMARY KEY ("external_id", "login_source_id")
) WITH (oids = false);

CREATE INDEX "IDX_external_login_user_provider" ON "public"."external_login_user" USING btree ("provider");

CREATE INDEX "IDX_external_login_user_user_id" ON "public"."external_login_user" USING btree ("user_id");


DROP TABLE IF EXISTS "follow";
DROP SEQUENCE IF EXISTS follow_id_seq;
CREATE SEQUENCE follow_id_seq INCREMENT 1 MINVALUE 1 MAXVALUE 9223372036854775807 CACHE 1;

CREATE TABLE "public"."follow" (
    "id" bigint DEFAULT nextval('follow_id_seq') NOT NULL,
    "user_id" bigint,
    "follow_id" bigint,
    CONSTRAINT "UQE_follow_follow" UNIQUE ("user_id", "follow_id"),
    CONSTRAINT "follow_pkey" PRIMARY KEY ("id")
) WITH (oids = false);


DROP TABLE IF EXISTS "gpg_key";
DROP SEQUENCE IF EXISTS gpg_key_id_seq;
CREATE SEQUENCE gpg_key_id_seq INCREMENT 1 MINVALUE 1 MAXVALUE 9223372036854775807 CACHE 1;

CREATE TABLE "public"."gpg_key" (
    "id" bigint DEFAULT nextval('gpg_key_id_seq') NOT NULL,
    "owner_id" bigint NOT NULL,
    "key_id" character(16) NOT NULL,
    "primary_key_id" character(16),
    "content" text NOT NULL,
    "created_unix" bigint,
    "expired_unix" bigint,
    "added_unix" bigint,
    "emails" text,
    "can_sign" boolean,
    "can_encrypt_comms" boolean,
    "can_encrypt_storage" boolean,
    "can_certify" boolean,
    CONSTRAINT "gpg_key_pkey" PRIMARY KEY ("id")
) WITH (oids = false);

CREATE INDEX "IDX_gpg_key_key_id" ON "public"."gpg_key" USING btree ("key_id");

CREATE INDEX "IDX_gpg_key_owner_id" ON "public"."gpg_key" USING btree ("owner_id");


DROP TABLE IF EXISTS "gpg_key_import";
CREATE TABLE "public"."gpg_key_import" (
    "key_id" character(16) NOT NULL,
    "content" text NOT NULL,
    CONSTRAINT "gpg_key_import_pkey" PRIMARY KEY ("key_id")
) WITH (oids = false);


DROP TABLE IF EXISTS "hook_task";
DROP SEQUENCE IF EXISTS hook_task_id_seq;
CREATE SEQUENCE hook_task_id_seq INCREMENT 1 MINVALUE 1 MAXVALUE 9223372036854775807 CACHE 1;

CREATE TABLE "public"."hook_task" (
    "id" bigint DEFAULT nextval('hook_task_id_seq') NOT NULL,
    "repo_id" bigint,
    "hook_id" bigint,
    "uuid" character varying(255),
    "type" integer,
    "url" text,
    "signature" text,
    "payload_content" text,
    "http_method" character varying(255),
    "content_type" integer,
    "event_type" character varying(255),
    "is_ssl" boolean,
    "is_delivered" boolean,
    "delivered" bigint,
    "is_succeed" boolean,
    "request_content" text,
    "response_content" text,
    CONSTRAINT "hook_task_pkey" PRIMARY KEY ("id")
) WITH (oids = false);

CREATE INDEX "IDX_hook_task_repo_id" ON "public"."hook_task" USING btree ("repo_id");


DROP TABLE IF EXISTS "issue";
DROP SEQUENCE IF EXISTS issue_id_seq;
CREATE SEQUENCE issue_id_seq INCREMENT 1 MINVALUE 1 MAXVALUE 9223372036854775807 CACHE 1;

CREATE TABLE "public"."issue" (
    "id" bigint DEFAULT nextval('issue_id_seq') NOT NULL,
    "repo_id" bigint,
    "index" bigint,
    "poster_id" bigint,
    "original_author" character varying(255),
    "original_author_id" bigint,
    "name" character varying(255),
    "content" text,
    "milestone_id" bigint,
    "priority" integer,
    "is_closed" boolean,
    "is_pull" boolean,
    "num_comments" integer,
    "ref" character varying(255),
    "deadline_unix" bigint,
    "created_unix" bigint,
    "updated_unix" bigint,
    "closed_unix" bigint,
    "is_locked" boolean DEFAULT false NOT NULL,
    CONSTRAINT "UQE_issue_repo_index" UNIQUE ("repo_id", "index"),
    CONSTRAINT "issue_pkey" PRIMARY KEY ("id")
) WITH (oids = false);

CREATE INDEX "IDX_issue_closed_unix" ON "public"."issue" USING btree ("closed_unix");

CREATE INDEX "IDX_issue_created_unix" ON "public"."issue" USING btree ("created_unix");

CREATE INDEX "IDX_issue_deadline_unix" ON "public"."issue" USING btree ("deadline_unix");

CREATE INDEX "IDX_issue_is_closed" ON "public"."issue" USING btree ("is_closed");

CREATE INDEX "IDX_issue_is_pull" ON "public"."issue" USING btree ("is_pull");

CREATE INDEX "IDX_issue_milestone_id" ON "public"."issue" USING btree ("milestone_id");

CREATE INDEX "IDX_issue_original_author_id" ON "public"."issue" USING btree ("original_author_id");

CREATE INDEX "IDX_issue_poster_id" ON "public"."issue" USING btree ("poster_id");

CREATE INDEX "IDX_issue_repo_id" ON "public"."issue" USING btree ("repo_id");

CREATE INDEX "IDX_issue_updated_unix" ON "public"."issue" USING btree ("updated_unix");


DROP TABLE IF EXISTS "issue_assignees";
DROP SEQUENCE IF EXISTS issue_assignees_id_seq;
CREATE SEQUENCE issue_assignees_id_seq INCREMENT 1 MINVALUE 1 MAXVALUE 9223372036854775807 CACHE 1;

CREATE TABLE "public"."issue_assignees" (
    "id" bigint DEFAULT nextval('issue_assignees_id_seq') NOT NULL,
    "assignee_id" bigint,
    "issue_id" bigint,
    CONSTRAINT "issue_assignees_pkey" PRIMARY KEY ("id")
) WITH (oids = false);

CREATE INDEX "IDX_issue_assignees_assignee_id" ON "public"."issue_assignees" USING btree ("assignee_id");

CREATE INDEX "IDX_issue_assignees_issue_id" ON "public"."issue_assignees" USING btree ("issue_id");


DROP TABLE IF EXISTS "issue_dependency";
DROP SEQUENCE IF EXISTS issue_dependency_id_seq;
CREATE SEQUENCE issue_dependency_id_seq INCREMENT 1 MINVALUE 1 MAXVALUE 9223372036854775807 CACHE 1;

CREATE TABLE "public"."issue_dependency" (
    "id" bigint DEFAULT nextval('issue_dependency_id_seq') NOT NULL,
    "user_id" bigint NOT NULL,
    "issue_id" bigint NOT NULL,
    "dependency_id" bigint NOT NULL,
    "created_unix" bigint,
    "updated_unix" bigint,
    CONSTRAINT "UQE_issue_dependency_issue_dependency" UNIQUE ("issue_id", "dependency_id"),
    CONSTRAINT "issue_dependency_pkey" PRIMARY KEY ("id")
) WITH (oids = false);


DROP TABLE IF EXISTS "issue_label";
DROP SEQUENCE IF EXISTS issue_label_id_seq;
CREATE SEQUENCE issue_label_id_seq INCREMENT 1 MINVALUE 1 MAXVALUE 9223372036854775807 CACHE 1;

CREATE TABLE "public"."issue_label" (
    "id" bigint DEFAULT nextval('issue_label_id_seq') NOT NULL,
    "issue_id" bigint,
    "label_id" bigint,
    CONSTRAINT "UQE_issue_label_s" UNIQUE ("issue_id", "label_id"),
    CONSTRAINT "issue_label_pkey" PRIMARY KEY ("id")
) WITH (oids = false);


DROP TABLE IF EXISTS "issue_user";
DROP SEQUENCE IF EXISTS issue_user_id_seq;
CREATE SEQUENCE issue_user_id_seq INCREMENT 1 MINVALUE 1 MAXVALUE 9223372036854775807 CACHE 1;

CREATE TABLE "public"."issue_user" (
    "id" bigint DEFAULT nextval('issue_user_id_seq') NOT NULL,
    "uid" bigint,
    "issue_id" bigint,
    "is_read" boolean,
    "is_mentioned" boolean,
    CONSTRAINT "issue_user_pkey" PRIMARY KEY ("id")
) WITH (oids = false);

CREATE INDEX "IDX_issue_user_uid" ON "public"."issue_user" USING btree ("uid");


DROP TABLE IF EXISTS "issue_watch";
DROP SEQUENCE IF EXISTS issue_watch_id_seq;
CREATE SEQUENCE issue_watch_id_seq INCREMENT 1 MINVALUE 1 MAXVALUE 9223372036854775807 CACHE 1;

CREATE TABLE "public"."issue_watch" (
    "id" bigint DEFAULT nextval('issue_watch_id_seq') NOT NULL,
    "user_id" bigint NOT NULL,
    "issue_id" bigint NOT NULL,
    "is_watching" boolean NOT NULL,
    "created_unix" bigint NOT NULL,
    "updated_unix" bigint NOT NULL,
    CONSTRAINT "UQE_issue_watch_watch" UNIQUE ("user_id", "issue_id"),
    CONSTRAINT "issue_watch_pkey" PRIMARY KEY ("id")
) WITH (oids = false);


DROP TABLE IF EXISTS "label";
DROP SEQUENCE IF EXISTS label_id_seq;
CREATE SEQUENCE label_id_seq INCREMENT 1 MINVALUE 1 MAXVALUE 9223372036854775807 CACHE 1;

CREATE TABLE "public"."label" (
    "id" bigint DEFAULT nextval('label_id_seq') NOT NULL,
    "repo_id" bigint,
    "org_id" bigint,
    "name" character varying(255),
    "description" character varying(255),
    "color" character varying(7),
    "num_issues" integer,
    "num_closed_issues" integer,
    CONSTRAINT "label_pkey" PRIMARY KEY ("id")
) WITH (oids = false);

CREATE INDEX "IDX_label_org_id" ON "public"."label" USING btree ("org_id");

CREATE INDEX "IDX_label_repo_id" ON "public"."label" USING btree ("repo_id");


DROP TABLE IF EXISTS "language_stat";
DROP SEQUENCE IF EXISTS language_stat_id_seq;
CREATE SEQUENCE language_stat_id_seq INCREMENT 1 MINVALUE 1 MAXVALUE 9223372036854775807 CACHE 1;

CREATE TABLE "public"."language_stat" (
    "id" bigint DEFAULT nextval('language_stat_id_seq') NOT NULL,
    "repo_id" bigint NOT NULL,
    "commit_id" character varying(255),
    "is_primary" boolean,
    "language" character varying(30) NOT NULL,
    "size" bigint DEFAULT '0' NOT NULL,
    "created_unix" bigint,
    CONSTRAINT "UQE_language_stat_s" UNIQUE ("repo_id", "language"),
    CONSTRAINT "language_stat_pkey" PRIMARY KEY ("id")
) WITH (oids = false);

CREATE INDEX "IDX_language_stat_created_unix" ON "public"."language_stat" USING btree ("created_unix");

CREATE INDEX "IDX_language_stat_language" ON "public"."language_stat" USING btree ("language");

CREATE INDEX "IDX_language_stat_repo_id" ON "public"."language_stat" USING btree ("repo_id");


DROP TABLE IF EXISTS "lfs_lock";
DROP SEQUENCE IF EXISTS lfs_lock_id_seq;
CREATE SEQUENCE lfs_lock_id_seq INCREMENT 1 MINVALUE 1 MAXVALUE 9223372036854775807 CACHE 1;

CREATE TABLE "public"."lfs_lock" (
    "id" bigint DEFAULT nextval('lfs_lock_id_seq') NOT NULL,
    "repo_id" bigint NOT NULL,
    "owner_id" bigint NOT NULL,
    "path" text,
    "created" timestamp,
    CONSTRAINT "lfs_lock_pkey" PRIMARY KEY ("id")
) WITH (oids = false);

CREATE INDEX "IDX_lfs_lock_owner_id" ON "public"."lfs_lock" USING btree ("owner_id");

CREATE INDEX "IDX_lfs_lock_repo_id" ON "public"."lfs_lock" USING btree ("repo_id");


DROP TABLE IF EXISTS "lfs_meta_object";
DROP SEQUENCE IF EXISTS lfs_meta_object_id_seq;
CREATE SEQUENCE lfs_meta_object_id_seq INCREMENT 1 MINVALUE 1 MAXVALUE 9223372036854775807 CACHE 1;

CREATE TABLE "public"."lfs_meta_object" (
    "id" bigint DEFAULT nextval('lfs_meta_object_id_seq') NOT NULL,
    "oid" character varying(255) NOT NULL,
    "size" bigint NOT NULL,
    "repository_id" bigint NOT NULL,
    "created_unix" bigint,
    CONSTRAINT "UQE_lfs_meta_object_s" UNIQUE ("oid", "repository_id"),
    CONSTRAINT "lfs_meta_object_pkey" PRIMARY KEY ("id")
) WITH (oids = false);

CREATE INDEX "IDX_lfs_meta_object_oid" ON "public"."lfs_meta_object" USING btree ("oid");

CREATE INDEX "IDX_lfs_meta_object_repository_id" ON "public"."lfs_meta_object" USING btree ("repository_id");


DROP TABLE IF EXISTS "login_source";
DROP SEQUENCE IF EXISTS login_source_id_seq;
CREATE SEQUENCE login_source_id_seq INCREMENT 1 MINVALUE 1 MAXVALUE 9223372036854775807 CACHE 1;

CREATE TABLE "public"."login_source" (
    "id" bigint DEFAULT nextval('login_source_id_seq') NOT NULL,
    "type" integer,
    "name" character varying(255),
    "is_actived" boolean DEFAULT false NOT NULL,
    "is_sync_enabled" boolean DEFAULT false NOT NULL,
    "cfg" text,
    "created_unix" bigint,
    "updated_unix" bigint,
    CONSTRAINT "UQE_login_source_name" UNIQUE ("name"),
    CONSTRAINT "login_source_pkey" PRIMARY KEY ("id")
) WITH (oids = false);

CREATE INDEX "IDX_login_source_created_unix" ON "public"."login_source" USING btree ("created_unix");

CREATE INDEX "IDX_login_source_is_actived" ON "public"."login_source" USING btree ("is_actived");

CREATE INDEX "IDX_login_source_is_sync_enabled" ON "public"."login_source" USING btree ("is_sync_enabled");

CREATE INDEX "IDX_login_source_updated_unix" ON "public"."login_source" USING btree ("updated_unix");


DROP TABLE IF EXISTS "milestone";
DROP SEQUENCE IF EXISTS milestone_id_seq;
CREATE SEQUENCE milestone_id_seq INCREMENT 1 MINVALUE 1 MAXVALUE 9223372036854775807 CACHE 1;

CREATE TABLE "public"."milestone" (
    "id" bigint DEFAULT nextval('milestone_id_seq') NOT NULL,
    "repo_id" bigint,
    "name" character varying(255),
    "content" text,
    "is_closed" boolean,
    "num_issues" integer,
    "num_closed_issues" integer,
    "completeness" integer,
    "deadline_unix" bigint,
    "closed_date_unix" bigint,
    CONSTRAINT "milestone_pkey" PRIMARY KEY ("id")
) WITH (oids = false);

CREATE INDEX "IDX_milestone_repo_id" ON "public"."milestone" USING btree ("repo_id");


DROP TABLE IF EXISTS "mirror";
DROP SEQUENCE IF EXISTS mirror_id_seq;
CREATE SEQUENCE mirror_id_seq INCREMENT 1 MINVALUE 1 MAXVALUE 9223372036854775807 CACHE 1;

CREATE TABLE "public"."mirror" (
    "id" bigint DEFAULT nextval('mirror_id_seq') NOT NULL,
    "repo_id" bigint,
    "interval" bigint,
    "enable_prune" boolean DEFAULT true NOT NULL,
    "updated_unix" bigint,
    "next_update_unix" bigint,
    CONSTRAINT "mirror_pkey" PRIMARY KEY ("id")
) WITH (oids = false);

CREATE INDEX "IDX_mirror_next_update_unix" ON "public"."mirror" USING btree ("next_update_unix");

CREATE INDEX "IDX_mirror_repo_id" ON "public"."mirror" USING btree ("repo_id");

CREATE INDEX "IDX_mirror_updated_unix" ON "public"."mirror" USING btree ("updated_unix");


DROP TABLE IF EXISTS "notice";
DROP SEQUENCE IF EXISTS notice_id_seq;
CREATE SEQUENCE notice_id_seq INCREMENT 1 MINVALUE 1 MAXVALUE 9223372036854775807 CACHE 1;

CREATE TABLE "public"."notice" (
    "id" bigint DEFAULT nextval('notice_id_seq') NOT NULL,
    "type" integer,
    "description" text,
    "created_unix" bigint,
    CONSTRAINT "notice_pkey" PRIMARY KEY ("id")
) WITH (oids = false);

CREATE INDEX "IDX_notice_created_unix" ON "public"."notice" USING btree ("created_unix");


DROP TABLE IF EXISTS "notification";
DROP SEQUENCE IF EXISTS notification_id_seq;
CREATE SEQUENCE notification_id_seq INCREMENT 1 MINVALUE 1 MAXVALUE 9223372036854775807 CACHE 1;

CREATE TABLE "public"."notification" (
    "id" bigint DEFAULT nextval('notification_id_seq') NOT NULL,
    "user_id" bigint NOT NULL,
    "repo_id" bigint NOT NULL,
    "status" smallint NOT NULL,
    "source" smallint NOT NULL,
    "issue_id" bigint NOT NULL,
    "commit_id" character varying(255),
    "comment_id" bigint,
    "updated_by" bigint NOT NULL,
    "created_unix" bigint NOT NULL,
    "updated_unix" bigint NOT NULL,
    CONSTRAINT "notification_pkey" PRIMARY KEY ("id")
) WITH (oids = false);

CREATE INDEX "IDX_notification_commit_id" ON "public"."notification" USING btree ("commit_id");

CREATE INDEX "IDX_notification_created_unix" ON "public"."notification" USING btree ("created_unix");

CREATE INDEX "IDX_notification_issue_id" ON "public"."notification" USING btree ("issue_id");

CREATE INDEX "IDX_notification_repo_id" ON "public"."notification" USING btree ("repo_id");

CREATE INDEX "IDX_notification_source" ON "public"."notification" USING btree ("source");

CREATE INDEX "IDX_notification_status" ON "public"."notification" USING btree ("status");

CREATE INDEX "IDX_notification_updated_by" ON "public"."notification" USING btree ("updated_by");

CREATE INDEX "IDX_notification_updated_unix" ON "public"."notification" USING btree ("updated_unix");

CREATE INDEX "IDX_notification_user_id" ON "public"."notification" USING btree ("user_id");


DROP TABLE IF EXISTS "oauth2_application";
DROP SEQUENCE IF EXISTS oauth2_application_id_seq;
CREATE SEQUENCE oauth2_application_id_seq INCREMENT 1 MINVALUE 1 MAXVALUE 9223372036854775807 CACHE 1;

CREATE TABLE "public"."oauth2_application" (
    "id" bigint DEFAULT nextval('oauth2_application_id_seq') NOT NULL,
    "uid" bigint,
    "name" character varying(255),
    "client_id" character varying(255),
    "client_secret" character varying(255),
    "redirect_uris" text,
    "created_unix" bigint,
    "updated_unix" bigint,
    CONSTRAINT "UQE_oauth2_application_client_id" UNIQUE ("client_id"),
    CONSTRAINT "oauth2_application_pkey" PRIMARY KEY ("id")
) WITH (oids = false);

CREATE INDEX "IDX_oauth2_application_created_unix" ON "public"."oauth2_application" USING btree ("created_unix");

CREATE INDEX "IDX_oauth2_application_uid" ON "public"."oauth2_application" USING btree ("uid");

CREATE INDEX "IDX_oauth2_application_updated_unix" ON "public"."oauth2_application" USING btree ("updated_unix");


DROP TABLE IF EXISTS "oauth2_authorization_code";
DROP SEQUENCE IF EXISTS oauth2_authorization_code_id_seq;
CREATE SEQUENCE oauth2_authorization_code_id_seq INCREMENT 1 MINVALUE 1 MAXVALUE 9223372036854775807 CACHE 1;

CREATE TABLE "public"."oauth2_authorization_code" (
    "id" bigint DEFAULT nextval('oauth2_authorization_code_id_seq') NOT NULL,
    "grant_id" bigint,
    "code" character varying(255),
    "code_challenge" character varying(255),
    "code_challenge_method" character varying(255),
    "redirect_uri" character varying(255),
    "valid_until" bigint,
    CONSTRAINT "UQE_oauth2_authorization_code_code" UNIQUE ("code"),
    CONSTRAINT "oauth2_authorization_code_pkey" PRIMARY KEY ("id")
) WITH (oids = false);

CREATE INDEX "IDX_oauth2_authorization_code_valid_until" ON "public"."oauth2_authorization_code" USING btree ("valid_until");


DROP TABLE IF EXISTS "oauth2_grant";
DROP SEQUENCE IF EXISTS oauth2_grant_id_seq;
CREATE SEQUENCE oauth2_grant_id_seq INCREMENT 1 MINVALUE 1 MAXVALUE 9223372036854775807 CACHE 1;

CREATE TABLE "public"."oauth2_grant" (
    "id" bigint DEFAULT nextval('oauth2_grant_id_seq') NOT NULL,
    "user_id" bigint,
    "application_id" bigint,
    "counter" bigint DEFAULT '1' NOT NULL,
    "created_unix" bigint,
    "updated_unix" bigint,
    CONSTRAINT "UQE_oauth2_grant_user_application" UNIQUE ("user_id", "application_id"),
    CONSTRAINT "oauth2_grant_pkey" PRIMARY KEY ("id")
) WITH (oids = false);

CREATE INDEX "IDX_oauth2_grant_application_id" ON "public"."oauth2_grant" USING btree ("application_id");

CREATE INDEX "IDX_oauth2_grant_user_id" ON "public"."oauth2_grant" USING btree ("user_id");


DROP TABLE IF EXISTS "oauth2_session";
CREATE TABLE "public"."oauth2_session" (
    "id" character varying(100) NOT NULL,
    "data" text,
    "created_unix" bigint,
    "updated_unix" bigint,
    "expires_unix" bigint,
    CONSTRAINT "oauth2_session_pkey" PRIMARY KEY ("id")
) WITH (oids = false);

CREATE INDEX "IDX_oauth2_session_expires_unix" ON "public"."oauth2_session" USING btree ("expires_unix");


DROP TABLE IF EXISTS "org_user";
DROP SEQUENCE IF EXISTS org_user_id_seq;
CREATE SEQUENCE org_user_id_seq INCREMENT 1 MINVALUE 1 MAXVALUE 9223372036854775807 CACHE 1;

CREATE TABLE "public"."org_user" (
    "id" bigint DEFAULT nextval('org_user_id_seq') NOT NULL,
    "uid" bigint,
    "org_id" bigint,
    "is_public" boolean,
    CONSTRAINT "UQE_org_user_s" UNIQUE ("uid", "org_id"),
    CONSTRAINT "org_user_pkey" PRIMARY KEY ("id")
) WITH (oids = false);

CREATE INDEX "IDX_org_user_is_public" ON "public"."org_user" USING btree ("is_public");

CREATE INDEX "IDX_org_user_org_id" ON "public"."org_user" USING btree ("org_id");

CREATE INDEX "IDX_org_user_uid" ON "public"."org_user" USING btree ("uid");


DROP TABLE IF EXISTS "protected_branch";
DROP SEQUENCE IF EXISTS protected_branch_id_seq;
CREATE SEQUENCE protected_branch_id_seq INCREMENT 1 MINVALUE 1 MAXVALUE 9223372036854775807 CACHE 1;

CREATE TABLE "public"."protected_branch" (
    "id" bigint DEFAULT nextval('protected_branch_id_seq') NOT NULL,
    "repo_id" bigint,
    "branch_name" character varying(255),
    "can_push" boolean DEFAULT false NOT NULL,
    "enable_whitelist" boolean,
    "whitelist_user_i_ds" text,
    "whitelist_team_i_ds" text,
    "enable_merge_whitelist" boolean DEFAULT false NOT NULL,
    "whitelist_deploy_keys" boolean DEFAULT false NOT NULL,
    "merge_whitelist_user_i_ds" text,
    "merge_whitelist_team_i_ds" text,
    "enable_status_check" boolean DEFAULT false NOT NULL,
    "status_check_contexts" text,
    "enable_approvals_whitelist" boolean DEFAULT false NOT NULL,
    "approvals_whitelist_user_i_ds" text,
    "approvals_whitelist_team_i_ds" text,
    "required_approvals" bigint DEFAULT '0' NOT NULL,
    "block_on_rejected_reviews" boolean DEFAULT false NOT NULL,
    "block_on_outdated_branch" boolean DEFAULT false NOT NULL,
    "dismiss_stale_approvals" boolean DEFAULT false NOT NULL,
    "require_signed_commits" boolean DEFAULT false NOT NULL,
    "protected_file_patterns" text,
    "created_unix" bigint,
    "updated_unix" bigint,
    CONSTRAINT "UQE_protected_branch_s" UNIQUE ("repo_id", "branch_name"),
    CONSTRAINT "protected_branch_pkey" PRIMARY KEY ("id")
) WITH (oids = false);


DROP TABLE IF EXISTS "public_key";
DROP SEQUENCE IF EXISTS public_key_id_seq;
CREATE SEQUENCE public_key_id_seq INCREMENT 1 MINVALUE 1 MAXVALUE 9223372036854775807 CACHE 1;

CREATE TABLE "public"."public_key" (
    "id" bigint DEFAULT nextval('public_key_id_seq') NOT NULL,
    "owner_id" bigint NOT NULL,
    "name" character varying(255) NOT NULL,
    "fingerprint" character varying(255) NOT NULL,
    "content" text NOT NULL,
    "mode" integer DEFAULT '2' NOT NULL,
    "type" integer DEFAULT '1' NOT NULL,
    "login_source_id" bigint DEFAULT '0' NOT NULL,
    "created_unix" bigint,
    "updated_unix" bigint,
    CONSTRAINT "public_key_pkey" PRIMARY KEY ("id")
) WITH (oids = false);

CREATE INDEX "IDX_public_key_fingerprint" ON "public"."public_key" USING btree ("fingerprint");

CREATE INDEX "IDX_public_key_owner_id" ON "public"."public_key" USING btree ("owner_id");


DROP TABLE IF EXISTS "pull_request";
DROP SEQUENCE IF EXISTS pull_request_id_seq;
CREATE SEQUENCE pull_request_id_seq INCREMENT 1 MINVALUE 1 MAXVALUE 9223372036854775807 CACHE 1;

CREATE TABLE "public"."pull_request" (
    "id" bigint DEFAULT nextval('pull_request_id_seq') NOT NULL,
    "type" integer,
    "status" integer,
    "conflicted_files" json,
    "commits_ahead" integer,
    "commits_behind" integer,
    "issue_id" bigint,
    "index" bigint,
    "head_repo_id" bigint,
    "base_repo_id" bigint,
    "head_branch" character varying(255),
    "base_branch" character varying(255),
    "merge_base" character varying(40),
    "has_merged" boolean,
    "merged_commit_id" character varying(40),
    "merger_id" bigint,
    "merged_unix" bigint,
    CONSTRAINT "pull_request_pkey" PRIMARY KEY ("id")
) WITH (oids = false);

CREATE INDEX "IDX_pull_request_base_repo_id" ON "public"."pull_request" USING btree ("base_repo_id");

CREATE INDEX "IDX_pull_request_has_merged" ON "public"."pull_request" USING btree ("has_merged");

CREATE INDEX "IDX_pull_request_head_repo_id" ON "public"."pull_request" USING btree ("head_repo_id");

CREATE INDEX "IDX_pull_request_issue_id" ON "public"."pull_request" USING btree ("issue_id");

CREATE INDEX "IDX_pull_request_merged_unix" ON "public"."pull_request" USING btree ("merged_unix");

CREATE INDEX "IDX_pull_request_merger_id" ON "public"."pull_request" USING btree ("merger_id");


DROP TABLE IF EXISTS "reaction";
DROP SEQUENCE IF EXISTS reaction_id_seq;
CREATE SEQUENCE reaction_id_seq INCREMENT 1 MINVALUE 1 MAXVALUE 9223372036854775807 CACHE 1;

CREATE TABLE "public"."reaction" (
    "id" bigint DEFAULT nextval('reaction_id_seq') NOT NULL,
    "type" character varying(255) NOT NULL,
    "issue_id" bigint NOT NULL,
    "comment_id" bigint,
    "user_id" bigint NOT NULL,
    "original_author_id" bigint DEFAULT '0' NOT NULL,
    "original_author" character varying(255),
    "created_unix" bigint,
    CONSTRAINT "UQE_reaction_s" UNIQUE ("type", "issue_id", "comment_id", "user_id", "original_author_id"),
    CONSTRAINT "reaction_pkey" PRIMARY KEY ("id")
) WITH (oids = false);

CREATE INDEX "IDX_reaction_comment_id" ON "public"."reaction" USING btree ("comment_id");

CREATE INDEX "IDX_reaction_created_unix" ON "public"."reaction" USING btree ("created_unix");

CREATE INDEX "IDX_reaction_issue_id" ON "public"."reaction" USING btree ("issue_id");

CREATE INDEX "IDX_reaction_original_author_id" ON "public"."reaction" USING btree ("original_author_id");

CREATE INDEX "IDX_reaction_type" ON "public"."reaction" USING btree ("type");

CREATE INDEX "IDX_reaction_user_id" ON "public"."reaction" USING btree ("user_id");


DROP TABLE IF EXISTS "release";
DROP SEQUENCE IF EXISTS release_id_seq;
CREATE SEQUENCE release_id_seq INCREMENT 1 MINVALUE 1 MAXVALUE 9223372036854775807 CACHE 1;

CREATE TABLE "public"."release" (
    "id" bigint DEFAULT nextval('release_id_seq') NOT NULL,
    "repo_id" bigint,
    "publisher_id" bigint,
    "tag_name" character varying(255),
    "original_author" character varying(255),
    "original_author_id" bigint,
    "lower_tag_name" character varying(255),
    "target" character varying(255),
    "title" character varying(255),
    "sha1" character varying(40),
    "num_commits" bigint,
    "note" text,
    "is_draft" boolean DEFAULT false NOT NULL,
    "is_prerelease" boolean DEFAULT false NOT NULL,
    "is_tag" boolean DEFAULT false NOT NULL,
    "created_unix" bigint,
    CONSTRAINT "UQE_release_n" UNIQUE ("repo_id", "tag_name"),
    CONSTRAINT "release_pkey" PRIMARY KEY ("id")
) WITH (oids = false);

CREATE INDEX "IDX_release_created_unix" ON "public"."release" USING btree ("created_unix");

CREATE INDEX "IDX_release_original_author_id" ON "public"."release" USING btree ("original_author_id");

CREATE INDEX "IDX_release_publisher_id" ON "public"."release" USING btree ("publisher_id");

CREATE INDEX "IDX_release_repo_id" ON "public"."release" USING btree ("repo_id");

CREATE INDEX "IDX_release_tag_name" ON "public"."release" USING btree ("tag_name");


DROP TABLE IF EXISTS "repo_indexer_status";
DROP SEQUENCE IF EXISTS repo_indexer_status_id_seq;
CREATE SEQUENCE repo_indexer_status_id_seq INCREMENT 1 MINVALUE 1 MAXVALUE 9223372036854775807 CACHE 1;

CREATE TABLE "public"."repo_indexer_status" (
    "id" bigint DEFAULT nextval('repo_indexer_status_id_seq') NOT NULL,
    "repo_id" bigint,
    "commit_sha" character varying(40),
    "indexer_type" integer DEFAULT '0' NOT NULL,
    CONSTRAINT "repo_indexer_status_pkey" PRIMARY KEY ("id")
) WITH (oids = false);

CREATE INDEX "IDX_repo_indexer_status_s" ON "public"."repo_indexer_status" USING btree ("repo_id", "indexer_type");


DROP TABLE IF EXISTS "repo_redirect";
DROP SEQUENCE IF EXISTS repo_redirect_id_seq;
CREATE SEQUENCE repo_redirect_id_seq INCREMENT 1 MINVALUE 1 MAXVALUE 9223372036854775807 CACHE 1;

CREATE TABLE "public"."repo_redirect" (
    "id" bigint DEFAULT nextval('repo_redirect_id_seq') NOT NULL,
    "owner_id" bigint,
    "lower_name" character varying(255) NOT NULL,
    "redirect_repo_id" bigint,
    CONSTRAINT "UQE_repo_redirect_s" UNIQUE ("owner_id", "lower_name"),
    CONSTRAINT "repo_redirect_pkey" PRIMARY KEY ("id")
) WITH (oids = false);

CREATE INDEX "IDX_repo_redirect_lower_name" ON "public"."repo_redirect" USING btree ("lower_name");


DROP TABLE IF EXISTS "repo_topic";
CREATE TABLE "public"."repo_topic" (
    "repo_id" bigint,
    "topic_id" bigint,
    CONSTRAINT "UQE_repo_topic_s" UNIQUE ("repo_id", "topic_id")
) WITH (oids = false);


DROP TABLE IF EXISTS "repo_unit";
DROP SEQUENCE IF EXISTS repo_unit_id_seq;
CREATE SEQUENCE repo_unit_id_seq INCREMENT 1 MINVALUE 1 MAXVALUE 9223372036854775807 CACHE 1;

CREATE TABLE "public"."repo_unit" (
    "id" bigint DEFAULT nextval('repo_unit_id_seq') NOT NULL,
    "repo_id" bigint,
    "type" integer,
    "config" text,
    "created_unix" bigint,
    CONSTRAINT "repo_unit_pkey" PRIMARY KEY ("id")
) WITH (oids = false);

CREATE INDEX "IDX_repo_unit_created_unix" ON "public"."repo_unit" USING btree ("created_unix");

CREATE INDEX "IDX_repo_unit_s" ON "public"."repo_unit" USING btree ("repo_id", "type");


DROP TABLE IF EXISTS "repository";
DROP SEQUENCE IF EXISTS repository_id_seq;
CREATE SEQUENCE repository_id_seq INCREMENT 1 MINVALUE 1 MAXVALUE 9223372036854775807 CACHE 1;

CREATE TABLE "public"."repository" (
    "id" bigint DEFAULT nextval('repository_id_seq') NOT NULL,
    "owner_id" bigint,
    "owner_name" character varying(255),
    "lower_name" character varying(255) NOT NULL,
    "name" character varying(255) NOT NULL,
    "description" text,
    "website" character varying(2048),
    "original_service_type" integer,
    "original_url" character varying(2048),
    "default_branch" character varying(255),
    "num_watches" integer,
    "num_stars" integer,
    "num_forks" integer,
    "num_issues" integer,
    "num_closed_issues" integer,
    "num_pulls" integer,
    "num_closed_pulls" integer,
    "num_milestones" integer DEFAULT '0' NOT NULL,
    "num_closed_milestones" integer DEFAULT '0' NOT NULL,
    "is_private" boolean,
    "is_empty" boolean,
    "is_archived" boolean,
    "is_mirror" boolean,
    "status" integer DEFAULT '0' NOT NULL,
    "is_fork" boolean DEFAULT false NOT NULL,
    "fork_id" bigint,
    "is_template" boolean DEFAULT false NOT NULL,
    "template_id" bigint,
    "size" bigint DEFAULT '0' NOT NULL,
    "is_fsck_enabled" boolean DEFAULT true NOT NULL,
    "close_issues_via_commit_in_any_branch" boolean DEFAULT false NOT NULL,
    "topics" json,
    "avatar" character varying(64),
    "created_unix" bigint,
    "updated_unix" bigint,
    CONSTRAINT "UQE_repository_s" UNIQUE ("owner_id", "lower_name"),
    CONSTRAINT "repository_pkey" PRIMARY KEY ("id")
) WITH (oids = false);

CREATE INDEX "IDX_repository_created_unix" ON "public"."repository" USING btree ("created_unix");

CREATE INDEX "IDX_repository_fork_id" ON "public"."repository" USING btree ("fork_id");

CREATE INDEX "IDX_repository_is_archived" ON "public"."repository" USING btree ("is_archived");

CREATE INDEX "IDX_repository_is_empty" ON "public"."repository" USING btree ("is_empty");

CREATE INDEX "IDX_repository_is_fork" ON "public"."repository" USING btree ("is_fork");

CREATE INDEX "IDX_repository_is_mirror" ON "public"."repository" USING btree ("is_mirror");

CREATE INDEX "IDX_repository_is_private" ON "public"."repository" USING btree ("is_private");

CREATE INDEX "IDX_repository_is_template" ON "public"."repository" USING btree ("is_template");

CREATE INDEX "IDX_repository_lower_name" ON "public"."repository" USING btree ("lower_name");

CREATE INDEX "IDX_repository_name" ON "public"."repository" USING btree ("name");

CREATE INDEX "IDX_repository_original_service_type" ON "public"."repository" USING btree ("original_service_type");

CREATE INDEX "IDX_repository_owner_id" ON "public"."repository" USING btree ("owner_id");

CREATE INDEX "IDX_repository_template_id" ON "public"."repository" USING btree ("template_id");

CREATE INDEX "IDX_repository_updated_unix" ON "public"."repository" USING btree ("updated_unix");


DROP TABLE IF EXISTS "review";
DROP SEQUENCE IF EXISTS review_id_seq;
CREATE SEQUENCE review_id_seq INCREMENT 1 MINVALUE 1 MAXVALUE 9223372036854775807 CACHE 1;

CREATE TABLE "public"."review" (
    "id" bigint DEFAULT nextval('review_id_seq') NOT NULL,
    "type" integer,
    "reviewer_id" bigint,
    "original_author" character varying(255),
    "original_author_id" bigint,
    "issue_id" bigint,
    "content" text,
    "official" boolean DEFAULT false NOT NULL,
    "commit_id" character varying(40),
    "stale" boolean DEFAULT false NOT NULL,
    "created_unix" bigint,
    "updated_unix" bigint,
    CONSTRAINT "review_pkey" PRIMARY KEY ("id")
) WITH (oids = false);

CREATE INDEX "IDX_review_created_unix" ON "public"."review" USING btree ("created_unix");

CREATE INDEX "IDX_review_issue_id" ON "public"."review" USING btree ("issue_id");

CREATE INDEX "IDX_review_reviewer_id" ON "public"."review" USING btree ("reviewer_id");

CREATE INDEX "IDX_review_updated_unix" ON "public"."review" USING btree ("updated_unix");


DROP TABLE IF EXISTS "star";
DROP SEQUENCE IF EXISTS star_id_seq;
CREATE SEQUENCE star_id_seq INCREMENT 1 MINVALUE 1 MAXVALUE 9223372036854775807 CACHE 1;

CREATE TABLE "public"."star" (
    "id" bigint DEFAULT nextval('star_id_seq') NOT NULL,
    "uid" bigint,
    "repo_id" bigint,
    CONSTRAINT "UQE_star_s" UNIQUE ("uid", "repo_id"),
    CONSTRAINT "star_pkey" PRIMARY KEY ("id")
) WITH (oids = false);


DROP TABLE IF EXISTS "stopwatch";
DROP SEQUENCE IF EXISTS stopwatch_id_seq;
CREATE SEQUENCE stopwatch_id_seq INCREMENT 1 MINVALUE 1 MAXVALUE 9223372036854775807 CACHE 1;

CREATE TABLE "public"."stopwatch" (
    "id" bigint DEFAULT nextval('stopwatch_id_seq') NOT NULL,
    "issue_id" bigint,
    "user_id" bigint,
    "created_unix" bigint,
    CONSTRAINT "stopwatch_pkey" PRIMARY KEY ("id")
) WITH (oids = false);

CREATE INDEX "IDX_stopwatch_issue_id" ON "public"."stopwatch" USING btree ("issue_id");

CREATE INDEX "IDX_stopwatch_user_id" ON "public"."stopwatch" USING btree ("user_id");


DROP TABLE IF EXISTS "task";
DROP SEQUENCE IF EXISTS task_id_seq;
CREATE SEQUENCE task_id_seq INCREMENT 1 MINVALUE 1 MAXVALUE 9223372036854775807 CACHE 1;

CREATE TABLE "public"."task" (
    "id" bigint DEFAULT nextval('task_id_seq') NOT NULL,
    "doer_id" bigint,
    "owner_id" bigint,
    "repo_id" bigint,
    "type" integer,
    "status" integer,
    "start_time" bigint,
    "end_time" bigint,
    "payload_content" text,
    "errors" text,
    "created" bigint,
    CONSTRAINT "task_pkey" PRIMARY KEY ("id")
) WITH (oids = false);

CREATE INDEX "IDX_task_doer_id" ON "public"."task" USING btree ("doer_id");

CREATE INDEX "IDX_task_owner_id" ON "public"."task" USING btree ("owner_id");

CREATE INDEX "IDX_task_repo_id" ON "public"."task" USING btree ("repo_id");

CREATE INDEX "IDX_task_status" ON "public"."task" USING btree ("status");


DROP TABLE IF EXISTS "team";
DROP SEQUENCE IF EXISTS team_id_seq;
CREATE SEQUENCE team_id_seq INCREMENT 1 MINVALUE 1 MAXVALUE 9223372036854775807 CACHE 1;

CREATE TABLE "public"."team" (
    "id" bigint DEFAULT nextval('team_id_seq') NOT NULL,
    "org_id" bigint,
    "lower_name" character varying(255),
    "name" character varying(255),
    "description" character varying(255),
    "authorize" integer,
    "num_repos" integer,
    "num_members" integer,
    "includes_all_repositories" boolean DEFAULT false NOT NULL,
    "can_create_org_repo" boolean DEFAULT false NOT NULL,
    CONSTRAINT "team_pkey" PRIMARY KEY ("id")
) WITH (oids = false);

CREATE INDEX "IDX_team_org_id" ON "public"."team" USING btree ("org_id");


DROP TABLE IF EXISTS "team_repo";
DROP SEQUENCE IF EXISTS team_repo_id_seq;
CREATE SEQUENCE team_repo_id_seq INCREMENT 1 MINVALUE 1 MAXVALUE 9223372036854775807 CACHE 1;

CREATE TABLE "public"."team_repo" (
    "id" bigint DEFAULT nextval('team_repo_id_seq') NOT NULL,
    "org_id" bigint,
    "team_id" bigint,
    "repo_id" bigint,
    CONSTRAINT "UQE_team_repo_s" UNIQUE ("team_id", "repo_id"),
    CONSTRAINT "team_repo_pkey" PRIMARY KEY ("id")
) WITH (oids = false);

CREATE INDEX "IDX_team_repo_org_id" ON "public"."team_repo" USING btree ("org_id");


DROP TABLE IF EXISTS "team_unit";
DROP SEQUENCE IF EXISTS team_unit_id_seq;
CREATE SEQUENCE team_unit_id_seq INCREMENT 1 MINVALUE 1 MAXVALUE 9223372036854775807 CACHE 1;

CREATE TABLE "public"."team_unit" (
    "id" bigint DEFAULT nextval('team_unit_id_seq') NOT NULL,
    "org_id" bigint,
    "team_id" bigint,
    "type" integer,
    CONSTRAINT "UQE_team_unit_s" UNIQUE ("team_id", "type"),
    CONSTRAINT "team_unit_pkey" PRIMARY KEY ("id")
) WITH (oids = false);

CREATE INDEX "IDX_team_unit_org_id" ON "public"."team_unit" USING btree ("org_id");


DROP TABLE IF EXISTS "team_user";
DROP SEQUENCE IF EXISTS team_user_id_seq;
CREATE SEQUENCE team_user_id_seq INCREMENT 1 MINVALUE 1 MAXVALUE 9223372036854775807 CACHE 1;

CREATE TABLE "public"."team_user" (
    "id" bigint DEFAULT nextval('team_user_id_seq') NOT NULL,
    "org_id" bigint,
    "team_id" bigint,
    "uid" bigint,
    CONSTRAINT "UQE_team_user_s" UNIQUE ("team_id", "uid"),
    CONSTRAINT "team_user_pkey" PRIMARY KEY ("id")
) WITH (oids = false);

CREATE INDEX "IDX_team_user_org_id" ON "public"."team_user" USING btree ("org_id");


DROP TABLE IF EXISTS "topic";
DROP SEQUENCE IF EXISTS topic_id_seq;
CREATE SEQUENCE topic_id_seq INCREMENT 1 MINVALUE 1 MAXVALUE 9223372036854775807 CACHE 1;

CREATE TABLE "public"."topic" (
    "id" bigint DEFAULT nextval('topic_id_seq') NOT NULL,
    "name" character varying(25),
    "repo_count" integer,
    "created_unix" bigint,
    "updated_unix" bigint,
    CONSTRAINT "UQE_topic_name" UNIQUE ("name"),
    CONSTRAINT "topic_pkey" PRIMARY KEY ("id")
) WITH (oids = false);

CREATE INDEX "IDX_topic_created_unix" ON "public"."topic" USING btree ("created_unix");

CREATE INDEX "IDX_topic_updated_unix" ON "public"."topic" USING btree ("updated_unix");


DROP TABLE IF EXISTS "tracked_time";
DROP SEQUENCE IF EXISTS tracked_time_id_seq;
CREATE SEQUENCE tracked_time_id_seq INCREMENT 1 MINVALUE 1 MAXVALUE 9223372036854775807 CACHE 1;

CREATE TABLE "public"."tracked_time" (
    "id" bigint DEFAULT nextval('tracked_time_id_seq') NOT NULL,
    "issue_id" bigint,
    "user_id" bigint,
    "created_unix" bigint,
    "time" bigint NOT NULL,
    "deleted" boolean DEFAULT false NOT NULL,
    CONSTRAINT "tracked_time_pkey" PRIMARY KEY ("id")
) WITH (oids = false);

CREATE INDEX "IDX_tracked_time_issue_id" ON "public"."tracked_time" USING btree ("issue_id");

CREATE INDEX "IDX_tracked_time_user_id" ON "public"."tracked_time" USING btree ("user_id");


DROP TABLE IF EXISTS "two_factor";
DROP SEQUENCE IF EXISTS two_factor_id_seq;
CREATE SEQUENCE two_factor_id_seq INCREMENT 1 MINVALUE 1 MAXVALUE 9223372036854775807 CACHE 1;

CREATE TABLE "public"."two_factor" (
    "id" bigint DEFAULT nextval('two_factor_id_seq') NOT NULL,
    "uid" bigint,
    "secret" character varying(255),
    "scratch_salt" character varying(255),
    "scratch_hash" character varying(255),
    "last_used_passcode" character varying(10),
    "created_unix" bigint,
    "updated_unix" bigint,
    CONSTRAINT "UQE_two_factor_uid" UNIQUE ("uid"),
    CONSTRAINT "two_factor_pkey" PRIMARY KEY ("id")
) WITH (oids = false);

CREATE INDEX "IDX_two_factor_created_unix" ON "public"."two_factor" USING btree ("created_unix");

CREATE INDEX "IDX_two_factor_updated_unix" ON "public"."two_factor" USING btree ("updated_unix");


DROP TABLE IF EXISTS "u2f_registration";
DROP SEQUENCE IF EXISTS u2f_registration_id_seq;
CREATE SEQUENCE u2f_registration_id_seq INCREMENT 1 MINVALUE 1 MAXVALUE 9223372036854775807 CACHE 1;

CREATE TABLE "public"."u2f_registration" (
    "id" bigint DEFAULT nextval('u2f_registration_id_seq') NOT NULL,
    "name" character varying(255),
    "user_id" bigint,
    "raw" bytea,
    "counter" bigint,
    "created_unix" bigint,
    "updated_unix" bigint,
    CONSTRAINT "u2f_registration_pkey" PRIMARY KEY ("id")
) WITH (oids = false);

CREATE INDEX "IDX_u2f_registration_created_unix" ON "public"."u2f_registration" USING btree ("created_unix");

CREATE INDEX "IDX_u2f_registration_updated_unix" ON "public"."u2f_registration" USING btree ("updated_unix");

CREATE INDEX "IDX_u2f_registration_user_id" ON "public"."u2f_registration" USING btree ("user_id");


DROP TABLE IF EXISTS "upload";
DROP SEQUENCE IF EXISTS upload_id_seq;
CREATE SEQUENCE upload_id_seq INCREMENT 1 MINVALUE 1 MAXVALUE 9223372036854775807 CACHE 1;

CREATE TABLE "public"."upload" (
    "id" bigint DEFAULT nextval('upload_id_seq') NOT NULL,
    "uuid" uuid,
    "name" character varying(255),
    CONSTRAINT "UQE_upload_uuid" UNIQUE ("uuid"),
    CONSTRAINT "upload_pkey" PRIMARY KEY ("id")
) WITH (oids = false);


DROP TABLE IF EXISTS "user";
DROP SEQUENCE IF EXISTS user_id_seq;
CREATE SEQUENCE user_id_seq INCREMENT 1 MINVALUE 1 MAXVALUE 9223372036854775807 CACHE 1;

CREATE TABLE "public"."user" (
    "id" bigint DEFAULT nextval('user_id_seq') NOT NULL,
    "lower_name" character varying(255) NOT NULL,
    "name" character varying(255) NOT NULL,
    "full_name" character varying(255),
    "email" character varying(255) NOT NULL,
    "keep_email_private" boolean,
    "email_notifications_preference" character varying(20) DEFAULT 'enabled' NOT NULL,
    "passwd" character varying(255) NOT NULL,
    "passwd_hash_algo" character varying(255) DEFAULT 'pbkdf2' NOT NULL,
    "must_change_password" boolean DEFAULT false NOT NULL,
    "login_type" integer,
    "login_source" bigint DEFAULT '0' NOT NULL,
    "login_name" character varying(255),
    "type" integer,
    "location" character varying(255),
    "website" character varying(255),
    "rands" character varying(10),
    "salt" character varying(10),
    "language" character varying(5),
    "description" character varying(255),
    "created_unix" bigint,
    "updated_unix" bigint,
    "last_login_unix" bigint,
    "last_repo_visibility" boolean,
    "max_repo_creation" integer DEFAULT '-1' NOT NULL,
    "is_active" boolean,
    "is_admin" boolean,
    "is_restricted" boolean DEFAULT false NOT NULL,
    "allow_git_hook" boolean,
    "allow_import_local" boolean,
    "allow_create_organization" boolean DEFAULT true,
    "prohibit_login" boolean DEFAULT false NOT NULL,
    "avatar" character varying(2048) NOT NULL,
    "avatar_email" character varying(255) NOT NULL,
    "use_custom_avatar" boolean,
    "num_followers" integer,
    "num_following" integer DEFAULT '0' NOT NULL,
    "num_stars" integer,
    "num_repos" integer,
    "num_teams" integer,
    "num_members" integer,
    "visibility" integer DEFAULT '0' NOT NULL,
    "repo_admin_change_team_access" boolean DEFAULT false NOT NULL,
    "diff_view_style" character varying(255) DEFAULT '' NOT NULL,
    "theme" character varying(255) DEFAULT '' NOT NULL,
    CONSTRAINT "UQE_user_lower_name" UNIQUE ("lower_name"),
    CONSTRAINT "UQE_user_name" UNIQUE ("name"),
    CONSTRAINT "user_pkey" PRIMARY KEY ("id")
) WITH (oids = false);

CREATE INDEX "IDX_user_created_unix" ON "public"."user" USING btree ("created_unix");

CREATE INDEX "IDX_user_is_active" ON "public"."user" USING btree ("is_active");

CREATE INDEX "IDX_user_last_login_unix" ON "public"."user" USING btree ("last_login_unix");

CREATE INDEX "IDX_user_updated_unix" ON "public"."user" USING btree ("updated_unix");

DROP TABLE IF EXISTS "user_open_id";
DROP SEQUENCE IF EXISTS user_open_id_id_seq;
CREATE SEQUENCE user_open_id_id_seq INCREMENT 1 MINVALUE 1 MAXVALUE 9223372036854775807 CACHE 1;

CREATE TABLE "public"."user_open_id" (
    "id" bigint DEFAULT nextval('user_open_id_id_seq') NOT NULL,
    "uid" bigint NOT NULL,
    "uri" character varying(255) NOT NULL,
    "show" boolean DEFAULT false,
    CONSTRAINT "UQE_user_open_id_uri" UNIQUE ("uri"),
    CONSTRAINT "user_open_id_pkey" PRIMARY KEY ("id")
) WITH (oids = false);

CREATE INDEX "IDX_user_open_id_uid" ON "public"."user_open_id" USING btree ("uid");


DROP TABLE IF EXISTS "version";
DROP SEQUENCE IF EXISTS version_id_seq;
CREATE SEQUENCE version_id_seq INCREMENT 1 MINVALUE 1 MAXVALUE 9223372036854775807 CACHE 1;

CREATE TABLE "public"."version" (
    "id" bigint DEFAULT nextval('version_id_seq') NOT NULL,
    "version" bigint,
    CONSTRAINT "version_pkey" PRIMARY KEY ("id")
) WITH (oids = false);


-- 2022-07-23 17:58:50.081018+00
