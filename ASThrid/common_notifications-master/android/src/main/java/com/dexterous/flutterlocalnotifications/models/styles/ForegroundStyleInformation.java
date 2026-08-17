package com.dexterous.flutterlocalnotifications.models.styles;

import androidx.annotation.Keep;

@Keep
public class ForegroundStyleInformation extends DefaultStyleInformation {
    public String value;
    public String image;
    public ForegroundStyleInformation(String value,String image) {
        super(false, false);
        this.value = value;
        this.image = image;
    }
}
