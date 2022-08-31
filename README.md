<p >
<a href="https://www.buymeacoffee.com/abhayrawat" target="_blank"><img align="center" src="https://cdn.buymeacoffee.com/buttons/v2/default-yellow.png" alt="Buy Me A Coffee" height="30px" width= "108px"></a>
</p> 

# gesture_debouncer

Created simple widget that can act as debouncer to absorb certain gestures according to the cooldowns/futures.

Liked my work ? [support me](https://www.buymeacoffee.com/abhayrawat)

## Example
for full example please view example/main.dart
```dart
 Widget _getIconWidget(onPressed) {
    return IconButton(
      icon: Icon(
        liked ? FontAwesome.heart : FontAwesome.heart_empty,
      ),
      iconSize: iconSize,
      color: liked ? Colors.red : Colors.grey,
      onPressed: onPressed,
    );
  }
```
```dart
GestureDebouncer(
          cooldownAfterExecution: const Duration(seconds: 5),
          cooldownBuilder: (BuildContext ctx, _) {
            return Stack(
              alignment: AlignmentDirectional.center,
              children: [
                _getIconWidget(() {
                  if (liked) {
                    toast("You have recently liked this");
                  } else {
                    toast("You have recently unliked this");
                  }
                }),
                IgnorePointer(
                  // Used so that main icon gets the click event
                  child: Icon(
                    Icons.lock_outline,
                    color: liked ? Colors.white : Colors.grey,
                    size: iconSize / 3,
                  ),
                ),
              ],
            );
          },
          onError: (e) {
            log(e.toString());
          },
          builder: (BuildContext ctx, Future<void> Function()? onGesture) {
            return _getIconWidget(onGesture);
          },
          onGesture: () async {
            setState(() {
              liked = !liked;
            });
            await Future.delayed(const Duration(seconds: 5), () {});
          },
        )
```

## Screenshot
![](https://github.com/abhay-s-rawat/gesture_debouncer/blob/main/example/screenshots/gesture_debouncer.gif)
