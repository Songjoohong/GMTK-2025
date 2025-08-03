using UnityEngine;

public class MushroomPickup : MonoBehaviour
{
    public string playerTag = "Player";
    public string cloneTag = "Ghost";

    public GameObject collectEffectPrefab; // 아이템 수집 이펙트 프리팹
    public float effectDuration = 1.0f; // 이펙트 지속시간

    void OnTriggerEnter2D(Collider2D other)
    {
        if (other.CompareTag(playerTag))
        {
            var characterStatus = other.GetComponent<CharacterStatus>();
            if (characterStatus != null)
            {
                if (characterStatus.currentStatus == CharacterStatus.Status.Chick)
                {
                    characterStatus.ChangeStatus(CharacterStatus.Status.Chicken);

                    // 닭 변신 로직
                }
                else if (characterStatus.currentStatus == CharacterStatus.Status.Chicken)
                {
                    SoundManager.Instance.PlayOneShotSound("SFX_Eat_Muschroom");
                    // 알 낳기 로직 (알 오브젝트 생성 등)
                }
            }
            // 달걀 상태는 여기서 따로 다룰 필요 없음
            // 이펙트 재생 및 버섯 제거 처리
            if (collectEffectPrefab != null)
            {
                GameObject effect = Instantiate(collectEffectPrefab, transform.position, Quaternion.identity);
                Destroy(effect, effectDuration);
            }
            gameObject.SetActive(false);  // 버섯은 먹히면 사라짐
        }
    }
}