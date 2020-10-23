 CREATE TABLE bin (
	id		VARCHAR(64) NOT NULL PRIMARY KEY,
	readonly	BOOLEAN NOT NULL,
	updated_at	TIMESTAMP NOT NULL,
	created_at	TIMESTAMP NOT NULL,
	expired_at	TIMESTAMP NOT NULL,
	deleted_at	TIMESTAMP,
	downloads	BIGINT NOT NULL,
	updates		BIGINT NOT NULL
);

CREATE TABLE file (
	id		BIGSERIAL NOT NULL PRIMARY KEY,
	bin_id		VARCHAR(64) REFERENCES bin(id) ON DELETE CASCADE,
	filename        VARCHAR(128) NOT NULL,
	in_storage	BOOLEAN NOT NULL,
	mime		VARCHAR(128) NOT NULL,
	bytes		BIGINT NOT NULL,
	md5		VARCHAR(128) NOT NULL,
	sha256		VARCHAR(128) NOT NULL,
	downloads	BIGINT NOT NULL,
	updates 	BIGINT NOT NULL,
	ip		VARCHAR(128) NOT NULL,
	trace		TEXT NOT NULL,
	nonce		VARCHAR(128) NOT NULL,
	updated_at	TIMESTAMP NOT NULL,
	created_at	TIMESTAMP NOT NULL,
	deleted_at	TIMESTAMP,
	UNIQUE(bin_id, filename)
);

CREATE TABLE transaction (
	id		BIGSERIAL NOT NULL PRIMARY KEY,
	bin_id		VARCHAR(64),
	filename	TEXT,
	method		VARCHAR(128) NOT NULL,
	path		TEXT NOT NULL,
	ip		VARCHAR(128) NOT NULL,
	trace		TEXT NOT NULL,
	started_at	TIMESTAMP NOT NULL,
	finished_at	TIMESTAMP,
	UNIQUE(id)
);
