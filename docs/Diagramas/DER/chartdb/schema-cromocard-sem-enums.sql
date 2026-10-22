-- =====================================================================
--  CromoCard - Sistema de Gestao de Cartas Colecionaveis
--  DER COMPLETO - DDL PostgreSQL (VARIANTE SEM 'CREATE TYPE')
--  Use este arquivo se a ferramenta reclamar dos tipos enumerados.
--  Cada coluna virou VARCHAR(30) e os valores possiveis estao no comentario.
--
--  COMO USAR NO ChartDB (https://app.chartdb.io):
--    1. Abra o ChartDB e escolha 'Import' / 'Start from SQL script'
--    2. Selecione o dialeto PostgreSQL
--    3. Cole este arquivo inteiro e confirme
--
--  Serve tambem para dbdiagram.io (Import > From PostgreSQL),
--  DrawSQL, QuickDBD, pgModeler e para criar o banco de verdade.
--
--  50 tabelas | 90 chaves estrangeiras | 27 enums
--  Gerado a partir de DER/dbdiagram.io/03-der-completo.dbml
-- =====================================================================

-- ---------------------------------------------------------------------
-- TABELAS
-- ---------------------------------------------------------------------

-- ===== 1 - USUARIOS, PERFIL E ACESSO =====

CREATE TABLE users (
    id UUID PRIMARY KEY DEFAULT uuidv7(),
    name VARCHAR(120) NOT NULL,
    email VARCHAR(160) NOT NULL UNIQUE,
    password_hash VARCHAR(255),
    role VARCHAR(30) NOT NULL,  -- user_role: CUSTOMER, SELLER, ADMIN
    status VARCHAR(30) NOT NULL DEFAULT 'ACTIVE',  -- user_status: ACTIVE, SUSPENDED, BLOCKED
    email_verified BOOLEAN NOT NULL DEFAULT false,
    terms_accepted BOOLEAN NOT NULL DEFAULT false,
    oauth_provider VARCHAR(30),
    oauth_id VARCHAR(120),
    username VARCHAR(30) UNIQUE,
    phone VARCHAR(20),
    cpf VARCHAR(14) UNIQUE,
    last_login_at TIMESTAMPTZ,
    last_login_ip VARCHAR(45),
    suspended_until TIMESTAMPTZ,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    deleted_at TIMESTAMPTZ  -- soft delete (ADR-015)
);

CREATE TABLE profiles (
    id UUID PRIMARY KEY DEFAULT uuidv7(),
    user_id UUID NOT NULL UNIQUE,
    bio TEXT,
    avatar_url VARCHAR(255),
    city VARCHAR(120),
    portfolio_privacy VARCHAR(30) NOT NULL DEFAULT 'PUBLIC',  -- privacy: PUBLIC, PRIVATE
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    deleted_at TIMESTAMPTZ
);

CREATE TABLE addresses (
    id UUID PRIMARY KEY DEFAULT uuidv7(),
    user_id UUID NOT NULL,
    label VARCHAR(60) NOT NULL,
    zip_code VARCHAR(9) NOT NULL,
    street VARCHAR(160) NOT NULL,
    number VARCHAR(15) NOT NULL,
    complement VARCHAR(60),
    neighborhood VARCHAR(90) NOT NULL,
    city VARCHAR(90) NOT NULL,
    state CHAR(2) NOT NULL,
    is_primary BOOLEAN NOT NULL DEFAULT false,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    deleted_at TIMESTAMPTZ
);

CREATE TABLE password_reset_tokens (
    id UUID PRIMARY KEY DEFAULT uuidv7(),
    user_id UUID NOT NULL,
    token VARCHAR(255) NOT NULL UNIQUE,
    expires_at TIMESTAMPTZ NOT NULL,
    used BOOLEAN NOT NULL DEFAULT false,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    deleted_at TIMESTAMPTZ
);

CREATE TABLE refresh_tokens (
    id UUID PRIMARY KEY DEFAULT uuidv7(),
    user_id UUID NOT NULL,
    token_hash VARCHAR(255) NOT NULL UNIQUE,
    expires_at TIMESTAMPTZ NOT NULL,
    revoked_at TIMESTAMPTZ,
    user_agent VARCHAR(255),
    ip_address VARCHAR(45),
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    deleted_at TIMESTAMPTZ
);

CREATE TABLE achievements (
    id UUID PRIMARY KEY DEFAULT uuidv7(),
    name VARCHAR(90) NOT NULL UNIQUE,
    description VARCHAR(255) NOT NULL,
    icon_url VARCHAR(255),
    criteria VARCHAR(255) NOT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    deleted_at TIMESTAMPTZ
);

CREATE TABLE user_achievements (
    user_id UUID NOT NULL,
    achievement_id UUID NOT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    deleted_at TIMESTAMPTZ,
    PRIMARY KEY (user_id, achievement_id)
);

CREATE TABLE subscriptions (
    id UUID PRIMARY KEY DEFAULT uuidv7(),
    user_id UUID NOT NULL,
    plan VARCHAR(20) NOT NULL DEFAULT 'PRO',
    status VARCHAR(30) NOT NULL DEFAULT 'ACTIVE',  -- subscription_status: ACTIVE, CANCELED, EXPIRED
    payment_method VARCHAR(30) NOT NULL,  -- payment_method: CREDIT_CARD, PIX, BOLETO
    start_date DATE NOT NULL,
    end_date DATE,
    gateway_reference VARCHAR(120),
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    deleted_at TIMESTAMPTZ
);

-- ===== 2 - CATALOGO GLOBAL (ALBUNS E CARTAS) =====

CREATE TABLE categories (
    id UUID PRIMARY KEY DEFAULT uuidv7(),
    parent_category_id UUID,
    name VARCHAR(90) NOT NULL,
    type VARCHAR(30) NOT NULL,  -- category_type: ALBUM, CARD
    description VARCHAR(255),
    is_default BOOLEAN NOT NULL DEFAULT false,
    slug VARCHAR(100) UNIQUE,
    display_order INTEGER NOT NULL DEFAULT 0,
    is_pinned BOOLEAN NOT NULL DEFAULT false,
    badge VARCHAR(20),
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    deleted_at TIMESTAMPTZ
);

CREATE TABLE rarities (
    id UUID PRIMARY KEY DEFAULT uuidv7(),
    name VARCHAR(60) NOT NULL UNIQUE,
    sort_order SMALLINT NOT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    deleted_at TIMESTAMPTZ
);

CREATE TABLE languages (
    id UUID PRIMARY KEY DEFAULT uuidv7(),
    name VARCHAR(60) NOT NULL,
    code VARCHAR(5) NOT NULL UNIQUE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    deleted_at TIMESTAMPTZ
);

CREATE TABLE card_conditions (
    id UUID PRIMARY KEY DEFAULT uuidv7(),
    name VARCHAR(60) NOT NULL UNIQUE,
    sort_order SMALLINT NOT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    deleted_at TIMESTAMPTZ
);

CREATE TABLE albums (
    id UUID PRIMARY KEY DEFAULT uuidv7(),
    category_id UUID,
    title VARCHAR(160) NOT NULL,
    publisher VARCHAR(120),
    year SMALLINT,
    description TEXT,
    cover_url VARCHAR(255),
    total_cards INTEGER NOT NULL DEFAULT 0,
    status VARCHAR(30) NOT NULL DEFAULT 'ACTIVE',  -- album_status: ACTIVE, INACTIVE
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    deleted_at TIMESTAMPTZ
);

CREATE TABLE cards (
    id UUID PRIMARY KEY DEFAULT uuidv7(),
    album_id UUID,
    category_id UUID,
    rarity_id UUID,
    language_id UUID,
    name VARCHAR(160) NOT NULL,
    number VARCHAR(20),
    description TEXT,
    front_image_url VARCHAR(255),
    back_image_url VARCHAR(255),
    status VARCHAR(30) NOT NULL DEFAULT 'ACTIVE',  -- card_status: DRAFT, ACTIVE
    code VARCHAR(30) UNIQUE,
    variants VARCHAR(120),
    release_year SMALLINT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    deleted_at TIMESTAMPTZ,
    UNIQUE (album_id, number)
);

CREATE TABLE card_photos (
    id UUID PRIMARY KEY DEFAULT uuidv7(),
    card_id UUID NOT NULL,
    url VARCHAR(255) NOT NULL,
    sort_order SMALLINT NOT NULL DEFAULT 0,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    deleted_at TIMESTAMPTZ
);

CREATE TABLE price_history (
    id UUID PRIMARY KEY DEFAULT uuidv7(),
    card_id UUID NOT NULL,
    price NUMERIC(10,2) NOT NULL,
    reference_date DATE NOT NULL,
    source VARCHAR(30) NOT NULL,  -- price_source: SALE, LISTING
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    deleted_at TIMESTAMPTZ
);

-- ===== 3 - COLECAO DO CLIENTE =====

CREATE TABLE collections (
    id UUID PRIMARY KEY DEFAULT uuidv7(),
    user_id UUID NOT NULL UNIQUE,
    is_public BOOLEAN NOT NULL DEFAULT false,
    share_link VARCHAR(120) UNIQUE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    deleted_at TIMESTAMPTZ
);

CREATE TABLE user_albums (
    id UUID PRIMARY KEY DEFAULT uuidv7(),
    collection_id UUID NOT NULL,
    album_id UUID NOT NULL,
    is_favorite BOOLEAN NOT NULL DEFAULT false,
    progress_percentage NUMERIC(5,2) NOT NULL DEFAULT 0,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    deleted_at TIMESTAMPTZ,
    UNIQUE (collection_id, album_id)
);

CREATE TABLE collection_cards (
    id UUID PRIMARY KEY DEFAULT uuidv7(),
    collection_id UUID NOT NULL,
    card_id UUID NOT NULL,
    status VARCHAR(30) NOT NULL,  -- collection_card_status: OWNED, MISSING, DUPLICATE
    quantity INTEGER NOT NULL DEFAULT 1,
    market_value NUMERIC(10,2),
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    deleted_at TIMESTAMPTZ,
    UNIQUE (collection_id, card_id)
);

-- ===== 4 - COMUNIDADE (GRUPOS) =====

CREATE TABLE groups (
    id UUID PRIMARY KEY DEFAULT uuidv7(),
    creator_id UUID NOT NULL,
    name VARCHAR(120) NOT NULL,
    description TEXT,
    cover_image_url VARCHAR(255),
    access_type VARCHAR(30) NOT NULL,  -- group_access_type: OPEN, CLOSED
    status VARCHAR(30) NOT NULL DEFAULT 'ACTIVE',  -- group_status: ACTIVE, WARNED, SUSPENDED
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    deleted_at TIMESTAMPTZ
);

CREATE TABLE group_members (
    id UUID PRIMARY KEY DEFAULT uuidv7(),
    group_id UUID NOT NULL,
    user_id UUID NOT NULL,
    role VARCHAR(30) NOT NULL DEFAULT 'MEMBER',  -- member_role: MEMBER, ADMIN
    muted_until TIMESTAMPTZ,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    deleted_at TIMESTAMPTZ,
    UNIQUE (group_id, user_id)
);

CREATE TABLE group_join_requests (
    id UUID PRIMARY KEY DEFAULT uuidv7(),
    group_id UUID NOT NULL,
    user_id UUID NOT NULL,
    reviewed_by_id UUID,
    status VARCHAR(30) NOT NULL DEFAULT 'PENDING',  -- request_status: PENDING, APPROVED, REJECTED
    reviewed_at TIMESTAMPTZ,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    deleted_at TIMESTAMPTZ
);

CREATE TABLE group_messages (
    id UUID PRIMARY KEY DEFAULT uuidv7(),
    group_id UUID NOT NULL,
    author_id UUID NOT NULL,
    reply_to_id UUID,
    card_id UUID,
    listing_id UUID,
    content_type VARCHAR(30) NOT NULL DEFAULT 'TEXT',  -- message_content_type: TEXT, IMAGE, CARD, LISTING, POLL
    content TEXT,
    attachment_url VARCHAR(255),
    pinned BOOLEAN NOT NULL DEFAULT false,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    deleted_at TIMESTAMPTZ
);

CREATE TABLE polls (
    id UUID PRIMARY KEY DEFAULT uuidv7(),
    group_message_id UUID NOT NULL UNIQUE,
    question VARCHAR(255) NOT NULL,
    multiple_choice BOOLEAN NOT NULL DEFAULT false,
    closes_at TIMESTAMPTZ,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    deleted_at TIMESTAMPTZ
);

CREATE TABLE poll_options (
    id UUID PRIMARY KEY DEFAULT uuidv7(),
    poll_id UUID NOT NULL,
    text VARCHAR(160) NOT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    deleted_at TIMESTAMPTZ
);

CREATE TABLE poll_votes (
    poll_option_id UUID NOT NULL,
    user_id UUID NOT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    deleted_at TIMESTAMPTZ,
    PRIMARY KEY (poll_option_id, user_id)
);

-- ===== 5 - CHAT PESSOAL =====

CREATE TABLE conversations (
    id UUID PRIMARY KEY DEFAULT uuidv7(),
    listing_id UUID,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    deleted_at TIMESTAMPTZ
);

CREATE TABLE conversation_participants (
    conversation_id UUID NOT NULL,
    user_id UUID NOT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    deleted_at TIMESTAMPTZ,
    PRIMARY KEY (conversation_id, user_id)
);

CREATE TABLE messages (
    id UUID PRIMARY KEY DEFAULT uuidv7(),
    conversation_id UUID NOT NULL,
    author_id UUID NOT NULL,
    reply_to_id UUID,
    content TEXT,
    attachment_url VARCHAR(255),
    is_read BOOLEAN NOT NULL DEFAULT false,
    read_at TIMESTAMPTZ,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    deleted_at TIMESTAMPTZ
);

CREATE TABLE user_blocks (
    id UUID PRIMARY KEY DEFAULT uuidv7(),
    blocker_id UUID NOT NULL,
    blocked_id UUID NOT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    deleted_at TIMESTAMPTZ,
    UNIQUE (blocker_id, blocked_id)
);

-- ===== 6 - MARKETPLACE (ANUNCIOS, PEDIDOS, AVALIACOES) =====

CREATE TABLE listings (
    id UUID PRIMARY KEY DEFAULT uuidv7(),
    seller_id UUID NOT NULL,
    card_id UUID NOT NULL,
    condition_id UUID,
    price NUMERIC(10,2) NOT NULL,
    available_quantity INTEGER NOT NULL DEFAULT 1,
    description TEXT,
    status VARCHAR(30) NOT NULL DEFAULT 'ACTIVE',  -- listing_status: ACTIVE, PAUSED, CLOSED
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    deleted_at TIMESTAMPTZ
);

CREATE TABLE listing_photos (
    id UUID PRIMARY KEY DEFAULT uuidv7(),
    listing_id UUID NOT NULL,
    url VARCHAR(255) NOT NULL,
    sort_order SMALLINT NOT NULL DEFAULT 0,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    deleted_at TIMESTAMPTZ
);

CREATE TABLE offers (
    id UUID PRIMARY KEY DEFAULT uuidv7(),
    listing_id UUID NOT NULL,
    buyer_id UUID NOT NULL,
    offered_amount NUMERIC(10,2) NOT NULL,
    message VARCHAR(255),
    status VARCHAR(30) NOT NULL DEFAULT 'PENDING',  -- offer_status: PENDING, ACCEPTED, REJECTED, EXPIRED
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    deleted_at TIMESTAMPTZ
);

CREATE TABLE orders (
    id UUID PRIMARY KEY DEFAULT uuidv7(),
    listing_id UUID NOT NULL,
    buyer_id UUID NOT NULL,
    seller_id UUID NOT NULL,
    shipping_address_id UUID NOT NULL,
    quantity INTEGER NOT NULL DEFAULT 1,
    items_amount NUMERIC(10,2) NOT NULL,
    shipping_amount NUMERIC(10,2) NOT NULL DEFAULT 0,
    total_amount NUMERIC(10,2) NOT NULL,
    shipping_method VARCHAR(60) NOT NULL,
    status VARCHAR(30) NOT NULL DEFAULT 'AWAITING_PAYMENT',  -- order_status: AWAITING_PAYMENT, PAID, SHIPPED, DELIVERED, CANCELED
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    deleted_at TIMESTAMPTZ
);

CREATE TABLE payments (
    id UUID PRIMARY KEY DEFAULT uuidv7(),
    order_id UUID NOT NULL UNIQUE,
    method VARCHAR(30) NOT NULL,  -- payment_method: CREDIT_CARD, PIX, BOLETO
    value NUMERIC(10,2) NOT NULL,
    status VARCHAR(30) NOT NULL DEFAULT 'PENDING',  -- payment_status: PENDING, APPROVED, REJECTED, REFUNDED
    gateway_reference VARCHAR(120),
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    deleted_at TIMESTAMPTZ
);

CREATE TABLE reviews (
    id UUID PRIMARY KEY DEFAULT uuidv7(),
    order_id UUID NOT NULL UNIQUE,
    author_id UUID NOT NULL,
    seller_id UUID NOT NULL,
    rating SMALLINT NOT NULL,
    comment VARCHAR(500),
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    deleted_at TIMESTAMPTZ
);

-- ===== 7 - NOTIFICACOES E FAVORITOS =====

CREATE TABLE favorites (
    id UUID PRIMARY KEY DEFAULT uuidv7(),
    user_id UUID NOT NULL,
    type VARCHAR(30) NOT NULL,  -- favorite_type: ALBUM, CARD, GROUP
    album_id UUID,
    card_id UUID,
    group_id UUID,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    deleted_at TIMESTAMPTZ
);

CREATE TABLE price_alerts (
    id UUID PRIMARY KEY DEFAULT uuidv7(),
    user_id UUID NOT NULL,
    card_id UUID NOT NULL,
    target_price NUMERIC(10,2) NOT NULL,
    active BOOLEAN NOT NULL DEFAULT true,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    deleted_at TIMESTAMPTZ
);

CREATE TABLE global_notifications (
    id UUID PRIMARY KEY DEFAULT uuidv7(),
    admin_id UUID NOT NULL,
    title VARCHAR(120) NOT NULL,
    content VARCHAR(500) NOT NULL,
    recipient_count INTEGER NOT NULL DEFAULT 0,
    reference_link VARCHAR(255),
    audience VARCHAR(30) NOT NULL DEFAULT 'ALL',
    channels VARCHAR(60) NOT NULL DEFAULT 'IN_APP',
    status VARCHAR(30) NOT NULL DEFAULT 'SENT',  -- notification_dispatch_status: SCHEDULED, SENT, CANCELED
    scheduled_at TIMESTAMPTZ,
    sent_at TIMESTAMPTZ,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    deleted_at TIMESTAMPTZ
);

CREATE TABLE notifications (
    id UUID PRIMARY KEY DEFAULT uuidv7(),
    user_id UUID NOT NULL,
    global_notification_id UUID,
    title VARCHAR(120) NOT NULL,
    message VARCHAR(500) NOT NULL,
    type VARCHAR(40) NOT NULL,
    reference_link VARCHAR(255),
    is_read BOOLEAN NOT NULL DEFAULT false,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    deleted_at TIMESTAMPTZ
);

-- ===== 8 - MODERACAO E ADMINISTRACAO =====

CREATE TABLE reports (
    id UUID PRIMARY KEY DEFAULT uuidv7(),
    reporter_id UUID NOT NULL,
    moderator_id UUID,
    listing_id UUID,
    target_user_id UUID,
    group_message_id UUID,
    target_type VARCHAR(30) NOT NULL,  -- report_target_type: LISTING, SELLER, USER, PROFILE, GROUP_MESSAGE
    reason VARCHAR(90) NOT NULL,
    description VARCHAR(500),
    status VARCHAR(30) NOT NULL DEFAULT 'PENDING',  -- report_status: PENDING, UNDER_REVIEW, RESOLVED, DISMISSED
    resolved_at TIMESTAMPTZ,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    deleted_at TIMESTAMPTZ
);

CREATE TABLE catalog_requests (
    id UUID PRIMARY KEY DEFAULT uuidv7(),
    requester_id UUID NOT NULL,
    reviewed_by_id UUID,
    card_id UUID,
    album_id UUID,
    type VARCHAR(30) NOT NULL,  -- catalog_request_type: CARD, ALBUM, CATEGORY
    data JSONB NOT NULL,
    status VARCHAR(30) NOT NULL DEFAULT 'PENDING',  -- request_status: PENDING, APPROVED, REJECTED
    reviewed_at TIMESTAMPTZ,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    deleted_at TIMESTAMPTZ
);

CREATE TABLE audit_logs (
    id UUID PRIMARY KEY DEFAULT uuidv7(),
    admin_id UUID NOT NULL,
    action VARCHAR(90) NOT NULL,
    entity_type VARCHAR(60) NOT NULL,
    entity_id UUID,
    details JSONB,
    ip_address VARCHAR(45),
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    deleted_at TIMESTAMPTZ
);

CREATE TABLE global_settings (
    id UUID PRIMARY KEY DEFAULT uuidv7(),
    updated_by_id UUID,
    key VARCHAR(90) NOT NULL UNIQUE,
    value TEXT NOT NULL,
    description VARCHAR(255),
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    deleted_at TIMESTAMPTZ
);

CREATE TABLE seller_verifications (
    id UUID PRIMARY KEY DEFAULT uuidv7(),
    user_id UUID NOT NULL UNIQUE,
    reviewed_by_id UUID,
    address_id UUID,
    status VARCHAR(30) NOT NULL DEFAULT 'UNDER_REVIEW',  -- seller_verification_status: UNDER_REVIEW, PENDING, APPROVED, REJECTED
    legal_name VARCHAR(160) NOT NULL,
    trade_name VARCHAR(160),
    cnpj VARCHAR(18) NOT NULL UNIQUE,
    state_registration VARCHAR(30),
    opening_date DATE,
    company_size VARCHAR(40),
    cnae VARCHAR(120),
    responsible_name VARCHAR(120) NOT NULL,
    responsible_cpf VARCHAR(14) NOT NULL,
    responsible_phone VARCHAR(20),
    bank_name VARCHAR(80),
    bank_branch VARCHAR(10),
    bank_account VARCHAR(20),
    pix_key VARCHAR(120),
    rejection_reason VARCHAR(255),
    regularization_deadline TIMESTAMPTZ,
    reviewed_at TIMESTAMPTZ,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    deleted_at TIMESTAMPTZ
);

CREATE TABLE seller_documents (
    id UUID PRIMARY KEY DEFAULT uuidv7(),
    seller_verification_id UUID NOT NULL,
    validated_by_id UUID,
    type VARCHAR(60) NOT NULL,
    file_url VARCHAR(255) NOT NULL,
    file_size INTEGER,
    status VARCHAR(30) NOT NULL DEFAULT 'SUBMITTED',  -- seller_document_status: SUBMITTED, VALIDATED
    validated_at TIMESTAMPTZ,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    deleted_at TIMESTAMPTZ
);

CREATE TABLE seller_verification_notes (
    id UUID PRIMARY KEY DEFAULT uuidv7(),
    seller_verification_id UUID NOT NULL,
    author_id UUID NOT NULL,
    content TEXT NOT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    deleted_at TIMESTAMPTZ
);

CREATE TABLE user_warnings (
    id UUID PRIMARY KEY DEFAULT uuidv7(),
    user_id UUID NOT NULL,
    admin_id UUID NOT NULL,
    report_id UUID,
    reason VARCHAR(255) NOT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    deleted_at TIMESTAMPTZ
);

CREATE TABLE catalog_request_votes (
    catalog_request_id UUID NOT NULL,
    user_id UUID NOT NULL,
    vote VARCHAR(30) NOT NULL,  -- catalog_vote: FOR, NEUTRAL, AGAINST
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    deleted_at TIMESTAMPTZ,
    PRIMARY KEY (catalog_request_id, user_id)
);

CREATE TABLE report_exports (
    id UUID PRIMARY KEY DEFAULT uuidv7(),
    admin_id UUID NOT NULL,
    report_type VARCHAR(60) NOT NULL,
    filters JSONB,
    format VARCHAR(10) NOT NULL,
    file_url VARCHAR(255) NOT NULL,
    file_size INTEGER,
    expires_at TIMESTAMPTZ NOT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    deleted_at TIMESTAMPTZ
);

-- ---------------------------------------------------------------------
-- CHAVES ESTRANGEIRAS
-- ---------------------------------------------------------------------
ALTER TABLE profiles ADD CONSTRAINT fk_profiles_user_id FOREIGN KEY (user_id) REFERENCES users (id);
ALTER TABLE addresses ADD CONSTRAINT fk_addresses_user_id FOREIGN KEY (user_id) REFERENCES users (id);
CREATE UNIQUE INDEX uq_users_oauth_provider_oauth_id ON users (oauth_provider, oauth_id);
COMMENT ON COLUMN password_reset_tokens.token IS 'Hash (SHA-256) do token; o valor puro so vai no link do e-mail (ADR-048)';

ALTER TABLE password_reset_tokens ADD CONSTRAINT fk_password_reset_tokens_user_id FOREIGN KEY (user_id) REFERENCES users (id);
ALTER TABLE refresh_tokens ADD CONSTRAINT fk_refresh_tokens_user_id FOREIGN KEY (user_id) REFERENCES users (id);
ALTER TABLE user_achievements ADD CONSTRAINT fk_user_achievements_user_id FOREIGN KEY (user_id) REFERENCES users (id);
ALTER TABLE user_achievements ADD CONSTRAINT fk_user_achievements_achievement_id FOREIGN KEY (achievement_id) REFERENCES achievements (id);
ALTER TABLE subscriptions ADD CONSTRAINT fk_subscriptions_user_id FOREIGN KEY (user_id) REFERENCES users (id);
ALTER TABLE categories ADD CONSTRAINT fk_categories_parent_category_id FOREIGN KEY (parent_category_id) REFERENCES categories (id);
ALTER TABLE albums ADD CONSTRAINT fk_albums_category_id FOREIGN KEY (category_id) REFERENCES categories (id);
ALTER TABLE cards ADD CONSTRAINT fk_cards_album_id FOREIGN KEY (album_id) REFERENCES albums (id);
ALTER TABLE cards ADD CONSTRAINT fk_cards_category_id FOREIGN KEY (category_id) REFERENCES categories (id);
ALTER TABLE cards ADD CONSTRAINT fk_cards_rarity_id FOREIGN KEY (rarity_id) REFERENCES rarities (id);
ALTER TABLE cards ADD CONSTRAINT fk_cards_language_id FOREIGN KEY (language_id) REFERENCES languages (id);
ALTER TABLE card_photos ADD CONSTRAINT fk_card_photos_card_id FOREIGN KEY (card_id) REFERENCES cards (id);
ALTER TABLE price_history ADD CONSTRAINT fk_price_history_card_id FOREIGN KEY (card_id) REFERENCES cards (id);
ALTER TABLE collections ADD CONSTRAINT fk_collections_user_id FOREIGN KEY (user_id) REFERENCES users (id);
ALTER TABLE user_albums ADD CONSTRAINT fk_user_albums_collection_id FOREIGN KEY (collection_id) REFERENCES collections (id);
ALTER TABLE user_albums ADD CONSTRAINT fk_user_albums_album_id FOREIGN KEY (album_id) REFERENCES albums (id);
ALTER TABLE collection_cards ADD CONSTRAINT fk_collection_cards_collection_id FOREIGN KEY (collection_id) REFERENCES collections (id);
ALTER TABLE collection_cards ADD CONSTRAINT fk_collection_cards_card_id FOREIGN KEY (card_id) REFERENCES cards (id);
ALTER TABLE groups ADD CONSTRAINT fk_groups_creator_id FOREIGN KEY (creator_id) REFERENCES users (id);
ALTER TABLE group_members ADD CONSTRAINT fk_group_members_group_id FOREIGN KEY (group_id) REFERENCES groups (id);
ALTER TABLE group_members ADD CONSTRAINT fk_group_members_user_id FOREIGN KEY (user_id) REFERENCES users (id);
ALTER TABLE group_join_requests ADD CONSTRAINT fk_group_join_requests_group_id FOREIGN KEY (group_id) REFERENCES groups (id);
ALTER TABLE group_join_requests ADD CONSTRAINT fk_group_join_requests_user_id FOREIGN KEY (user_id) REFERENCES users (id);
ALTER TABLE group_join_requests ADD CONSTRAINT fk_group_join_requests_reviewed_by_id FOREIGN KEY (reviewed_by_id) REFERENCES users (id);
ALTER TABLE group_messages ADD CONSTRAINT fk_group_messages_group_id FOREIGN KEY (group_id) REFERENCES groups (id);
ALTER TABLE group_messages ADD CONSTRAINT fk_group_messages_author_id FOREIGN KEY (author_id) REFERENCES users (id);
ALTER TABLE group_messages ADD CONSTRAINT fk_group_messages_reply_to_id FOREIGN KEY (reply_to_id) REFERENCES group_messages (id);
ALTER TABLE group_messages ADD CONSTRAINT fk_group_messages_card_id FOREIGN KEY (card_id) REFERENCES cards (id);
ALTER TABLE group_messages ADD CONSTRAINT fk_group_messages_listing_id FOREIGN KEY (listing_id) REFERENCES listings (id);
ALTER TABLE polls ADD CONSTRAINT fk_polls_group_message_id FOREIGN KEY (group_message_id) REFERENCES group_messages (id);
ALTER TABLE poll_options ADD CONSTRAINT fk_poll_options_poll_id FOREIGN KEY (poll_id) REFERENCES polls (id);
ALTER TABLE poll_votes ADD CONSTRAINT fk_poll_votes_poll_option_id FOREIGN KEY (poll_option_id) REFERENCES poll_options (id);
ALTER TABLE poll_votes ADD CONSTRAINT fk_poll_votes_user_id FOREIGN KEY (user_id) REFERENCES users (id);
ALTER TABLE conversation_participants ADD CONSTRAINT fk_conversation_participants_conversation_id FOREIGN KEY (conversation_id) REFERENCES conversations (id);
ALTER TABLE conversation_participants ADD CONSTRAINT fk_conversation_participants_user_id FOREIGN KEY (user_id) REFERENCES users (id);
ALTER TABLE messages ADD CONSTRAINT fk_messages_conversation_id FOREIGN KEY (conversation_id) REFERENCES conversations (id);
ALTER TABLE messages ADD CONSTRAINT fk_messages_author_id FOREIGN KEY (author_id) REFERENCES users (id);
ALTER TABLE messages ADD CONSTRAINT fk_messages_reply_to_id FOREIGN KEY (reply_to_id) REFERENCES messages (id);
ALTER TABLE conversations ADD CONSTRAINT fk_conversations_listing_id FOREIGN KEY (listing_id) REFERENCES listings (id);
ALTER TABLE user_blocks ADD CONSTRAINT fk_user_blocks_blocker_id FOREIGN KEY (blocker_id) REFERENCES users (id);
ALTER TABLE user_blocks ADD CONSTRAINT fk_user_blocks_blocked_id FOREIGN KEY (blocked_id) REFERENCES users (id);
ALTER TABLE listings ADD CONSTRAINT fk_listings_seller_id FOREIGN KEY (seller_id) REFERENCES users (id);
ALTER TABLE listings ADD CONSTRAINT fk_listings_card_id FOREIGN KEY (card_id) REFERENCES cards (id);
ALTER TABLE listings ADD CONSTRAINT fk_listings_condition_id FOREIGN KEY (condition_id) REFERENCES card_conditions (id);
ALTER TABLE listing_photos ADD CONSTRAINT fk_listing_photos_listing_id FOREIGN KEY (listing_id) REFERENCES listings (id);
ALTER TABLE offers ADD CONSTRAINT fk_offers_listing_id FOREIGN KEY (listing_id) REFERENCES listings (id);
ALTER TABLE offers ADD CONSTRAINT fk_offers_buyer_id FOREIGN KEY (buyer_id) REFERENCES users (id);
ALTER TABLE orders ADD CONSTRAINT fk_orders_listing_id FOREIGN KEY (listing_id) REFERENCES listings (id);
ALTER TABLE orders ADD CONSTRAINT fk_orders_buyer_id FOREIGN KEY (buyer_id) REFERENCES users (id);
ALTER TABLE orders ADD CONSTRAINT fk_orders_seller_id FOREIGN KEY (seller_id) REFERENCES users (id);
ALTER TABLE orders ADD CONSTRAINT fk_orders_shipping_address_id FOREIGN KEY (shipping_address_id) REFERENCES addresses (id);
ALTER TABLE payments ADD CONSTRAINT fk_payments_order_id FOREIGN KEY (order_id) REFERENCES orders (id);
ALTER TABLE reviews ADD CONSTRAINT fk_reviews_order_id FOREIGN KEY (order_id) REFERENCES orders (id);
ALTER TABLE reviews ADD CONSTRAINT fk_reviews_author_id FOREIGN KEY (author_id) REFERENCES users (id);
ALTER TABLE reviews ADD CONSTRAINT fk_reviews_seller_id FOREIGN KEY (seller_id) REFERENCES users (id);
ALTER TABLE favorites ADD CONSTRAINT fk_favorites_user_id FOREIGN KEY (user_id) REFERENCES users (id);
ALTER TABLE favorites ADD CONSTRAINT fk_favorites_album_id FOREIGN KEY (album_id) REFERENCES albums (id);
ALTER TABLE favorites ADD CONSTRAINT fk_favorites_card_id FOREIGN KEY (card_id) REFERENCES cards (id);
ALTER TABLE favorites ADD CONSTRAINT fk_favorites_group_id FOREIGN KEY (group_id) REFERENCES groups (id);
ALTER TABLE price_alerts ADD CONSTRAINT fk_price_alerts_user_id FOREIGN KEY (user_id) REFERENCES users (id);
ALTER TABLE price_alerts ADD CONSTRAINT fk_price_alerts_card_id FOREIGN KEY (card_id) REFERENCES cards (id);
ALTER TABLE notifications ADD CONSTRAINT fk_notifications_user_id FOREIGN KEY (user_id) REFERENCES users (id);
ALTER TABLE notifications ADD CONSTRAINT fk_notifications_global_notification_id FOREIGN KEY (global_notification_id) REFERENCES global_notifications (id);
ALTER TABLE global_notifications ADD CONSTRAINT fk_global_notifications_admin_id FOREIGN KEY (admin_id) REFERENCES users (id);
ALTER TABLE reports ADD CONSTRAINT fk_reports_reporter_id FOREIGN KEY (reporter_id) REFERENCES users (id);
ALTER TABLE reports ADD CONSTRAINT fk_reports_moderator_id FOREIGN KEY (moderator_id) REFERENCES users (id);
ALTER TABLE reports ADD CONSTRAINT fk_reports_listing_id FOREIGN KEY (listing_id) REFERENCES listings (id);
ALTER TABLE reports ADD CONSTRAINT fk_reports_target_user_id FOREIGN KEY (target_user_id) REFERENCES users (id);
ALTER TABLE reports ADD CONSTRAINT fk_reports_group_message_id FOREIGN KEY (group_message_id) REFERENCES group_messages (id);
ALTER TABLE catalog_requests ADD CONSTRAINT fk_catalog_requests_requester_id FOREIGN KEY (requester_id) REFERENCES users (id);
ALTER TABLE catalog_requests ADD CONSTRAINT fk_catalog_requests_reviewed_by_id FOREIGN KEY (reviewed_by_id) REFERENCES users (id);
ALTER TABLE catalog_requests ADD CONSTRAINT fk_catalog_requests_card_id FOREIGN KEY (card_id) REFERENCES cards (id);
ALTER TABLE catalog_requests ADD CONSTRAINT fk_catalog_requests_album_id FOREIGN KEY (album_id) REFERENCES albums (id);
ALTER TABLE audit_logs ADD CONSTRAINT fk_audit_logs_admin_id FOREIGN KEY (admin_id) REFERENCES users (id);
ALTER TABLE global_settings ADD CONSTRAINT fk_global_settings_updated_by_id FOREIGN KEY (updated_by_id) REFERENCES users (id);
ALTER TABLE seller_verifications ADD CONSTRAINT fk_seller_verifications_user_id FOREIGN KEY (user_id) REFERENCES users (id);
ALTER TABLE seller_verifications ADD CONSTRAINT fk_seller_verifications_reviewed_by_id FOREIGN KEY (reviewed_by_id) REFERENCES users (id);
ALTER TABLE seller_verifications ADD CONSTRAINT fk_seller_verifications_address_id FOREIGN KEY (address_id) REFERENCES addresses (id);
ALTER TABLE seller_documents ADD CONSTRAINT fk_seller_documents_seller_verification_id FOREIGN KEY (seller_verification_id) REFERENCES seller_verifications (id);
ALTER TABLE seller_documents ADD CONSTRAINT fk_seller_documents_validated_by_id FOREIGN KEY (validated_by_id) REFERENCES users (id);
ALTER TABLE seller_verification_notes ADD CONSTRAINT fk_seller_verification_notes_seller_verification_id FOREIGN KEY (seller_verification_id) REFERENCES seller_verifications (id);
ALTER TABLE seller_verification_notes ADD CONSTRAINT fk_seller_verification_notes_author_id FOREIGN KEY (author_id) REFERENCES users (id);
ALTER TABLE user_warnings ADD CONSTRAINT fk_user_warnings_user_id FOREIGN KEY (user_id) REFERENCES users (id);
ALTER TABLE user_warnings ADD CONSTRAINT fk_user_warnings_admin_id FOREIGN KEY (admin_id) REFERENCES users (id);
ALTER TABLE user_warnings ADD CONSTRAINT fk_user_warnings_report_id FOREIGN KEY (report_id) REFERENCES reports (id);
ALTER TABLE catalog_request_votes ADD CONSTRAINT fk_catalog_request_votes_catalog_request_id FOREIGN KEY (catalog_request_id) REFERENCES catalog_requests (id);
ALTER TABLE catalog_request_votes ADD CONSTRAINT fk_catalog_request_votes_user_id FOREIGN KEY (user_id) REFERENCES users (id);
ALTER TABLE report_exports ADD CONSTRAINT fk_report_exports_admin_id FOREIGN KEY (admin_id) REFERENCES users (id);

