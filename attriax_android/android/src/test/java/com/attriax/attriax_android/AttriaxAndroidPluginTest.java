package com.attriax.attriax_android;

import static org.junit.Assert.assertEquals;
import static org.junit.Assert.assertNotEquals;
import static org.junit.Assert.assertNotNull;
import static org.junit.Assert.assertNull;

import java.lang.reflect.Method;
import org.junit.Test;

public class AttriaxAndroidPluginTest {
    @Test
    public void hashAndroidIdUsesThePackageNameAsSalt() throws Exception {
        AttriaxAndroidPlugin plugin = new AttriaxAndroidPlugin();
        Method hashMethod = AttriaxAndroidPlugin.class.getDeclaredMethod(
            "hashAndroidId",
            String.class,
            String.class
        );
        hashMethod.setAccessible(true);

        String first = (String) hashMethod.invoke(plugin, "android-id-123", "com.attriax.first");
        String second = (String) hashMethod.invoke(plugin, "android-id-123", "com.attriax.second");

        assertNotNull(first);
        assertNotNull(second);
        assertEquals(64, first.length());
        assertEquals(64, second.length());
        assertNotEquals("android-id-123", first);
        assertNotEquals(first, second);
    }

    @Test
    public void hashAndroidIdReturnsNullForMissingValues() throws Exception {
        AttriaxAndroidPlugin plugin = new AttriaxAndroidPlugin();
        Method hashMethod = AttriaxAndroidPlugin.class.getDeclaredMethod(
            "hashAndroidId",
            String.class,
            String.class
        );
        hashMethod.setAccessible(true);

        assertNull(hashMethod.invoke(plugin, (String) null, "com.attriax.first"));
        assertNull(hashMethod.invoke(plugin, "", "com.attriax.first"));
    }
}