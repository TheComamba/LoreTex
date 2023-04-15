// @generated automatically by Diesel CLI.

diesel::table! {
    entities (label, descriptor) {
        label -> Text,
        descriptor -> Text,
        description -> Text,
    }
}

diesel::table! {
    history_items (label) {
        label -> Text,
        content -> Text,
        is_concerns_others -> Bool,
        is_secret -> Bool,
        year -> Integer,
        day -> Nullable<Integer>,
        originator -> Nullable<Text>,
        year_format -> Nullable<Text>,
    }
}

diesel::table! {
    relationships (parent, child) {
        parent -> Text,
        child -> Text,
        role -> Nullable<Text>,
    }
}

diesel::allow_tables_to_appear_in_same_query!(entities, history_items, relationships,);
