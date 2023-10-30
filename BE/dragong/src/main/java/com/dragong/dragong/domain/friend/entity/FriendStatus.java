package com.dragong.dragong.domain.friend.entity;

public enum FriendStatus {
    WAITING("WAITING"),
    REQUESTCHECK("REQUESTCHECK"),
    ACCEPTCHECK("ACCEPTCHECK"),
    FRIEND("FRIEND"),
    DISCONNECTED("DISCONNECTED");

    private final String friendStatus;

    FriendStatus(String friendStatus) {
        this.friendStatus = friendStatus;
    }

    public String getFriendStatus() {
        return friendStatus;
    }
}
