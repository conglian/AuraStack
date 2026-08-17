package com.dexterous.flutterlocalnotifications.models.styles;

import androidx.annotation.Keep;
import androidx.annotation.NonNull;

@Keep
public class MediaStyleInformation extends DefaultStyleInformation {
    @NonNull
    public String image;

    public MediaStyleInformation(@NonNull String image) {
        super(false, false);
        this.image = image;
    }
}
