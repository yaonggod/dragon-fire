package com.dragong.dragong.domain.friend.entity;

public enum FriendStatus {
    WAITING("WAITING"),
    REQUESTCHECK("REQUESTCHECK"),
    ACCEPTCHECK("ACCEPTCHECK"),
    FRIEND("FRIEND"),
    DISCONNECTED("DISCONNECTED"),

    // Friend가 DB에 없으면 response로 리턴할 값
    NONE("NONE");

    private final String friendStatus;

    FriendStatus(String friendStatus) {
        this.friendStatus = friendStatus;
    }

    public String getFriendStatus() {
        return friendStatus;
    }
}
