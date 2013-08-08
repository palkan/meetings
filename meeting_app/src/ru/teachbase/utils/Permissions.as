package ru.teachbase.utils {

/**
 *  Class containing constants and helpers to work with user's permissions.
 *
 *  User permissions are represented as a bit mask of length 5.
 *
 *  Bits order (left to right): GUEST, ADMIN, CAMERA, MIC, DOCS.
 *
 *  For example, 2#10001 represents guest user with only rights to work with docs;
 *  2#01**** represents administrator user.
 *
 *  <b>Note:</b> administrator can be a guest (i.e. permissions' mask 2#11111 is possible).
 *
 *
 *
 */

public class Permissions {

    public static const CAMERA:uint = 1 << 2;
    public static const MIC:uint = 1 << 1;
    public static const DOCS:uint = 1;
    public static const ADMIN:uint = 1 << 3;
    public static const GUEST:uint = 1 << 4;

    public static const ADMIN_MASK:uint = CAMERA + MIC + DOCS + ADMIN;

    public function Permissions() {
    }

    /**
     *
     * @param value
     * @return
     */

    public static function isAdmin(value:uint):Boolean {

        return Boolean(value & ADMIN);

    }

    /**
     *
     * @param value
     * @return
     */

    public static function isGuest(value:uint):Boolean {

        return Boolean(value & GUEST);

    }


    /**
     *
     * @param value
     * @return
     */

    public static function camAvailable(value:uint):Boolean {

        return Boolean(value & CAMERA) || isAdmin(value);
    }


    /**
     *
     * @param value
     * @return
     */
    public static function micAvailable(value:uint):Boolean {

        return Boolean(value & MIC) || isAdmin(value);
    }


    /**
     *
     * @param value
     * @return
     */
    public static function docsAvailable(value:uint):Boolean {

        return Boolean(value & DOCS) || isAdmin(value);
    }


    /**
     *
     * @param right mask of the right to check
     * @param permissions total user permissions
     * @return <i>true</i> if user already has these rights
     *
     */

    public static function hasRight(right:uint, permissions:uint):Boolean {

        return Boolean(permissions & right);
    }
}
}